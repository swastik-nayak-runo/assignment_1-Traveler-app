import 'package:assignment_1/screens/trips/util/trip_detail_utils.dart'
    show PlanType, NormalizedPlan, tsOrNull, asDay; // confirm these are exported!
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TripPlansProvider extends ChangeNotifier {
  TripPlansProvider({
    required this.userId,
    required this.tripId,
  });

  final String userId;
  final String tripId;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Convenience ref to this trip document
  DocumentReference<Map<String, dynamic>> get _tripRef => _db
      .collection('users')
      .doc(userId)
      .collection('trips')
      .doc(tripId);

  // Map PlanType -> subcollection name
  static const Map<PlanType, String> _planTypeToColl = {
    PlanType.activity: 'activityPlans',
    PlanType.travel: 'travelPlans',
    PlanType.lodging: 'lodgingPlans',
    PlanType.restaurant: 'restaurantPlans',
  };

  // ----- State -----
  List<NormalizedPlan> _plans = [];
  bool _loading = false;
  bool _error = false;

  List<NormalizedPlan> get plans => _plans;
  bool get isLoading => _loading;
  bool get hasError => _error;

  // ----- Load -----
  Future<void> fetchPlans() async {
    _loading = true;
    _error  = false;
    notifyListeners();

    try {
      final tripSnap = await _tripRef.get();
      if (!tripSnap.exists) {
        _plans = [];
        _loading = false;
        notifyListeners();
        return;
      }

      final tripData = tripSnap.data()!;
      final tripStart = tsOrNull(tripData['startDate']) ?? DateTime.now();
      final tripEnd   = tsOrNull(tripData['endDate'])   ?? DateTime.now();

      // fetch subcollections in parallel
      final snaps = await Future.wait([
        _tripRef.collection('activityPlans').get(),
        _tripRef.collection('travelPlans').get(),
        _tripRef.collection('lodgingPlans').get(),
        _tripRef.collection('restaurantPlans').get(),
      ]);

      final loaded = <NormalizedPlan>[];

      // ----- Activity -----
      for (final doc in snaps[0].docs) {
        final data  = doc.data();
        final start = tsOrNull(data['startDate']) ?? tripStart;
        final end   = tsOrNull(data['endDate'])   ?? tripEnd;
        loaded.add(
          NormalizedPlan(
            type: PlanType.activity,
            id: doc.id,
            title: (data['eventName'] ?? 'Activity') as String,
            subtitle: data['venue'] as String?,
            startDay: asDay(start),
            endDay: asDay(end),
          ),
        );
      }

      // ----- Travel -----
      for (final doc in snaps[1].docs) {
        final data  = doc.data();
        final start = tsOrNull(data['departureDate']) ?? tripStart;
        final end   = tsOrNull(data['arrivalDate'])   ?? tripEnd;
        final mode  = (data['modeOfTravel'] ?? 'Travel') as String;
        final name  = (data['name'] ?? data['travelName'] ?? '') as String;
        final title = name.isEmpty ? mode : '$mode: $name';
        final src   = data['source'] as String?;
        final dst   = data['destination'] as String?;
        loaded.add(
          NormalizedPlan(
            type: PlanType.travel,
            id: doc.id,
            title: title,
            subtitle: (src != null && dst != null) ? '$src → $dst' : null,
            startDay: asDay(start),
            endDay: asDay(end),
          ),
        );
      }

      // ----- Lodging -----
      for (final doc in snaps[2].docs) {
        final data  = doc.data();
        final start = tsOrNull(data['checkInDate'])  ?? tripStart;
        final end   = tsOrNull(data['checkOutDate']) ?? tripEnd;
        loaded.add(
          NormalizedPlan(
            type: PlanType.lodging,
            id: doc.id,
            title: (data['lodgingName'] ?? 'Lodging') as String,
            subtitle: data['address'] as String?,
            startDay: asDay(start),
            endDay: asDay(end),
          ),
        );
      }

      // ----- Restaurant -----
      for (final doc in snaps[3].docs) {
        final data    = doc.data();
        final planDay = tsOrNull(data['date']);
        final start   = planDay ?? tripStart;
        final end     = planDay ?? tripEnd;
        loaded.add(
          NormalizedPlan(
            type: PlanType.restaurant,
            id: doc.id,
            title: (data['restaurantName'] ?? 'Restaurant') as String,
            subtitle: data['address'] as String?,
            startDay: asDay(start),
            endDay: asDay(end),
          ),
        );
      }

      _plans   = loaded;
      _loading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('fetchPlans error: $e');
      _error   = true;
      _loading = false;
      notifyListeners();
    }
  }

  // ----- Delete -----
  Future<bool> deletePlan(PlanType type, String planId) async {
    try {
      final collName = _planTypeToColl[type]!;
      await _tripRef.collection(collName).doc(planId).delete();
      await fetchPlans(); // refresh list after delete
      return true;
    } catch (e) {
      debugPrint('deletePlan error: $e');
      return false;
    }
  }

  /// Call after editing to re-pull Firestore.
  Future<void> refreshAfterEdit() => fetchPlans();
}
