import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    print(widget.tripId);
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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          automaticallyImplyLeading: false, // removes default back button
          backgroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 12),
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

                if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                  return const Text("Plan your trip",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400));
                }

                final data = snapshot.data!.data();
                final destination = data?['destination'] ?? 'Unknown';

                return Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end ,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Plan your trip for",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                      ),
                      Spacer(),
                      Text(
                        destination,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
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
          _ActivityPlansTab(ref: _activityRef),
          _TravelPlansTab(ref: _travelRef),
          _LodgingPlansTab(ref: _lodgingRef),
          _RestaurantPlansTab(ref: _restaurantRef),
        ],
      ),
    );
  }
}
class _ActivityPlansTab extends StatefulWidget {
  final CollectionReference<Map<String, dynamic>> ref;
  const _ActivityPlansTab({required this.ref});

  @override
  State<_ActivityPlansTab> createState() => _ActivityPlansTabState();
}

class _ActivityPlansTabState extends State<_ActivityPlansTab> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController venueController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => startDate = picked);
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => endDate = picked);
  }

  Future<void> pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => startTime = picked);
  }

  Future<void> pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => endTime = picked);
  }

  Future<void> saveActivity() async {
    if (eventNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event name is required")),
      );
      return;
    }

    try {
      await widget.ref.add({
        'eventName': eventNameController.text.trim(),
        'venue': venueController.text.trim().isNotEmpty ? venueController.text.trim() : null,
        'phone': phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
        'email': emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
        'website': websiteController.text.trim().isNotEmpty ? websiteController.text.trim() : null,
        'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
        'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
        'startTime': startTime != null ? '${startTime!.hour}:${startTime!.minute}' : null,
        'endTime': endTime != null ? '${endTime!.hour}:${endTime!.minute}' : null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Activity added successfully")),
      );

      _formKey.currentState?.reset();
      setState(() {
        startDate = null;
        endDate = null;
        startTime = null;
        endTime = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: eventNameController,
              decoration: const InputDecoration(
                labelText: "Event Name *",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            const Text("Start (optional)"),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickStartDate,
                    child: Text(startDate == null
                        ? "Start Date"
                        : startDate!.toString().split(' ')[0]),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickStartTime,
                    child: Text(startTime == null
                        ? "Start Time"
                        : startTime!.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text("End (optional)"),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickEndDate,
                    child: Text(endDate == null
                        ? "End Date"
                        : endDate!.toString().split(' ')[0]),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickEndTime,
                    child: Text(endTime == null
                        ? "End Time"
                        : endTime!.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: venueController,
              decoration: const InputDecoration(
                labelText: "Venue / Address (optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone (optional)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email (optional)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: websiteController,
              decoration: const InputDecoration(
                labelText: "Website (optional)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveActivity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  "Save Activity",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _TravelPlansTab extends StatelessWidget {
  final CollectionReference<Map<String, dynamic>> ref;
  const _TravelPlansTab({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Placeholder(
      );
  }
}

class _LodgingPlansTab extends StatelessWidget {
  final CollectionReference<Map<String, dynamic>> ref;
  const _LodgingPlansTab({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}

class _RestaurantPlansTab extends StatelessWidget {
  final CollectionReference<Map<String, dynamic>> ref;
  const _RestaurantPlansTab({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
