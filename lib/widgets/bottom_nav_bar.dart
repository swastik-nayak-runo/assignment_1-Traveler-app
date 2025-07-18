import 'package:assignment_1/screens/add_screen/add_page.dart';
import 'package:assignment_1/screens/trips/trips.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:assignment_1/screens/homepage/home.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [
    HomePage(),
    PlaceholderPage(label: 'Map'),
    TripsPage(),
    PlaceholderPage(label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PlanTripPage()),
          );
        },
        shape: const CircleBorder(),
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // 👈 Creates the notch
        notchMargin: 8, // space around the FAB
        color: Colors.white,
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 0, "Home"),
              _buildNavItem(Icons.map, 1, "Map"),
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(Icons.luggage, 2, "Trips"),
              _buildNavItem(Icons.person, 3, "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    final isSelected = _index == index;
    return GestureDetector(
      onTap: () => setState(() => _index = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? Colors.black : Colors.grey),
          Text(label, style: TextStyle(color: isSelected ? Colors.black : Colors.grey)),
        ],
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String label;

  const PlaceholderPage({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label, style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}
