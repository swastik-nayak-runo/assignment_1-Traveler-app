import 'package:assignment_1/screens/add_screen/widgets/activity_plan_tab.dart';
import 'package:assignment_1/screens/add_screen/widgets/lodging_plan_tab.dart';
import 'package:assignment_1/screens/add_screen/widgets/restaurant_plan_tab.dart';
import 'package:assignment_1/screens/add_screen/widgets/travel_plan_tab.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddPlanPage extends StatefulWidget {
  final String tripId;
  final String userId;

  const AddPlanPage({
    super.key,
    required this.tripId,
    this.userId = 'demoUser',
  });

  @override
  State<AddPlanPage> createState() => _AddPlanPageState();
}

class _AddPlanPageState extends State<AddPlanPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final CollectionReference<Map<String, dynamic>> _activityRef;
  late final CollectionReference<Map<String, dynamic>> _travelRef;
  late final CollectionReference<Map<String, dynamic>> _lodgingRef;
  late final CollectionReference<Map<String, dynamic>> _restaurantRef;

  DateTime? tripStartDate;
  DateTime? tripEndDate;
  String destination = "Unknown";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    final baseTripRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('trips')
        .doc(widget.tripId);

    _activityRef = baseTripRef.collection('activityPlans');
    _travelRef = baseTripRef.collection('travelPlans');
    _lodgingRef = baseTripRef.collection('lodgingPlans');
    _restaurantRef = baseTripRef.collection('restaurantPlans');

    _fetchTripDetails(baseTripRef);
  }

  Future<void> _fetchTripDetails(DocumentReference<Map<String, dynamic>> tripRef) async {
    final docSnap = await tripRef.get();
    if (docSnap.exists) {
      final data = docSnap.data();
      setState(() {
        destination = data?['destination'] ?? "Unknown";
        tripStartDate = (data?['startDate'] as Timestamp?)?.toDate();
        tripEndDate = (data?['endDate'] as Timestamp?)?.toDate();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd-MM-yyyy');
    final startLabel =
    tripStartDate != null ? fmt.format(tripStartDate!) : 'Start date not set';
    final endLabel =
    tripEndDate != null ? fmt.format(tripEndDate!) : 'End date not set';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Padding(
            padding:
            const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 12),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Plan your trip for",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      destination,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(startLabel, style: const TextStyle(color: Colors.black)),
                    const Text('→', style: TextStyle(color: Colors.black)),
                    Text(endLabel, style: const TextStyle(color: Colors.black)),
                  ],
                ),
              ],
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.black,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
            tabs: const [
              Tab(text: 'Activity'),
              Tab(text: 'Travel'),
              Tab(text: 'Lodging'),
              Tab(text: 'Food'),
            ],
          ),
        ),
      ),
      body: isLoading || tripStartDate == null || tripEndDate == null
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : TabBarView(
        controller: _tabController,
        children: [
          ActivityPlansTab(
            ref: _activityRef,
            onPLanSaved: () => Navigator.pop(context, true),
          ),
          TravelPlansTab(
            ref: _travelRef,
            onPLanSaved: () => Navigator.pop(context, true),
          ),
          LodgingPlansTab(
            ref: _lodgingRef,
            onPLanSaved: () => Navigator.pop(context, true),
          ),
          RestaurantPlansTab(
            ref: _restaurantRef,
            tripStartDate: tripStartDate!,
            tripEndDate: tripEndDate!,
            onPLanSaved: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }

}
