import 'package:assignment_1/screens/add_screen/add_plan_page.dart';
import 'package:assignment_1/screens/trips/trips_plan_provider.dart';
import 'package:assignment_1/screens/trips/widgets/day_plan_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TripDetailBody extends StatefulWidget {
  final Map<String, dynamic> tripData;
  final List<DateTime> days;
  final TabController tabController;
  final String tripId;
  final VoidCallback? onAdding;

  const TripDetailBody(
      {super.key,
      required this.tripData,
      required this.days,
      required this.tabController,
      required this.tripId,
      this.onAdding});

  @override
  State<TripDetailBody> createState() => _TripDetailBodyState();
}

class _TripDetailBodyState extends State<TripDetailBody> {

  /// Handle tap on the "+" button to add a plan.
  Future<void> _addPlan() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddPlanPage(tripId: widget.tripId),
      ),
    );

    if (updated == true) {
      // 1) Refresh plans in provider (if provided)
      if (mounted) {
        // Only call if provider exists above; wrap in try to avoid crash if absent.
        try {
          context.read<TripPlansProvider>().fetchPlans();
        } catch (_) {
          const SnackBar(
            content: Text(
              'Error fetching data',
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final destination = widget.tripData['destination'] ?? 'Unknown Trip';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          destination,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _addPlan,
            icon: const Icon(
              Icons.add,
              size: 30,
              color: Colors.black,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
        centerTitle: true,
        bottom: widget.days.isNotEmpty
            ? PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: TabBar(
                  controller: widget.tabController,
                  isScrollable: true,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black87,
                  ),
                  labelColor: Colors.white,
                  splashFactory: NoSplash.splashFactory,
                  tabAlignment: TabAlignment.center,
                  unselectedLabelColor: Colors.black,
                  tabs: widget.days.map((d) {
                    final weekday = DateFormat('EEE').format(d);
                    final dayWithSuffix = _dayWithSuffix(d.day);
                    final month = DateFormat('MMM').format(d);
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(weekday,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(dayWithSuffix,
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(month, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              )
            : null,
      ),
      body: widget.days.isNotEmpty
          ? TabBarView(
              controller: widget.tabController,
              children: widget.days.map((d) {
                return DayPlansView(
                  date: d,
                );
              }).toList(),
            )
          : const Center(child: Text('No days found')),
    );
  }

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
}
