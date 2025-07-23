import 'package:assignment_1/screens/add_screen/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RestaurantPlansTab extends StatefulWidget {
  final CollectionReference<Map<String, dynamic>> ref;
  final DateTime tripStartDate;
  final DateTime tripEndDate;
  final VoidCallback? onPLanSaved;

  const RestaurantPlansTab({
    super.key,
    required this.ref,
    required this.tripStartDate,
    required this.tripEndDate,
    this.onPLanSaved,
  });

  @override
  State<RestaurantPlansTab> createState() => RestaurantPlansTabState();
}

class RestaurantPlansTabState extends State<RestaurantPlansTab> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController restaurantNameController =
      TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String? selectedMealType;
  DateTime? reservationDate;
  TimeOfDay? reservationTime;
  bool confirmation = false;

  // Pick Date
  Future<void> pickReservationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.tripStartDate.isAfter(DateTime.now())
          ? widget.tripStartDate
          : DateTime.now(),
      firstDate: widget.tripStartDate,
      lastDate: widget.tripEndDate,
    );
    if (picked != null) {
      setState(() => reservationDate = picked);
    }
  }

  // Pick Time
  Future<void> pickReservationTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => reservationTime = picked);
  }

  // Save Plan
  Future<void> saveRestaurantPlan() async {
    if (restaurantNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the restaurant name")),
      );
      return;
    }
    if (selectedMealType.toString().trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select the meal type")),
      );
      return;
    }
    if (reservationDate == null || reservationTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please select both reservation date and time")),
      );
      return;
    }

    // **Validate Date Range**
    if (reservationDate!.isBefore(widget.tripStartDate) ||
        reservationDate!.isAfter(widget.tripEndDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Reservation date must be between ${widget.tripStartDate.toString().split(' ')[0]} and ${widget.tripEndDate.toString().split(' ')[0]}",
          ),
        ),
      );
      return;
    }

    // **Calculate End Time based on Meal Type**
    final startDateTime = DateTime(
      reservationDate!.year,
      reservationDate!.month,
      reservationDate!.day,
      reservationTime!.hour,
      reservationTime!.minute,
    );

    Duration duration;
    if (selectedMealType == "Breakfast" || selectedMealType == "Snacks") {
      duration = const Duration(minutes: 30);
    } else {
      duration = const Duration(hours: 1);
    }

    final endDateTime = startDateTime.add(duration);

    // Save to Firestore
    try {
      await widget.ref.add({
        'restaurantName': restaurantNameController.text.trim(),
        'mealType': selectedMealType.toString().trim(),
        'date': Timestamp.fromDate(reservationDate!),
        'startTime': '${reservationTime!.hour}:${reservationTime!.minute}',
        'endTime': '${endDateTime.hour}:${endDateTime.minute}',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Restaurant plan added successfully")),
      );

      Navigator.of(context).pop(true);
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
            // Restaurant Name (Required)
            CustomTextField(
              controller: restaurantNameController,
              hintText: 'e.g., Barbeque Nation, Olive Bistro',
              showLabel: true,
              labelText: 'Restaurant Name*',
            ),
            const SizedBox(height: 16),

            // Meal Type Dropdown (Required)
            const Text(
              "Meal Type*",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedMealType,
              items: ['Breakfast', 'Lunch', 'Snacks', 'Dinner']
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => selectedMealType = val),
              validator: (val) =>
                  val == null ? 'Please select meal type' : null,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.black, // Black border when not focused
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.black, // Black border when focused
                      width: 1.5,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  fillColor: Colors.transparent),
              dropdownColor: Color(0xFFE4EDF2),
            ),
            const SizedBox(height: 16),

            // Reservation Date & Time (Required)
            const Text("Reservation Date & Time*",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickReservationDate,
                    child: Text(
                      reservationDate == null
                          ? "Select Date"
                          : reservationDate!.toString().split(' ')[0],
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickReservationTime,
                    child: Text(
                      reservationTime == null
                          ? "Select Time"
                          : reservationTime!.format(context),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),

            // Optional Fields
            Row(
              children: [
                Checkbox(
                  value: confirmation,
                  onChanged: (val) {
                    setState(() {
                      confirmation = !confirmation;
                    });
                  },
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      confirmation = !confirmation;
                    });
                  },
                  child: const Text(
                    "Reservation Confirmed (optional)",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: addressController,
              hintText: 'Type restaurant address here',
              labelText: 'Address (optional)',
              showLabel: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: phoneController,
              hintText: "Contact phone number",
              showLabel: true,
              labelText: 'Phone Number (optional)',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: emailController,
              hintText: "Contact email address",
              showLabel: true,
              labelText: 'Email (optional)',
            ),
            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  if (reservationDate == null || reservationTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text("Please select reservation date and time")),
                    );
                    return;
                  }
                  saveRestaurantPlan();
                },
                child: const Text(
                  "Save Plan",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
