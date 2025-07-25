import 'package:assignment_1/screens/add_screen/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivityPlansTab extends StatefulWidget {
  final CollectionReference<Map<String, dynamic>> ref;
  final DateTime planDate;
  final VoidCallback? onPLanSaved;

  const ActivityPlansTab({
    super.key,
    required this.ref,
    this.onPLanSaved, required this.planDate,
  });

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

  TimeOfDay? startTime;
  TimeOfDay? endTime;

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

    if (endTime == null || startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both start time and finish time")),
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
        'planDate': Timestamp.fromDate(widget.planDate),
        'startTime': '${startTime!.hour}:${startTime!.minute}',
        'endTime': '${endTime!.hour}:${endTime!.minute}',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Activity Plan added successfully")),
      );

      _formKey.currentState?.reset();
      setState(() {
        startTime = null;
        endTime = null;
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
              controller: eventNameController,
              hintText: 'e.g., Meeting, Sight Seeing',
              showLabel: true,
              labelText: 'Event Name*',
            ),
            const SizedBox(height: 16),
            const Text("Start and Finish Tine*", style: TextStyle(fontWeight: FontWeight.bold),),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickStartTime,
                    child: Text(
                      startTime == null
                          ? "Start Time"
                          : startTime!.format(context),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(width: 8,),
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickEndTime,
                    child: Text(
                      endTime == null ? "End Time" : endTime!.format(context),
                      style: const TextStyle(color: Colors.black),
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
            const SizedBox(
              height: 40,
            ),
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
