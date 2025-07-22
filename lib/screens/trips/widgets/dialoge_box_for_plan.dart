import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:assignment_1/screens/trips/util/trip_detail_utils.dart';
import 'package:intl/intl.dart';

String dialogTitleForPlan(PlanType type) {
  switch (type) {
    case PlanType.activity:   return 'Activity Details';
    case PlanType.travel:     return 'Travel Details';
    case PlanType.lodging:    return 'Lodging Details';
    case PlanType.restaurant: return 'Restaurant Details';
  }
}

//for tap  info
const Map<PlanType, String> _planTypeToColl = {
  PlanType.activity:   'activityPlans',
  PlanType.travel:     'travelPlans',
  PlanType.lodging:    'lodgingPlans',
  PlanType.restaurant: 'restaurantPlans',
};


Future<void> showPlanDetailsDialog(BuildContext context, NormalizedPlan plan, String tripId,) async {
  const userId = 'demoUser';

  final collName = _planTypeToColl[plan.type];
  if (collName == null) return;

  final docRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('trips')
      .doc(tripId)
      .collection(collName)
      .doc(plan.id);

  late Map<String, dynamic>? data;
  try {
    final snap = await docRef.get();
    data = snap.data();
  } catch (e) {
    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text('Failed to load plan details:\n$e'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
    return;
  }

  if (!context.mounted) return;

  if (data == null) {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Not found'),
        content: const Text('This plan no longer exists.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
    return;
  }

  // Build content rows based on plan type
  final rows = buildDetailRowsForPlan(plan.type, data);

  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      title: Text(dialogTitleForPlan(plan.type,), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: rows,
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.black
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: Colors.white),),
        ),
      ],
    ),
  );
}



/// Builds a list of display rows (Widgets) appropriate for a plan type.
List<Widget> buildDetailRowsForPlan(PlanType type, Map<String, dynamic> data) {
  final rows = <Widget>[];

  void addRow(String label, String? value) {
    if (value == null || value.trim().isEmpty) return;
    rows.add(Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    ));
  }

  String? fmtTs(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) {
      final dt = v.toDate();
      return DateFormat('dd-MM-yyyy').format(dt);
    }
    if (v is DateTime) {
      return DateFormat('dd-MM-yyyy').format(v);
    }
    return v.toString();
  }

  // time values are stored as simple strings in your write code
  String? fmtTime(dynamic v) {
    if (v == null) return null;
    return v.toString(); // you could parse & reformat if needed
  }

  switch (type) {
    case PlanType.activity:
      addRow('Event Name', data['eventName'] as String?);
      addRow('Start Date', fmtTs(data['startDate']));
      addRow('Start Time', fmtTime(data['startTime']));
      addRow('End Date', fmtTs(data['endDate']));
      addRow('End Time', fmtTime(data['endTime']));
      addRow('Venue', data['venue'] as String?);
      addRow('Phone', data['phone'] as String?);
      addRow('Email', data['email'] as String?);
      addRow('Website', data['website'] as String?);
      break;

    case PlanType.travel:
      addRow('Mode', data['modeOfTravel'] as String?);
      addRow('Name', (data['name'] ?? data['travelName']) as String?);
      addRow('Departure Date', fmtTs(data['departureDate']));
      addRow('Departure Time', fmtTime(data['departureTime']));
      addRow('Arrival Date', fmtTs(data['arrivalDate']));
      addRow('Arrival Time', fmtTime(data['arrivalTime']));
      addRow('Flight / Train #', data['travelNumber'] as String?);
      addRow('Seat #', data['seatNumber'] as String?);
      addRow('From', data['source'] as String?);
      addRow('To', data['destination'] as String?);
      break;

    case PlanType.lodging:
      addRow('Lodging Name', data['lodgingName'] as String?);
      addRow('Check-in Date', fmtTs(data['checkInDate']));
      addRow('Check-in Time', fmtTime(data['checkInTime']));
      addRow('Check-out Date', fmtTs(data['checkOutDate']));
      addRow('Check-out Time', fmtTime(data['checkOutTime']));
      addRow('Address', data['address'] as String?);
      addRow('Phone', data['phone'] as String?);
      addRow('Email', data['email'] as String?);
      break;

    case PlanType.restaurant:
      addRow('Restaurant Name', data['restaurantName'] as String?);
      addRow('Date', fmtTs(data['date']));
      addRow('Time', fmtTime(data['time']));
      addRow('Confirmed', (data['confirmation'] == true) ? 'Yes' : null);
      addRow('Address', data['address'] as String?);
      addRow('Phone', data['phone'] as String?);
      addRow('Email', data['email'] as String?);
      break;
  }

  if (rows.isEmpty) {
    rows.add(const Text('No details available'));
  }

  return rows;
}
