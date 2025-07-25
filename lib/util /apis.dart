import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<List<Map<String, dynamic>>> loadCitiesFromJsonAsset() async {
  final String jsonString = await rootBundle.loadString('assets/places.json');
  final Map<String, dynamic> jsonData = json.decode(jsonString);

  if (!jsonData.containsKey('elements')) {
    throw Exception("Invalid JSON format: Missing 'elements' key");
  }

  final List elements = jsonData['elements'];

  return elements.map<Map<String, dynamic>>((e) {
    return {
      'name': e['tags']?['name'] ?? '',
      'lat': e['lat'],
      'lon': e['lon'],
    };
  }).where((e) => e['name'] != null && e['name']!.isNotEmpty).toList();
}
