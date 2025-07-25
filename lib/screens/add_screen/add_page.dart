import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlanTripPage extends StatefulWidget {
  const PlanTripPage({super.key});

  @override
  State<PlanTripPage> createState() => _PlanTripPageState();
}

class _PlanTripPageState extends State<PlanTripPage> {

  DateTime? startDate;
  DateTime? endDate;
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  final String _demoUsrId = 'demoUser';
  final _db = FirebaseFirestore.instance;
  String selectedDest = "";
  bool selected = false;
  List<Map<String, dynamic>> allCities = [];
  bool loadingCities = true;

  double? selectedLat;
  double? selectedLon;

  @override
  void initState() {
    super.initState();
    loadCities();
  }

  Future<void> loadCities() async {
    final String jsonString = await rootBundle.loadString('assets/places.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final List elements = jsonData['elements'];

    setState(() {
      allCities = elements
          .map<Map<String, dynamic>>((e) {
            return {
              'name': e['tags']?['name'] ?? '',
              'lat': e['lat'],
              'lon': e['lon'],
            };
          })
          .where((e) => e['name'].toString().isNotEmpty)
          .toList();

      loadingCities = false;
    });
  }

  List<Map<String, dynamic>> filterCities(String query) {
    return allCities
        .where((e) =>
            e['name'].toString().toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<void> _saveTrip() async {
    final dest = selectedDest;

    if (dest.isEmpty || selectedLat == null || selectedLon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid destination')),
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
      // Save to Firestore including lat/lon
      await _db.collection('users').doc(_demoUsrId).collection('trips').add({
        'destination': dest,
        'startDate': Timestamp.fromDate(startDate!),
        'endDate': Timestamp.fromDate(endDate!),
        'latitude': selectedLat,  // Add latitude to Firestore
        'longitude': selectedLon, // Add longitude to Firestore
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
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Plan a new trip",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(right: 16, left: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              /// 🔍 Destination Field with dropdown
              TypeAheadField<Map<String, dynamic>>(
                constraints: BoxConstraints(
                  maxHeight: 400
                ),
                suggestionsCallback: filterCities,
                itemBuilder: (context, suggestion) =>  ListTile(
                  hoverColor: Colors.black,
                  focusColor: const Color(0xFFE4EDF2),
                  tileColor: const Color(0xFFE4EDF2),
                  title: Text(
                    suggestion['name'],
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                hideOnEmpty: true,
                hideOnLoading: true,
                hideOnUnfocus: true,
                hideOnSelect: true,
                hideWithKeyboard: true,
                onSelected: (suggestion) {
                  setState(() {
                    selectedDest = suggestion['name'];
                    selectedLat = suggestion['lat'];
                    selectedLon = suggestion['lon'];
                    selected = true;
                  });
                  FocusScope.of(context).unfocus();
                  print("destination $selectedDest");
                },
                builder: (context, controller , focusNode) {
                  if (controller.text != selectedDest) {
                    controller.text = selectedDest;
                    focusNode.unfocus();
                  }
                  return TextField(
                    controller: controller,
                    cursorColor: Colors.black,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      fillColor: Colors.transparent,
                      isDense: true,
                      labelText: 'Destination*',
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      hintText: 'e.g. Paris, Goa',
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
                  );
                },
                decorationBuilder: (context, child) {
                  return Material(
                    color: const Color(0xFFE4EDF2),
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: child,
                  );
                },
              ),

              const SizedBox(height: 20),
              const Text("Dates*", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: pickStartDate,
                    icon: const Icon(Icons.calendar_today,
                        size: 18, color: Colors.black),
                    label: Text(
                      startDate == null
                          ? "Start Date"
                          : dateFormat.format(startDate!),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: pickEndDate,
                    icon: const Icon(Icons.calendar_today,
                        size: 18, color: Colors.black),
                    label: Text(
                      endDate == null ? "End Date" : dateFormat.format(endDate!),
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
      ),
    );
  }
}
