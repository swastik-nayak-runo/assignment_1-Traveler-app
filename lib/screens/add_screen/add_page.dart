import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlanTripPage extends StatefulWidget {
  const PlanTripPage({super.key});

  @override
  State<PlanTripPage> createState() => _PlanTripPageState();
}

class _PlanTripPageState extends State<PlanTripPage> {
  final TextEditingController destinationController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  final String _demoUsrId = 'demoUser';
  final _db = FirebaseFirestore.instance;

  Future<void> _saveTrip() async {
    final dest = destinationController.text.trim();

    if (dest.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a destination')),
      );
      return;
    }

    // Validate date range
    if (startDate != null && endDate != null && endDate!.isBefore(startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    try {
      await _db
          .collection('users')
          .doc(_demoUsrId)
          .collection('trips')
          .add({
        'destination': dest,
        'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
        'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
        'startTime': startTime != null ? '${startTime!.hour}:${startTime!.minute}' : null,
        'endTime': endTime != null ? '${endTime!.hour}:${endTime!.minute}' : null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip created successfully')),
      );

      destinationController.clear();
      setState(() {
        startDate = null;
        endDate = null;
        startTime = null;
        endTime = null;
      });
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => startDate = picked);
    }
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => endDate = picked);
    }
  }

  Future<void> pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => startTime = picked);
    }
  }

  Future<void> pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => endTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Row(
              children: [
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                const Text(
                  "Plan a new trip",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(flex: 2),
              ],
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Build an itinerary and map out your upcoming travel plans",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // Destination Input
            TextField(
              controller: destinationController,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                isDense: true,
                labelText: 'Destination',
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                hintText: "e.g., Paris, Hawaii, Japan",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text("Dates (optional)", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),

            // Start Date Button
            OutlinedButton.icon(
              onPressed: pickStartDate,
              icon: const Icon(Icons.calendar_today, size: 18, color: Colors.black),
              label: Text(
                startDate == null ? "Start date" : startDate!.toString().split(' ')[0],
                style: const TextStyle(color: Colors.black),
              ),
            ),

            // Show End Date & Time Inputs only if Start Date is selected
            if (startDate != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: pickEndDate,
                icon: const Icon(Icons.calendar_today, size: 18, color: Colors.black),
                label: Text(
                  endDate == null ? "End date" : endDate!.toString().split(' ')[0],
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Time (optional)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: pickStartTime,
                      icon: const Icon(Icons.access_time, size: 18, color: Colors.black),
                      label: Text(
                        startTime == null ? "Start time" : startTime!.format(context),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: pickEndTime,
                      icon: const Icon(Icons.access_time, size: 18, color: Colors.black),
                      label: Text(
                        endTime == null ? "End time" : endTime!.format(context),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _saveTrip,
                child: const Text(
                  "Save",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

}
