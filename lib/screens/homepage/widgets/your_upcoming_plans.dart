import 'package:assignment_1/screens/add_screen/add_page.dart';
import 'package:assignment_1/screens/add_screen/add_plan_page.dart';
import 'package:assignment_1/screens/edit%20screens/edit_trip_page.dart';
import 'package:assignment_1/screens/trips/trips_detail_page.dart';
import 'package:assignment_1/widgets/custom_Alert_box.dart';
import 'package:assignment_1/widgets/custome_shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <-- for dd-MM-yyyy formatting

class UpcomingTripsList extends StatelessWidget {
  const UpcomingTripsList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc('demoUser')
            .collection('trips')
            .orderBy('startDate',
                descending: false) // server-side sort (optional but good)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const UpcomingTripsShimmer(); // <-- shimmer here
          }

          // no snapshot or no docs
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const _NoTripsMessage();
          }

          final docs = snapshot.data!.docs;

          // normalize "today" (midnight local)
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          // filter: only startDate >= today
          final filtered = docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            final ts = data['startDate'] as Timestamp?;
            if (ts == null) return false; // no start date -> exclude
            final start = ts.toDate();
            return !start.isBefore(today) &&
                !start.isAtSameMomentAs(today); // true if start >= today
          }).toList();

          // nothing upcoming
          if (filtered.isEmpty) {
            return const _NoTripsMessage();
          }

          // sort locally just in case (server sort may be missing/null entries)
          filtered.sort((a, b) {
            final aStart =
                ((a.data() as Map<String, dynamic>)['startDate'] as Timestamp)
                    .toDate();
            final bStart =
                ((b.data() as Map<String, dynamic>)['startDate'] as Timestamp)
                    .toDate();
            return aStart.compareTo(bStart);
          });

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return TripCard(tripSnap: filtered[index]);
            },
          );
        },
      ),
    );
  }
}

/// Shared "no trips" widget
class _NoTripsMessage extends StatelessWidget {
  const _NoTripsMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_sharp, size: 30),
          const SizedBox(height: 4),
          const Text("You have no upcoming trips"),
          const SizedBox(
            height: 4,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PlanTripPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black
            ),
            child: const Text('Add Your Trip', style: TextStyle(color: Colors.white),),
          )
        ],
      ),
    );
  }
}

class UpcomingTripsShimmer extends StatelessWidget {
  const UpcomingTripsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        // show 3 shimmer cards
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return Container(
            width: MediaQuery.of(context).size.width - 50,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomShimmer(width: 120, height: 18), // destination
                        SizedBox(height: 8),
                        CustomShimmer(width: 100, height: 14), // date
                      ],
                    ),
                    CustomShimmer(width: 30, height: 30, borderRadius: 15),
                    // icon
                  ],
                ),
                SizedBox(height: 16),
                // Bottom row
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
        },
      ),
    );
  }
}

class TripCard extends StatefulWidget {
  final DocumentSnapshot tripSnap;

  const TripCard({super.key, required this.tripSnap});

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  bool isDeleting = false;

  Future<void> _deleteTrip(BuildContext context) async {
    final trip = widget.tripSnap.data() as Map<String, dynamic>;
    final destination = trip['destination'] ?? 'Unknown';

    final confirmed =
        await showConfirmDeleteDialog(context, destination, "Trip");
    if (confirmed != true) return;

    setState(() => isDeleting = true); // Start shimmer

    final db = FirebaseFirestore.instance;
    final tripRef = db
        .collection('users')
        .doc('demoUser')
        .collection('trips')
        .doc(widget.tripSnap.id);

    const subColls = [
      'activityPlans',
      'travelPlans',
      'lodgingPlans',
      'restaurantPlans',
    ];

    try {
      // Delete subcollections
      for (final name in subColls) {
        final q = await tripRef.collection(name).get();
        for (final doc in q.docs) {
          await doc.reference.delete();
        }
      }

      await tripRef.delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trip "$destination" deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete "$destination": $e')),
      );
    } finally {
      if (mounted) setState(() => isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isDeleting) {
      // Show shimmer instead of trip card
      return Container(
        width: MediaQuery.of(context).size.width - 50,
        child: const CustomShimmer(width: double.infinity, height: 120),
      );
    }

    final trip = widget.tripSnap.data() as Map<String, dynamic>;
    final destination = trip['destination'] ?? 'Unknown';
    final startTs = trip['startDate'] as Timestamp?;
    final endTs = trip['endDate'] as Timestamp?;

    final startDate = startTs?.toDate();
    final endDate = endTs?.toDate();

    String dateLabel;
    if (startDate != null && endDate != null) {
      dateLabel =
          "${DateFormat('dd-MM-yyyy').format(startDate)}  →  ${DateFormat('dd-MM-yyyy').format(endDate)}";
    } else if (startDate != null) {
      dateLabel = "${DateFormat('dd-MM-yyyy').format(startDate)} ";
    } else {
      dateLabel = "Dates not set";
    }

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              TripDetailPage(tripId: widget.tripSnap.id),
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
                            destination,
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
                                      EditTripPage(tripId: widget.tripSnap.id),
                                ),
                              );
                            },
                            child: Icon(Icons.edit, size: 23, color: Colors.white),
                          ),

                        ],
                      ),
                      SizedBox(height: 10,),
                      Text(
                        dateLabel,
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
                  onTap: () => _deleteTrip(context),
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
    );
  }
}
