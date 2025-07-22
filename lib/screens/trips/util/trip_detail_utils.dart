import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';



/// Normalize Timestamp? -> DateTime?
DateTime? tsOrNull(dynamic v) {
  if (v == null) return null;
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  return null;
}
/// Strip time-of-day
DateTime asDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// Internal enum for quick icon mapping
enum PlanType { activity, travel, lodging, restaurant }

/// Model used inside DayPlansView
class NormalizedPlan {
  final PlanType type;
  final String id;
  final String title;
  final String? subtitle;
  final DateTime startDay;
  final DateTime endDay;

  const NormalizedPlan({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.startDay,
    required this.endDay,
  });

  IconData get icon {
    switch (type) {
      case PlanType.activity:
        return Icons.event;
      case PlanType.travel:
        return Icons.flight_takeoff; // change to train if you store mode
      case PlanType.lodging:
        return Icons.hotel;
      case PlanType.restaurant:
        return Icons.restaurant;
    }
  }
}
