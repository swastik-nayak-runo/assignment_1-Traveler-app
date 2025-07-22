import 'package:assignment_1/screens/trips/util/trip_detail_utils.dart';
import 'package:assignment_1/screens/trips/widgets/dialoge_box_for_plan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripDetailPage extends StatefulWidget {
  final String tripId;

  const TripDetailPage({
    super.key,
    required this.tripId,
  });

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage>
    with SingleTickerProviderStateMixin {
  List<DateTime> _days = [];
  late TabController _tabController;
  Map<String, dynamic>? _tripData;

  @override
  void initState() {
    super.initState();
    _fetchTripData();
  }

  Future<void> _fetchTripData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc('demoUser')
        .collection('trips')
        .doc(widget.tripId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      final start = data['startDate'] == null
          ? DateTime.now() // fallback to today's date
          : (data['startDate'] as Timestamp).toDate();

      final end = data['endDate'] == null
          ? DateTime.now() // fallback to trip end date
          : (data['endDate'] as Timestamp).toDate();

      print(start.toString() + " " + end.toString());
      setState(() {
        _tripData = data;
        _days = _buildDayRange(start, end);
        _tabController = TabController(length: _days.length, vsync: this);

      });
    } else {
      setState(() {

      });
    }
  }

  List<DateTime> _buildDayRange(DateTime start, DateTime end) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    final list = <DateTime>[];
    var d = s;
    while (!d.isAfter(e)) {
      list.add(d);
      d = d.add(const Duration(days: 1));
    }
    print(list);
    return list;
  }

  /// Helper for day suffix (21st, 22nd, 23rd, etc.)
  String _dayWithSuffix(int day) {
    if (day >= 11 && day <= 13) return "${day}th";
    switch (day % 10) {
      case 1:
        return "${day}st";
      case 2:
        return "${day}nd";
      case 3:
        return "${day}rd";
      default:
        return "${day}th";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tripData == null) {
      return const Scaffold(
        body: Center(child: Text('Trip not found')),
      );
    }


    final destination = _tripData?['destination'] ?? 'Unknown Trip';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          destination,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: _days.isNotEmpty
            ? PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black87,
            ),
            labelColor: Colors.white,
            splashFactory: NoSplash.splashFactory,
            tabAlignment: TabAlignment.center,
            unselectedLabelColor: Colors.black,
            tabs: _days.map((d) {
              final weekday = DateFormat('EEE').format(d); // Mon, Tue
              final dayWithSuffix = _dayWithSuffix(d.day); // 21st, 22nd
              final month = DateFormat('MMM').format(d); // Jul
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      weekday,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dayWithSuffix,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      month,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        )
            : null,
      ),
      body: _days.isNotEmpty
          ? TabBarView(
        controller: _tabController,
        children: _days
            .map((d) => DayPlansView(
          tripId: widget.tripId,
          date: d,
        ))
            .toList(),
      )
          : const Center(child: Text('No days found')),
    );
  }
}



/// --------------------------------------------------------------------------------
/// DayPlansView
/// --------------------------------------------------------------------------------
/// Fetches all plans from the four known subcollections under the trip doc,
/// normalizes their date ranges, and shows only those that include [date].
///
/// Rules:
/// - If plan.startDate is null  → use tripStart
/// - If plan.endDate   is null  → use tripEnd
/// - If plan has custom fields (checkInDate, departureDate, etc.) we map them
///   into a normalized range.
///
class DayPlansView extends StatelessWidget {
  final String tripId;
  final DateTime date;

  const DayPlansView({
    super.key,
    required this.tripId,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEEE, MMM d, yyyy').format(date);

    return FutureBuilder<List<NormalizedPlan>>(
      future: _fetchPlans(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.black,));
        }

        // Error
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allPlans = snapshot.data ?? [];

        // Filter by current day
        final dayPlans = allPlans.where((p) {
          final d = DateTime(date.year, date.month, date.day);
          return !d.isBefore(p.startDay) && !d.isAfter(p.endDay);
        }).toList();

        if (dayPlans.isEmpty) {
          return Center(
            child: Text(
              'No plans for $dateLabel',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: dayPlans.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final p = dayPlans[i];
            return Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                onTap: () => showPlanDetailsDialog(context, p, tripId),
                leading: Icon(
                  p.icon,
                  color: Colors.white,
                ),
                title: Text(p.title, style: TextStyle(color: Colors.white),),
                subtitle: Text(p.subtitle ?? '', style: TextStyle(color: Colors.white70),),
                // You could add onTap to edit/see details
              ),
            );
          },
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // Fetch + normalize
  // --------------------------------------------------------------------------
  Future<List<NormalizedPlan>> _fetchPlans() async {
    final tripRef = FirebaseFirestore.instance
        .collection('users')
        .doc('demoUser')
        .collection('trips')
        .doc(tripId);

    // Get trip dates first
    final tripSnap = await tripRef.get();
    if (!tripSnap.exists) return [];

    final tripData = tripSnap.data()!;
    final tripStart = tripData['startDate'] != null ?  (tripData['startDate'] as Timestamp).toDate() : DateTime.now();
    final tripEnd =  tripData['endDate'] != null ? (tripData['endDate'] as Timestamp).toDate() : DateTime.now();

    // Build list of subcollection refs
    final activityRef = tripRef.collection('activityPlans');
    final travelRef = tripRef.collection('travelPlans');
    final lodgingRef = tripRef.collection('lodgingPlans');
    final restaurantRef = tripRef.collection('restaurantPlans');

    // Fetch them in parallel
    final snaps = await Future.wait([
      activityRef.get(),
      travelRef.get(),
      lodgingRef.get(),
      restaurantRef.get(),
    ]);

    final plans = <NormalizedPlan>[];

    // ----- Activity Plans -----
    for (final doc in snaps[0].docs) {
      final data = doc.data();
      final start = tsOrNull(data['startDate']) ?? tripStart;
      final end = tsOrNull(data['endDate']) ?? tripEnd;
      final name = (data['eventName'] ?? 'Activity') as String;
      final venue = data['venue'] as String?;
      plans.add(
        NormalizedPlan(
          type: PlanType.activity,
          id: doc.id,
          title: name,
          subtitle: venue,
          startDay: asDay(start),
          endDay: asDay(end),
        ),
      );
    }

    // ----- Travel Plans -----
    for (final doc in snaps[1].docs) {
      final data = doc.data();
      final start = tsOrNull(data['departureDate']) ?? tripStart;
      final end = tsOrNull(data['arrivalDate']) ?? tripEnd;
      final mode = (data['modeOfTravel'] ?? 'Travel') as String; // flight / train
      final name = (data['name'] ?? data['travelName'] ?? '') as String;
      final title = name.isEmpty ? mode : '$mode: $name';
      plans.add(
        NormalizedPlan(
          type: PlanType.travel,
          id: doc.id,
          title: title,
          subtitle: data['source'] != null && data['destination'] != null
              ? '${data['source']} → ${data['destination']}'
              : null,
          startDay: asDay(start),
          endDay: asDay(end),
        ),
      );
    }

    // ----- Lodging Plans -----
    for (final doc in snaps[2].docs) {
      final data = doc.data();
      final start = tsOrNull(data['checkInDate']) ?? tripStart;
      final end = tsOrNull(data['checkOutDate']) ?? tripEnd;
      final name = (data['lodgingName'] ?? 'Lodging') as String;
      final addr = data['address'] as String?;
      plans.add(
        NormalizedPlan(
          type: PlanType.lodging,
          id: doc.id,
          title: name,
          subtitle: addr,
          startDay: asDay(start),
          endDay: asDay(end),
        ),
      );
    }

    // ----- Restaurant Plans -----
    for (final doc in snaps[3].docs) {
      final data = doc.data();
      final planDate = tsOrNull(data['date']); // restaurants are usually 1 day
      final start = planDate ?? tripStart;
      // If no specific date is given, span full trip; else single day
      final end = planDate ?? tripEnd;
      final name = (data['restaurantName'] ?? 'Restaurant') as String;
      final addr = data['address'] as String?;
      plans.add(
        NormalizedPlan(
          type: PlanType.restaurant,
          id: doc.id,
          title: name,
          subtitle: addr,
          startDay: asDay(start),
          endDay: asDay(end),
        ),
      );
    }

    return plans;
  }
}



