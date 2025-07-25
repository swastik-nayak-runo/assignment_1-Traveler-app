import 'package:assignment_1/screens/add_screen/widgets/activity_plan_tab.dart';
import 'package:assignment_1/screens/add_screen/widgets/lodging_plan_tab.dart';
import 'package:assignment_1/screens/add_screen/widgets/restaurant_plan_tab.dart';
import 'package:assignment_1/screens/add_screen/widgets/travel_plan_tab.dart';
import 'package:assignment_1/screens/edit%20screens/edit_trip_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddPlanPage extends StatefulWidget {
  final String tripId;
  final String userId;
  final DateTime defaultDate;

  const AddPlanPage({
    super.key,
    required this.tripId,
    this.userId = 'demoUser',
    required this.defaultDate,
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
  late DateTime planDate;

  String destination = "Unknown";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    planDate = widget.defaultDate;
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

  Future<void> _fetchTripDetails(
      DocumentReference<Map<String, dynamic>> tripRef) async {
    final docSnap = await tripRef.get();
    if (docSnap.exists) {
      final data = docSnap.data();
      setState(() {
        destination = data?['destination'] ?? "Unknown";
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Padding(
            padding:
                const EdgeInsets.only(top: 55, left: 16, right: 16, bottom: 12),
            child: Column(
              children: [
                Center(
                  child: Text(
                    destination,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  "Add plan for ${DateFormat('EEEE, MMM d, yyyy').format(widget.defaultDate)}",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
          bottom: TabBar(
            dividerColor: Colors.black,
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.black,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.normal),
            tabs: const [
              Tab(text: 'Activity'),
              Tab(text: 'Travel'),
              Tab(text: 'Hotel'),
              Tab(text: 'Restaurant'),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : TabBarView(
              controller: _tabController,
              children: [
                ActivityPlansTab(
                  planDate: planDate,
                  ref: _activityRef,
                  onPLanSaved: () => Navigator.pop(context, true),
                ),
                TravelPlansTab(
                  ref: _travelRef,
                 planDate: planDate,
                  onPLanSaved: () => Navigator.pop(context, true),
                ),
                LodgingPlansTab(
                 planDate: planDate,
                  ref: _lodgingRef,
                  onPLanSaved: () => Navigator.pop(context, true),
                ),
                // RestaurantPlansTab(
                //   ref: _restaurantRef,
                //   planDate: planDate,
                //   onPLanSaved: () => Navigator.pop(context, true),
                // ),
              ],
            ),
    );
  }
}
