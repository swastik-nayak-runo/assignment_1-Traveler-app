import 'package:assignment_1/screens/add_screen/add_plan_page.dart';
import 'package:assignment_1/screens/edit%20screens/edit_trip_page.dart';
import 'package:assignment_1/screens/trips/trips_detail_page.dart';
import 'package:assignment_1/screens/trips/widgets/empty_tabs.dart';
import 'package:assignment_1/screens/trips/widgets/error_tabs.dart';
import 'package:assignment_1/screens/trips/widgets/loading_tabs.dart';
import 'package:assignment_1/widgets/custom_Alert_box.dart';
import 'package:assignment_1/widgets/custome_shimmer.dart';
import 'package:assignment_1/widgets/shimmer_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const String _demoUserId = 'demoUser'; // change later when auth added
final _dateFmt = DateFormat('dd-MM-yyyy');

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _tripStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_demoUserId)
        .collection('trips')
        .orderBy('startDate', descending: false)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("My Trips",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black,
          indicatorColor: Colors.black,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
          tabs: const [
            Tab(text: "Ongoing"),
            Tab(text: "Upcoming"),
            Tab(text: "Past"),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _tripStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingTabs(controller: _tabController);
          }

          if (snapshot.hasError) {
            return ErrorTabs(
                error: snapshot.error.toString(), controller: _tabController);
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return EmptyTabs(
                message: "No trips yet", controller: _tabController);
          }

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          final past = <TripDoc>[];
          final upcoming = <TripDoc>[];
          final ongoing = <TripDoc>[];

          for (final docSnap in snapshot.data!.docs) {
            final data = docSnap.data();
            final trip = TripDoc.fromFirestore(docSnap.id, data);

            final start = _asDay(trip.start!);
            final end = _asDay(trip.end!);

            if (start.isBefore(today) && end.isBefore(today)) {
              past.add(trip);
            } else if (start.isAfter(today) && end.isAfter(today)) {
              upcoming.add(trip);
            } else {
              ongoing.add(trip);
            }
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _TripList(trips: ongoing, emptyLabel: "No ongoing trips"),
              _TripList(trips: upcoming, emptyLabel: "No upcoming trips"),
              _TripList(trips: past, emptyLabel: "No past trips"),
            ],
          );
        },
      ),
    );
  }
}

class TripDoc {
  final String id;
  final String destination;
  final DateTime? start;
  final DateTime? end;

  TripDoc({
    required this.id,
    required this.destination,
    required this.start,
    required this.end,
  });

  factory TripDoc.fromFirestore(String id, Map<String, dynamic> data) {
    final dest = (data['destination'] ?? '') as String;
    final tsStart = data['startDate'] as Timestamp?;
    final tsEnd = data['endDate'] as Timestamp?;
    return TripDoc(
      id: id,
      destination: dest,
      start: tsStart?.toDate(),
      end: tsEnd?.toDate(),
    );
  }
}

DateTime _asDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

class _TripList extends StatelessWidget {
  final List<TripDoc> trips;
  final String emptyLabel;
  final String userId; // add this so we can delete properly

  const _TripList({
    required this.trips,
    required this.emptyLabel,
    this.userId = 'demoUser',
  });

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) {
      return EmptyState(message: emptyLabel);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final t = trips[i];
        return _TripCard(
          trip: t,
          userId: userId,
        );
      },
    );
  }
}

Future<bool> deleteTripAndPlans({
  required String userId,
  required String tripId,
}) async {
  final db = FirebaseFirestore.instance;
  final tripRef =
      db.collection('users').doc(userId).collection('trips').doc(tripId);

  // Known subcollections – adjust if you add more
  const subColls = [
    'activityPlans',
    'travelPlans',
    'lodgingPlans',
    'restaurantPlans',
  ];

  try {
    for (final coll in subColls) {
      final snap = await tripRef.collection(coll).get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
    }
    await tripRef.delete();
    return true;
  } catch (_) {
    return false;
  }
}

class _TripCard extends StatefulWidget {
  final TripDoc trip;
  final String userId;

  const _TripCard({
    required this.trip,
    required this.userId,
  });

  @override
  State<_TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<_TripCard> {
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    // Confirm
    final confirmed = await showConfirmDeleteDialog(
      context,
      widget.trip.destination,
      "Trip",
    );
    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    final ok = await deleteTripAndPlans(
      userId: widget.userId,
      tripId: widget.trip.id,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Trip "${widget.trip.destination}" deleted'
              : 'Failed to delete "${widget.trip.destination}"',
        ),
      ),
    );

    // No need to manually remove from list; the parent Stream/Query will rebuild.
    // Keep shimmer for a brief beat so user sees something happened.
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted)
        setState(() => _isDeleting = false); // in case doc still visible
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trip;
    final startStr = t.start != null ? _dateFmt.format(t.start!) : "—";
    final endStr = t.end != null ? _dateFmt.format(t.end!) : "—";
    final datesLabel = (t.start != null && t.end != null)
        ? "$startStr → $endStr"
        : "Dates not set";

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _isDeleting
          ? const _TripCardShimmer()
          : InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                TripDetailPage(tripId: t.id),
          ),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width - 50,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 270,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              t.destination,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                              ),
                            ),
                            SizedBox(width: 10,),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditTripPage(tripId: t.id),
                                  ),
                                );
                              },
                              child: Icon(Icons.edit, size: 23, color: Colors.white),
                            ),

                          ],
                        ),
                        SizedBox(height: 10,),
                        Text(
                         datesLabel,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _handleDelete(),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      )
    );
  }
}

class _TripCardShimmer extends StatelessWidget {
  const _TripCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('shimmer'),
      width: MediaQuery.of(context).size.width - 50,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: destination + delete icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomShimmer(width: 120, height: 18), // Destination shimmer
                  SizedBox(height: 8),
                  CustomShimmer(width: 100, height: 14), // Date shimmer
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          // Bottom row: edit/add plan shimmer
          Row(
            children: [
              CustomShimmer(width: 16, height: 16, borderRadius: 4),
              SizedBox(width: 8),
              CustomShimmer(width: 80, height: 14),
              Spacer(),
              CustomShimmer(width: 16, height: 16, borderRadius: 4),
              SizedBox(width: 8),
              CustomShimmer(width: 120, height: 14),
            ],
          ),
        ],
      ),
    );
  }
}
