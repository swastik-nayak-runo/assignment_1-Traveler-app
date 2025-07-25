import 'package:assignment_1/screens/add_screen/add_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LargeDestinationCard extends StatelessWidget {
  final String title;
  final String location;
  final String picUrl;

  const LargeDestinationCard({
    required this.title,
    required this.location,
    required this.picUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.6,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Colors.black,
              child: Image.asset(
                picUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w900),
                  ),
                  Text(
                    location,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PlanTripPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white70,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      elevation:5
                    ),
                    child: Text(
                      'Plan your Next Trip',
                      style: TextStyle(color: Colors.black),
                    ),

                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
