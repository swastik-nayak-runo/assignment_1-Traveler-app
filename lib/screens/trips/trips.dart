import 'package:assignment_1/screens/add_screen/add_plan_page.dart';
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
    _tabController = TabController(length: 4, vsync: this);
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
            Tab(text: "Incomplete"),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _tripStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _LoadingTabs(controller: _tabController);
          }

          if (snapshot.hasError) {
            return _ErrorTabs(
                error: snapshot.error.toString(), controller: _tabController);
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _EmptyTabs(
                message: "No trips yet", controller: _tabController);
          }

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          final past = <TripDoc>[];
          final upcoming = <TripDoc>[];
          final ongoing = <TripDoc>[];
          final incomplete = <TripDoc>[]; // New list

          for (final docSnap in snapshot.data!.docs) {
            final data = docSnap.data();
            final trip = TripDoc.fromFirestore(docSnap.id, data);

            if (trip.start == null || trip.end == null) {
              incomplete.add(trip); // If any date missing → incomplete
              continue;
            }

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
              _TripList(trips: incomplete, emptyLabel: "No incomplete trips"),
            ],
          );
        },
      ),
    );
  }
}

class _LoadingTabs extends StatelessWidget {
  final TabController controller;
  const _LoadingTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        ShimmerList(itemCount: 3, itemHeight: 92),
        ShimmerList(itemCount: 3, itemHeight: 92),
        ShimmerList(itemCount: 3, itemHeight: 92),
        ShimmerList(itemCount: 3, itemHeight: 92),
      ],
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

  const _TripList({
    required this.trips,
    required this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) {
      return _EmptyState(message: emptyLabel);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final t = trips[i];
        final startStr = t.start != null ? _dateFmt.format(t.start!) : "—";
        final endStr = t.end != null ? _dateFmt.format(t.end!) : "—";
        final datesLabel = (t.start != null && t.end != null)
            ? "$startStr → $endStr"
            : "Dates not set";

        return Container(
          width: MediaQuery.of(context).size.width - 50,
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Top row: destination + open icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Destination + dates
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.destination,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          datesLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        // TODO: open trip details page
                      },
                      child: const Icon(
                        Icons.open_in_new_rounded,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Bottom row: edit / add plan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        // TODO: edit trip info
                      },
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Edit Trip Info',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddPlanPage(tripId: t.id),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.add,
                        size: 23,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Add your trip plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ErrorTabs extends StatelessWidget {
  final String error;
  final TabController controller;
  const _ErrorTabs({required this.error, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _ErrorState(error: error),
        _ErrorState(error: error),
        _ErrorState(error: error),
        _ErrorState(error: error),
      ],
    );
  }
}

class _EmptyTabs extends StatelessWidget {
  final String message;
  final TabController controller;
  const _EmptyTabs({required this.message, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _EmptyState(message: message),
        _EmptyState(message: message),
        _EmptyState(message: message),
        _EmptyState(message: message),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Error: $error",
          style: TextStyle(color: Theme.of(context).colorScheme.error)),
    );
  }
}
