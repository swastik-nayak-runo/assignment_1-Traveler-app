import 'package:assignment_1/screens/edit%20screens/edit_plan_page.dart';
import 'package:assignment_1/screens/trips/trips_plan_provider.dart';
import 'package:assignment_1/screens/trips/widgets/trip_detail_body.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    fetchTripData();
  }

  Future<void> fetchTripData() async {
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
          ? start.add(const Duration(days: 15)) // fallback: 30 days after start
          : (data['endDate'] as Timestamp).toDate();

      setState(() {
        _tripData = data;
        _days = _buildDayRange(start, end);
        _tabController = TabController(length: _days.length, vsync: this);
      });
    } else {
      setState(() {});
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

    return ChangeNotifierProvider(
      create: (_) => TripPlansProvider(userId: 'demoUser', tripId: widget.tripId)..fetchPlans(),
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: fetchTripData,  // This will refresh the trip details
          child: TripDetailBody(
            tripId: widget.tripId,
            tripData: _tripData!,
            days: _days,
            tabController: _tabController,
            onAdding: () {
              context.read<TripPlansProvider>().fetchPlans();
            },
          ),
        ),
      ),
    );
  }
}
