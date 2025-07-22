import 'package:assignment_1/screens/add_screen/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditTripPage extends StatefulWidget {
  final String tripId;
  final String userId;

  const EditTripPage({
    super.key,
    required this.tripId,
    this.userId = 'demoUser',
  });

  @override
  State<EditTripPage> createState() => _EditTripPageState();
}

class _EditTripPageState extends State<EditTripPage> {
  final TextEditingController destinationController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  final _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchExistingData();
  }

  /// Fetch the existing trip details
  Future<void> _fetchExistingData() async {
    try {
      final doc = await _db
          .collection('users')
          .doc(widget.userId)
          .collection('trips')
          .doc(widget.tripId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          destinationController.text = data['destination'] ?? '';
          if (data['startDate'] != null) {
            startDate = (data['startDate'] as Timestamp).toDate();
          }
          if (data['endDate'] != null) {
            endDate = (data['endDate'] as Timestamp).toDate();
          }
          if (data['startTime'] != null) {
            final parts = data['startTime'].split(':');
            startTime = TimeOfDay(
                hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          }
          if (data['endTime'] != null) {
            final parts = data['endTime'].split(':');
            endTime = TimeOfDay(
                hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching trip data: $e");
    }
  }

  Future<void> _updateTrip() async {
    final dest = destinationController.text.trim();

    if (dest.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a destination')),
      );
      return;
    }

    if (startDate != null && endDate != null && endDate!.isBefore(startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    try {
      await _db
          .collection('users')
          .doc(widget.userId)
          .collection('trips')
          .doc(widget.tripId)
          .update({
        'destination': dest,
        'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
        'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
        'startTime': startTime != null
            ? '${startTime!.hour}:${startTime!.minute}'
            : null,
        'endTime':
        endTime != null ? '${endTime!.hour}:${endTime!.minute}' : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip updated successfully')),
      );
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
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => startDate = picked);
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? startDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => endDate = picked);
  }

  Future<void> pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: startTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => startTime = picked);
  }

  Future<void> pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: endTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => endTime = picked);
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
            const Center(
              child: Text(
                "Edit Trip",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            const Center(

              child: Text(
                "Update your trip details below",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: destinationController,
              hintText: "e.g., Paris, Hawaii, Japan",
              showLabel: true,
              labelText: 'Destination',
            ),
            const SizedBox(height: 16),

            const Text("Dates (optional)",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),

            OutlinedButton.icon(
              onPressed: pickStartDate,
              icon: const Icon(Icons.calendar_today,
                  size: 18, color: Colors.black),
              label: Text(
                startDate == null
                    ? "Start date"
                    : startDate!.toString().split(' ')[0],
                style: const TextStyle(color: Colors.black),
              ),
            ),

            if (startDate != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: pickEndDate,
                icon: const Icon(Icons.calendar_today,
                    size: 18, color: Colors.black),
                label: Text(
                  endDate == null
                      ? "End date"
                      : endDate!.toString().split(' ')[0],
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Time (optional)",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: pickStartTime,
                      icon: const Icon(Icons.access_time,
                          size: 18, color: Colors.black),
                      label: Text(
                        startTime == null
                            ? "Start time"
                            : startTime!.format(context),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: pickEndTime,
                      icon: const Icon(Icons.access_time,
                          size: 18, color: Colors.black),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _updateTrip,
                child: const Text(
                  "Update",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
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
