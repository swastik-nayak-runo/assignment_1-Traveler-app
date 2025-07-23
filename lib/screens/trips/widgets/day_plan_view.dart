import 'package:assignment_1/screens/edit%20screens/edit_plan_page.dart';
import 'package:assignment_1/screens/trips/trips_plan_provider.dart';
import 'package:assignment_1/screens/trips/util/trip_detail_utils.dart';
import 'package:assignment_1/screens/trips/widgets/dialoge_box_for_plan.dart';
import 'package:assignment_1/widgets/custom_Alert_box.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DayPlansView extends StatefulWidget {
  final DateTime date;

  const DayPlansView({super.key, required this.date});

  @override
  State<DayPlansView> createState() => _DayPlansViewState();
}

class _DayPlansViewState extends State<DayPlansView> {
  Future<void> _deletePlan(
    BuildContext context,
    TripPlansProvider provider,
    NormalizedPlan plan,
  ) async {
    final label = _labelForPlanType(plan.type);

    // Confirm
    final confirmed = await showConfirmDeleteDialog(context, plan.title, label);
    if (confirmed != true) return;

    // Delete via provider
    final ok = await provider.deletePlan(plan.type, plan.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? '$label deleted' : 'Failed to delete $label',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TripPlansProvider>();

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }

    final allPlans = provider.plans;
    final d = DateTime(widget.date.year, widget.date.month, widget.date.day);

    // Plans valid for this day
    final dayPlans = allPlans
        .where((p) => !d.isBefore(p.startDay) && !d.isAfter(p.endDay))
        .toList();

    if (dayPlans.isEmpty) {
      final dateLabel = DateFormat('EEEE, MMM d, yyyy').format(widget.date);
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
          color: Colors.black87, // match your trip cards
          child: ListTile(
            onTap: () => showPlanDetailsDialog(context, p, provider.tripId),
            leading: Icon(p.icon, color: Colors.white),
            title: Text(
              p.title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              p.subtitle ?? '',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // DELETE
                  IconButton(
                    onPressed: () => _deletePlan(context, provider, p),
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  // EDIT
                  IconButton(
                    onPressed: () async {
                      final updated = await Navigator.of(context)
                          .push(
                        MaterialPageRoute(
                          builder: (context) =>
                            EditPlanPage(
                              tripId: provider.tripId,
                              planId: p.id,
                              planType: p.type,
                              userId: provider.userId,
                            )

                        ),
                      );
                      if (updated == true) {
                        provider.fetchPlans(); // refresh list after edit
                      }
                    },
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

String _labelForPlanType(PlanType type) {
  switch (type) {
    case PlanType.activity:
      return 'Activity Plan';
    case PlanType.travel:
      return 'Travel Plan';
    case PlanType.lodging:
      return 'Lodging Plan';
    case PlanType.restaurant:
      return 'Restaurant Plan';
  }
}
