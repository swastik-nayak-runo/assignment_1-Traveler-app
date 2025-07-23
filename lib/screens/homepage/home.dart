import 'package:assignment_1/screens/homepage/widgets/your_upcoming_plans.dart';
import 'package:assignment_1/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:assignment_1/screens/homepage/widgets/category_grid.dart';
import 'package:assignment_1/screens/homepage/widgets/home_header.dart';
import 'package:assignment_1/screens/homepage/widgets/large_destination.dart';
import 'package:assignment_1/screens/homepage/widgets/search_field.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: HomeHeader()),
            SliverToBoxAdapter(child: SearchField()),
            SliverToBoxAdapter(child: CategoryGrid()),

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
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => MainShell(index: 2,))
                      ),
                      child: const Text(
                        'See All',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: UpcomingTripsList()),

            // advertisement
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              sliver: SliverToBoxAdapter(
                child:    Text(
                  'Nearby Destination',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: LargeDestinationCard(
                  title: 'Charminar',
                  description:
                  'One of the 7 wonders of the world, famous mausoleum in Agra.',
                  location: 'Agra, India',
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      ),
    );
  }
}


