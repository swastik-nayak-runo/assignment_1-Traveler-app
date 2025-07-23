import 'package:assignment_1/screens/add_screen/widgets/custom_text_field.dart';
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

  final String _demoUsrId = 'demoUser';
  final _db = FirebaseFirestore.instance;

  Future<void> _saveTrip() async {
    final dest = destinationController.text.trim();

    if (dest.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a destination')),
      );
      return;
    }

    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date')),
      );
      return;
    }

    if (endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an end date')),
      );
      return;
    }

    if (endDate!.isBefore(startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    try {
      await _db.collection('users').doc(_demoUsrId).collection('trips').add({
        'destination': dest,
        'startDate': Timestamp.fromDate(startDate!),
        'endDate': Timestamp.fromDate(endDate!),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip created successfully')),
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
                "Plan a new trip",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Add the destination and trip dates to create your itinerary.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // Destination Input
            CustomTextField(
              controller: destinationController,
              hintText: "e.g., Paris, Hawaii, Japan",
              showLabel: true,
              labelText: 'Destination*',
            ),

            const SizedBox(height: 16),
            const Text("Dates*", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Start Date Button
                OutlinedButton.icon(
                  onPressed: pickStartDate,
                  icon: const Icon(Icons.calendar_today,
                      size: 18, color: Colors.black),
                  label: Text(
                    startDate == null
                        ? "Select start date"
                        : startDate!.toString().split(' ')[0],
                    style: const TextStyle(color: Colors.black),
                  ),
                ),

                const SizedBox(height: 16),
                // End Date Button
                OutlinedButton.icon(
                  onPressed: pickEndDate,
                  icon: const Icon(Icons.calendar_today,
                      size: 18, color: Colors.black),
                  label: Text(
                    endDate == null
                        ? "Select end date"
                        : endDate!.toString().split(' ')[0],
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
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
                onPressed: _saveTrip,
                child: const Text(
                  "Save",
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
