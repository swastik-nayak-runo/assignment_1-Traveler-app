import 'package:assignment_1/widgets/custome_shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
          return const HomeHeaderShimmer();
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
        final now = DateTime.now();
        final formattedDate = DateFormat('EEE, MMM d').format(now);

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $firstName!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 16, color: Colors.grey.shade700),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            address,
                            style: const TextStyle(color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    )
                  ],
                ),
              ),
              const CircleAvatar(
                radius: 26,
                backgroundColor: Colors.black,
                child: Icon(Icons.person, color: Colors.white),
              ),

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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const  Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomShimmer(width: 100, height: 16), // Name shimmer
                SizedBox(height: 8),
                Row(
                  children: [
                    CustomShimmer(width: 16, height: 16, borderRadius: 4),
                    SizedBox(width: 6),
                    CustomShimmer(width: 120, height: 14), // Address shimmer
                  ],
                ),
                SizedBox(height: 8),
                CustomShimmer(width: 80, height: 12), // Date shimmer
              ],
            ),
          ),
          CustomShimmer(
            width: 52,
            height: 52,
            borderRadius: 26,
          ),
        ],
      ),
    );
  }
}
