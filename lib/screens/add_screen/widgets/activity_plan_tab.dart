import 'package:assignment_1/screens/add_screen/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class ActivityPlansTab extends StatefulWidget {
  final CollectionReference<Map<String, dynamic>> ref;

  const ActivityPlansTab({required this.ref});

  @override
  State<ActivityPlansTab> createState() => ActivityPlansTabState();
}

class ActivityPlansTabState extends State<ActivityPlansTab> {
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
        'venue': venueController.text.trim().isNotEmpty
            ? venueController.text.trim()
            : null,
        'phone': phoneController.text.trim().isNotEmpty
            ? phoneController.text.trim()
            : null,
        'email': emailController.text.trim().isNotEmpty
            ? emailController.text.trim()
            : null,
        'website': websiteController.text.trim().isNotEmpty
            ? websiteController.text.trim()
            : null,
        'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
        'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
        'startTime': startTime != null
            ? '${startTime!.hour}:${startTime!.minute}'
            : null,
        'endTime':
        endTime != null ? '${endTime!.hour}:${endTime!.minute}' : null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Activity Plan added successfully")),
      );

      _formKey.currentState?.reset();
      setState(() {
        startDate = null;
        endDate = null;
        startTime = null;
        endTime = null;
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
              controller: eventNameController,
              hintText: 'e.g., Meeting, Sight Seeing',
              showLabel: true,
              labelText: 'Event Name*',
            ),
            const SizedBox(height: 16),
            const Text("Start (optional)"),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickStartDate,
                    child: Text(
                      startDate == null
                          ? "Start Date"
                          : startDate!.toString().split(' ')[0],
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickStartTime,
                    child: Text(
                      startTime == null
                          ? "Start Time"
                          : startTime!.format(context),
                      style: TextStyle(color: Colors.black),
                    ),
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
                    child: Text(
                      endDate == null
                          ? "End Date"
                          : endDate!.toString().split(' ')[0],
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickEndTime,
                    child: Text(
                      endTime == null ? "End Time" : endTime!.format(context),
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: venueController,
              hintText: 'Type the venue / address here',
              labelText: 'Venue / Address (optional)',
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
              hintText: "Contact email",
              showLabel: true,
              labelText: 'Email (optional)',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: websiteController,
              hintText: "Preferred activity host website",
              showLabel: true,
              labelText: 'Website (optional)',
            ),
            SizedBox(height: 40,),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: saveActivity,
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