import 'package:assignment_1/screens/add_screen/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RestaurantPlansTab extends StatefulWidget {
  final CollectionReference<Map<String, dynamic>> ref;

  const RestaurantPlansTab({required this.ref});

  @override
  State<RestaurantPlansTab> createState() => RestaurantPlansTabState();
}

class RestaurantPlansTabState extends State<RestaurantPlansTab> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController restaurantNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  DateTime? reservationDate;
  TimeOfDay? reservationTime;
  bool confirmation = false;

  // Pickers
  Future<void> pickReservationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => reservationDate = picked);
  }

  Future<void> pickReservationTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => reservationTime = picked);
  }

  // Save Restaurant Plan
  Future<void> saveRestaurantPlan() async {
    if (restaurantNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Restaurant name is required")),
      );
      return;
    }

    try {
      await widget.ref.add({
        'restaurantName': restaurantNameController.text.trim(),
        'date': reservationDate != null ? Timestamp.fromDate(reservationDate!) : null,
        'time': reservationTime != null
            ? '${reservationTime!.hour}:${reservationTime!.minute}'
            : null,
        'confirmation': confirmation,
        'address': addressController.text.trim().isNotEmpty
            ? addressController.text.trim()
            : null,
        'phone': phoneController.text.trim().isNotEmpty
            ? phoneController.text.trim()
            : null,
        'email': emailController.text.trim().isNotEmpty
            ? emailController.text.trim()
            : null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Restaurant plan added successfully")),
      );

      _formKey.currentState?.reset();
      setState(() {
        reservationDate = null;
        reservationTime = null;
        confirmation = false;
      });

      Navigator.of(context).pop();
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
            CustomTextField(
              controller: restaurantNameController,
              hintText: 'e.g., Barbeque Nation, Olive Bistro',
              showLabel: true,
              labelText: 'Restaurant Name*',
            ),
            const SizedBox(height: 16),

            const Text("Reservation (optional)"),
            SizedBox(height: 12,),
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

            Row(
              children: [
                Checkbox(
                  value: confirmation,
                  onChanged: (val) {
                    setState(() => confirmation = val ?? false);
                  },
                ),
                const Text("Reservation Confirmed (optional)"),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: saveRestaurantPlan,
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
