import 'package:assignment_1/screens/add_screen/add_plan_page.dart';
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
            .orderBy('startDate', descending: false) // server-side sort (optional but good)
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
            return !start.isBefore(today); // true if start >= today
          }).toList();

          // nothing upcoming
          if (filtered.isEmpty) {
            return const _NoTripsMessage();
          }

          // sort locally just in case (server sort may be missing/null entries)
          filtered.sort((a, b) {
            final aStart = ((a.data() as Map<String, dynamic>)['startDate'] as Timestamp).toDate();
            final bStart = ((b.data() as Map<String, dynamic>)['startDate'] as Timestamp).toDate();
            return aStart.compareTo(bStart);
          });

          final dateFormat = DateFormat('dd-MM-yyyy');

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final tripSnap = filtered[index];
              final trip = tripSnap.data() as Map<String, dynamic>;

              final destination = trip['destination'] ?? 'Unknown';

              final startTs = trip['startDate'] as Timestamp?;
              final endTs = trip['endDate'] as Timestamp?;

              final startDate = startTs?.toDate();
              final endDate = endTs?.toDate();

              final startTimeRaw = trip['startTime']; // from Firestore
              final endTimeRaw = trip['endTime'];

              String startTime = (startTimeRaw == null || (startTimeRaw as String).isEmpty)
                  ? 'null'
                  : startTimeRaw;
              String endTime = (endTimeRaw == null || (endTimeRaw as String).isEmpty)
                  ? 'null'
                  : endTimeRaw;

              String dateLabel;
              if (startDate != null && endDate != null) {
                dateLabel =
                "${DateFormat('dd-MM-yyyy').format(startDate)} ($startTime) → ${DateFormat('dd-MM-yyyy').format(endDate)} ($endTime)";
              } else if (startDate != null) {
                dateLabel =
                "${DateFormat('dd-MM-yyyy').format(startDate)} ($startTime)";
              } else {
                dateLabel = "Dates not set";
              }

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
                                destination,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              Text(
                                dateLabel,
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
                                  builder: (_) => AddPlanPage(tripId: tripSnap.id),
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_sharp, size: 30),
          SizedBox(height: 4),
          Text("You have no upcoming trips"),
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
        itemCount: 3, // show 3 shimmer cards
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
                      children:  [
                        CustomShimmer(width: 120, height: 18), // destination
                        SizedBox(height: 8),
                        CustomShimmer(width: 100, height: 14), // date
                      ],
                    ),
                     CustomShimmer(width: 30, height: 30, borderRadius: 15), // icon
                  ],
                ),
                 SizedBox(height: 16),
                // Bottom row
                Row(
                  children:  [
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
