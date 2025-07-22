import 'package:assignment_1/screens/add_screen/widgets/activity_plan_tab.dart';
import 'package:assignment_1/screens/add_screen/widgets/custom_text_field.dart';
import 'package:assignment_1/screens/add_screen/widgets/lodging_plan_tab.dart';
import 'package:assignment_1/screens/add_screen/widgets/restaurant_plan_tab.dart';
import 'package:assignment_1/screens/add_screen/widgets/travel_plan_tab.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddPlanPage extends StatefulWidget {
  final String tripId;
  final String userId; // default: demoUser

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Expose these if child tabs need them (we'll wire up soon)
  CollectionReference<Map<String, dynamic>> get activityRef => _activityRef;

  CollectionReference<Map<String, dynamic>> get travelRef => _travelRef;

  CollectionReference<Map<String, dynamic>> get lodgingRef => _lodgingRef;

  CollectionReference<Map<String, dynamic>> get restaurantRef => _restaurantRef;

  @override
  Widget build(BuildContext context) {
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
            child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId)
                  .collection('trips')
                  .doc(widget.tripId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // ✅ Shimmer placeholder for loading
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 16,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 120,
                        height: 22,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  );
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    !snapshot.data!.exists) {
                  return const Text("Plan your trip",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w400));
                }

                final data = snapshot.data!.data();
                final destination = data?['destination'] ?? 'Unknown';

                final tsStart = data?['startDate'] as Timestamp?;
                final tsEnd = data?['endDate'] as Timestamp?;

                final startDt = tsStart?.toDate();
                final endDt = tsEnd?.toDate();

                final fmt = DateFormat('dd-MM-yyyy');
                final startLabel = startDt != null
                    ? fmt.format(startDt)
                    : 'Start date not set';
                final endLabel =
                    endDt != null ? fmt.format(endDt) : 'End date not set';

                return Padding(
                  padding: const EdgeInsets.only(top: 10.0),
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
                          Spacer(),
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
                          Text(
                        startLabel,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          const Text(
                            '→',
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            endLabel,
                            style: const TextStyle(color: Colors.black),
                          )
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.black,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
            tabs: const [
              Tab(text: 'Activity'),
              Tab(text: 'Travel'),
              Tab(text: 'Lodging'),
              Tab(text: 'Food'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ActivityPlansTab(ref: _activityRef),
          TravelPlansTab(ref: _travelRef),
          LodgingPlansTab(ref: _lodgingRef),
          RestaurantPlansTab(ref: _restaurantRef),
        ],
      ),
    );
  }
}
