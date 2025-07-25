import 'package:assignment_1/screens/add_screen/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LodgingPlansTab extends StatefulWidget {
  final CollectionReference<Map<String, dynamic>> ref;
  final VoidCallback? onPLanSaved;
  final DateTime planDate;

  const LodgingPlansTab({
    required this.ref,
    this.onPLanSaved,
    required this.planDate,
  });

  @override
  State<LodgingPlansTab> createState() => LodgingPlansTabState();
}

class LodgingPlansTabState extends State<LodgingPlansTab> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  final TextEditingController lodgingNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String checkType = "Check-in";
  TimeOfDay? time;


  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => time = picked);
  }

  // Save Lodging Data
  Future<void> saveLodging() async {
    if (lodgingNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter Lodging Name")),
      );
      return;
    }

    if (time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
            content: Text("$checkType time is required")),
      );
      return;
    }


    try {
      await widget.ref.add({
        'lodgingName': lodgingNameController.text.trim(),
        'address': addressController.text.trim().isNotEmpty
            ? addressController.text.trim()
            : null,
        'phone': phoneController.text.trim().isNotEmpty
            ? phoneController.text.trim()
            : null,
        'email': emailController.text.trim().isNotEmpty
            ? emailController.text.trim()
            : null,
        'planDate': Timestamp.fromDate(widget.planDate),
        'time': '${time!.hour}:${time!.minute}',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lodging Plan added successfully")),
      );

      _formKey.currentState?.reset();
      setState(() {
        time  = null;
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
              labelText: 'Lodging Name*',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: checkType,
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
                DropdownMenuItem(value: "Check-in", child: Text("Check-in")),
                DropdownMenuItem(value: "Check-out", child: Text("Check-out")),
              ],
              onChanged: (val) => setState(() => checkType = val!),
            ),
             SizedBox(height: 16,),
             Text(
              "$checkType time*",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
             children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickTime,
                    child: Text(
                      time == null
                          ? "$checkType Time"
                          : time!.format(context),
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
