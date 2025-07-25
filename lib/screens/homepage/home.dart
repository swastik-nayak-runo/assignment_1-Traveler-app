import 'package:assignment_1/screens/homepage/widgets/your_upcoming_plans.dart';
import 'package:assignment_1/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:assignment_1/screens/homepage/widgets/home_header.dart';
import 'package:assignment_1/screens/homepage/widgets/large_destination.dart';

class HomePage extends StatelessWidget {
   const HomePage({super.key});


  @override
  Widget build(BuildContext context) {

    final List<Map<String, String>> destinations = [
      {
        'title': 'Charminar',
        'location': 'Hyderabad, India',
        'picUrl': "assets/images/charminar.png"
      },
      {
        'title': 'Taj Mahal',
        'location': 'Agra, India',
        'picUrl': "assets/images/taj mahal.png"
      },
      {
        'title': 'Jagannath Temple',
        'location': 'Puri, India',
        'picUrl': "assets/images/jagannath temple.png"
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: HomeHeader()),
            const SliverToBoxAdapter(
              child: Divider(
                thickness: 2,
                color: Colors.black,
              ),
            ),
            // upcoming trips
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Upcoming Trips',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => MainShell(
                                    index: 1,
                                  ))),
                      child: const Text(
                        'See All',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(vertical: 10),
              sliver:  SliverToBoxAdapter(
                child: UpcomingTripsList(),
              ),
            ),

            // advertisement
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Nearby Destination',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200, // Adjust based on card height
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: destinations.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final destination = destinations[index];
                    return LargeDestinationCard(
                      title: destination['title']!,
                      location: destination['location']!,
                      picUrl: destination['picUrl']!,
                    );
                  },
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
