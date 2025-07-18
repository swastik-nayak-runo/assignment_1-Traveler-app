import 'package:assignment_1/screens/trips/trips.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:assignment_1/core/theme.dart';

import 'package:assignment_1/screens/onboarding/onboarding.dart';
import 'package:assignment_1/widgets/bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel Planner',
      theme: buildTheme(),
      home: MainShell(),
    );
  }
}

