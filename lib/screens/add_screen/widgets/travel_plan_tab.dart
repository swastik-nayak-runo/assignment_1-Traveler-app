import 'package:assignment_1/screens/add_screen/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TravelPlansTab extends StatefulWidget {
  final CollectionReference<Map<String, dynamic>> ref;
  final DateTime planDate;
  final VoidCallback? onPLanSaved;

  const TravelPlansTab({
    required this.ref,
    this.onPLanSaved,
    required this.planDate,
  });

  @override
  State<TravelPlansTab> createState() => TravelPlansTabState();
}

class TravelPlansTabState extends State<TravelPlansTab> {
  final _formKey = GlobalKey<FormState>();


  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController seatController = TextEditingController();
  final TextEditingController stationController = TextEditingController();

  String modeOfTravel = "Flight";
  String journeyType = "Departure";
  TimeOfDay? time;


  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => time = picked);
  }

  Future<void> saveTravelPlan() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Travel name is required")),
      );
      return;
    }

    if (time == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar( SnackBar(content: Text("Select $journeyType time")));
      return;
    }

    try {
      await widget.ref.add({
        'modeOfTravel': modeOfTravel,
        'journeyType': journeyType,
        'name': nameController.text.trim(),
        'number': numberController.text.trim().isNotEmpty
            ? numberController.text.trim()
            : null,
        'seat': seatController.text.trim().isNotEmpty
            ? seatController.text.trim()
            : null,
        'station': stationController.text.trim().isNotEmpty
            ? stationController.text.trim()
            : null,
        'planDate': Timestamp.fromDate(widget.planDate),
        'time': '${time!.hour}:${time!.minute}',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Travel Plan added successfully")),
      );

      _formKey.currentState?.reset();
      setState(() {
        modeOfTravel = "Flight";
        time = null;
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
            const Text(
              "Mode of Travel*",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5,
            ),
            DropdownButtonFormField<String>(
              value: modeOfTravel,
              decoration: const InputDecoration(
                fillColor: Colors.transparent,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
              ),
              dropdownColor: Color(0xFFE4EDF2),
              items: const [
                DropdownMenuItem(value: "Flight", child: Text("Flight")),
                DropdownMenuItem(value: "Train", child: Text("Train")),
              ],
              onChanged: (val) => setState(() => modeOfTravel = val!),
            ),
            const SizedBox(height: 8),
            const Text(
              "Journey Type*",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5,
            ),
            DropdownButtonFormField<String>(
              value: journeyType,
              decoration: const InputDecoration(
                fillColor: Colors.transparent,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
              ),
              dropdownColor: Color(0xFFE4EDF2),
              items: const [
                DropdownMenuItem(value: "Departure", child: Text("Departure")),
                DropdownMenuItem(value: "Arrival", child: Text("Arrival")),
              ],
              onChanged: (val) => setState(() => journeyType = val!),
            ),
            const SizedBox(height: 8),
            Text(
              "${journeyType} Time*",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickTime,
                    child: Text(
                      time == null
                          ? "$journeyType Time"
                          : time!.format(context),
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            CustomTextField(
              controller: nameController,
              hintText: 'e.g., Air India 101',
              showLabel: true,
              labelText: 'Name of Flight/Train*',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: numberController,
              hintText: 'Flight/Train number',
              showLabel: true,
              labelText: 'Train Number (optional)',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: stationController,
              hintText: 'Station / Airport',
              showLabel: true,
              labelText: '$journeyType Station / Airport (optional)',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: seatController,
              hintText: 'Seat Number',
              showLabel: true,
              labelText: 'Seat Number (optional)',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: saveTravelPlan,
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
