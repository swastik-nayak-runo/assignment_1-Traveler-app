import 'package:assignment_1/widgets/custome_shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  Future<Map<String, dynamic>?> getUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc('demoUser')
        .get();
    if (doc.exists) return doc.data();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const HomeHeaderShimmer(); // <-- Use shimmer
        }

        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text("User data not found"),
          );
        }

        final userData = snapshot.data!;
        final firstName = userData['firstName'] ?? '';
        final lastName = userData['lastName'] ?? '';
        final address = userData['address'] ?? '';

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$firstName $lastName',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 16, color: Colors.grey.shade700),
                        const SizedBox(width: 4),
                        SizedBox(
                          child: Text(
                            address,
                            style: TextStyle(color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down,
                            size: 18, color: Colors.grey.shade700),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                  icon: const Icon(Icons.notifications, size: 30),
                  onPressed: () {})
            ],
          ),
        );
      },
    );
  }
}

class HomeHeaderShimmer extends StatelessWidget {
  const HomeHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 CustomShimmer(width: 120, height: 18), // Name shimmer
                 SizedBox(height: 8),
                Row(
                  children:  [
                    CustomShimmer(width: 16, height: 16, borderRadius: 4),
                    SizedBox(width: 8),
                    CustomShimmer(width: 100, height: 14), // Address shimmer
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications, size: 30),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}
