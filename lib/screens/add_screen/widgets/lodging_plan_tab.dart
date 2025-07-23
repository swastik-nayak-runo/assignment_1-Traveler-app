import 'package:assignment_1/screens/add_screen/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LodgingPlansTab extends StatefulWidget {
  final CollectionReference<Map<String, dynamic>> ref;
  final VoidCallback? onPLanSaved;

  const LodgingPlansTab({required this.ref, this.onPLanSaved});

  @override
  State<LodgingPlansTab> createState() => LodgingPlansTabState();
}

class LodgingPlansTabState extends State<LodgingPlansTab> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController lodgingNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  DateTime? checkInDate;
  TimeOfDay? checkInTime;
  DateTime? checkOutDate;
  TimeOfDay? checkOutTime;

  // Pickers
  Future<void> pickCheckInDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => checkInDate = picked);
  }

  Future<void> pickCheckOutDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: checkInDate ?? DateTime.now(),
      firstDate: checkInDate ?? DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => checkOutDate = picked);
  }

  Future<void> pickCheckInTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => checkInTime = picked);
  }

  Future<void> pickCheckOutTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => checkOutTime = picked);
  }

  // Save Lodging Data
  Future<void> saveLodging() async {
    if (checkInDate == null || checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Check-in and check-out dates are required")),
      );
      return;
    }

    try {
      await widget.ref.add({
        'lodgingName': lodgingNameController.text.trim().isNotEmpty
            ? lodgingNameController.text.trim()
            : null,
        'address': addressController.text.trim().isNotEmpty
            ? addressController.text.trim()
            : null,
        'phone': phoneController.text.trim().isNotEmpty
            ? phoneController.text.trim()
            : null,
        'email': emailController.text.trim().isNotEmpty
            ? emailController.text.trim()
            : null,
        'checkInDate': Timestamp.fromDate(checkInDate!),
        'checkOutDate': Timestamp.fromDate(checkOutDate!),
        'checkInTime': checkInTime != null
            ? '${checkInTime!.hour}:${checkInTime!.minute}'
            : null,
        'checkOutTime': checkOutTime != null
            ? '${checkOutTime!.hour}:${checkOutTime!.minute}'
            : null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lodging Plan added successfully")),
      );

      _formKey.currentState?.reset();
      setState(() {
        checkInDate = null;
        checkOutDate = null;
        checkInTime = null;
        checkOutTime = null;
      });

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
            CustomTextField(
              controller: lodgingNameController,
              hintText: 'Hotel / Airbnb name',
              showLabel: true,
              labelText: 'Lodging Name (optional)',
            ),
            const SizedBox(height: 16),
            const Text("Check-in*"),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickCheckInDate,
                    child: Text(
                      checkInDate == null
                          ? "Check-in Date"
                          : checkInDate!.toString().split(' ')[0],
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickCheckInTime,
                    child: Text(
                      checkInTime == null
                          ? "Check-in Time"
                          : checkInTime!.format(context),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Check-out*"),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickCheckOutDate,
                    child: Text(
                      checkOutDate == null
                          ? "Check-out Date"
                          : checkOutDate!.toString().split(' ')[0],
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickCheckOutTime,
                    child: Text(
                      checkOutTime == null
                          ? "Check-out Time"
                          : checkOutTime!.format(context),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: addressController,
              hintText: 'Type the lodging address here',
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
                onPressed: saveLodging,
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
