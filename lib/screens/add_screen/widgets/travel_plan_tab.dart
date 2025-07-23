import 'package:assignment_1/screens/add_screen/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TravelPlansTab extends StatefulWidget {
  final CollectionReference<Map<String, dynamic>> ref;
  final VoidCallback? onPLanSaved;

  const TravelPlansTab({required this.ref, this.onPLanSaved});

  @override
  State<TravelPlansTab> createState() => TravelPlansTabState();
}

class TravelPlansTabState extends State<TravelPlansTab> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController seatController = TextEditingController();
  final TextEditingController sourceController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

  String modeOfTravel = "Flight"; // default selection
  DateTime? departureDate;
  DateTime? arrivalDate;
  TimeOfDay? departureTime;
  TimeOfDay? arrivalTime;

  Future<void> pickDepartureDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => departureDate = picked);
  }

  Future<void> pickArrivalDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => arrivalDate = picked);
  }

  Future<void> pickDepartureTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => departureTime = picked);
  }

  Future<void> pickArrivalTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => arrivalTime = picked);
  }

  Future<void> saveTravelPlan() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Travel name is required")),
      );
      return;
    }

    try {
      await widget.ref.add({
        'modeOfTravel': modeOfTravel,
        'name': nameController.text.trim(),
        'number': numberController.text.trim().isNotEmpty
            ? numberController.text.trim()
            : null,
        'seat': seatController.text.trim().isNotEmpty
            ? seatController.text.trim()
            : null,
        'source': sourceController.text.trim().isNotEmpty
            ? sourceController.text.trim()
            : null,
        'destination': destinationController.text.trim().isNotEmpty
            ? destinationController.text.trim()
            : null,
        'departureDate':
            departureDate != null ? Timestamp.fromDate(departureDate!) : null,
        'departureTime': departureTime != null
            ? '${departureTime!.hour}:${departureTime!.minute}'
            : null,
        'arrivalDate':
            arrivalDate != null ? Timestamp.fromDate(arrivalDate!) : null,
        'arrivalTime': arrivalTime != null
            ? '${arrivalTime!.hour}:${arrivalTime!.minute}'
            : null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Travel Plan added successfully")),
      );

      _formKey.currentState?.reset();
      setState(() {
        modeOfTravel = "Flight";
        departureDate = null;
        arrivalDate = null;
        departureTime = null;
        arrivalTime = null;
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
            SizedBox(height: 5,),
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
              items: const [
                DropdownMenuItem(value: "Flight", child: Text("Flight")),
                DropdownMenuItem(value: "Train", child: Text("Train")),
              ],
              onChanged: (val) => setState(() => modeOfTravel = val!),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: nameController,
              hintText: 'e.g., Air India 101',
              showLabel: true,
              labelText: 'Name of Flight/Train*',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: numberController,
              hintText: 'Flight/Train number (optional)',
              showLabel: true,
              labelText: 'Number (optional)',
            ),
            const SizedBox(height: 16),
            const Text("Departure (optional)"),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickDepartureDate,
                    child: Text(
                      departureDate == null
                          ? "Departure Date"
                          : departureDate!.toString().split(' ')[0],
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickDepartureTime,
                    child: Text(
                      departureTime == null
                          ? "Departure Time"
                          : departureTime!.format(context),
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: sourceController,
              hintText: 'Source Station / Airport (optional)',
              showLabel: true,
              labelText: 'Source (optional)',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: seatController,
              hintText: 'Seat Number (optional)',
              showLabel: true,
              labelText: 'Seat Number (optional)',
            ),
            const SizedBox(height: 16),
            const Text("Arrival (optional)"),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickArrivalDate,
                    child: Text(
                      arrivalDate == null
                          ? "Arrival Date"
                          : arrivalDate!.toString().split(' ')[0],
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickArrivalTime,
                    child: Text(
                      arrivalTime == null
                          ? "Arrival Time"
                          : arrivalTime!.format(context),
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: destinationController,
              hintText: 'Destination Station / Airport (optional)',
              showLabel: true,
              labelText: 'Destination (optional)',
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
