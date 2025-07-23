import 'package:assignment_1/screens/add_screen/add_page.dart';
import 'package:assignment_1/screens/profile%20page/profile_page.dart';
import 'package:assignment_1/screens/trips/trips.dart';
import 'package:flutter/material.dart';
import 'package:assignment_1/screens/homepage/home.dart';
import 'package:flutter/services.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.index = 0});

  final int index;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;

  final _pages = const [
    HomePage(),
    PlaceholderPage(label: 'Map'),
    TripsPage(),
    ProfilePage(userId: 'demoUser')
  ];

  @override
  void initState() {
    _index = widget.index;
    super.initState();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_index != 0) {
          setState(() => _index = 0); // go Home
          return false;               // block the pop
        }
        SystemNavigator.pop();
        return true;                  // allow default pop when already Home
      },
      child: Scaffold(
        body: _pages[_index],
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlanTripPage()),
            );
          },
          shape: const CircleBorder(),
          backgroundColor: Colors.black,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          color: Colors.white,
          child: SizedBox(
            height: 72,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 0, "Home"),
                _buildNavItem(Icons.map, 1, "Map"),
                const SizedBox(width: 40),
                _buildNavItem(Icons.luggage, 2, "Trips"),
                _buildNavItem(Icons.person, 3, "Profile"),
              ],
            ),
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
