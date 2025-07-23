import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String userId;
  const ProfilePage({super.key, this.userId = 'demoUser'});

  @override
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: docRef.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text('Profile not found'));
          }

          final data = snap.data!.data()!;

          // --- Field extraction with fallbacks ---
          final firstName = (data['firstName'] ?? '').toString().trim();
          final lastName  = (data['lastName']  ?? '').toString().trim();
          final displayNameFallback =
          (data['displayName'] ?? '').toString().trim(); // optional

          String name = [firstName, lastName]
              .where((s) => s.isNotEmpty)
              .join(' ')
              .trim();
          if (name.isEmpty) name = displayNameFallback;
          if (name.isEmpty) name = 'Unnamed User';

          final email   = (data['email']   ?? '').toString().trim();
          final phone   = (data['phone']   ?? '').toString().trim();
          final address = (data['address'] ?? '').toString().trim();
          final bio     = (data['bio']     ?? '').toString().trim(); // optional
          final photoUrl = (data['photoUrl'] ?? '').toString().trim(); // optional

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ProfileAvatar(
                  photoUrl: photoUrl,
                  displayName: name,
                  radius: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                // Contact basics
                const SizedBox(height: 4),
                if (email.isNotEmpty)
                  Text(email,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(phone,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center),
                ],

                const SizedBox(height: 24),

                // Address card
                if (address.isNotEmpty)
                  _InfoCard(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    child: Text(
                      address,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),

                // About/bio card (optional)
                if (bio.isNotEmpty)
                  _InfoCard(
                    icon: Icons.info_outline,
                    label: 'About',
                    child: Text(
                      bio,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),

                // You can put buttons here: Edit Profile, Sign Out, etc.
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Circular avatar that falls back to initials when no photo.
class _ProfileAvatar extends StatelessWidget {
  final String photoUrl;
  final String displayName;
  final double radius;
  const _ProfileAvatar({
    required this.photoUrl,
    required this.displayName,
    this.radius = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(photoUrl),
        backgroundColor: Colors.grey.shade200,
      );
    }
    final initials = _initialsFor(displayName);
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.black87,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.6,
        ),
      ),
    );
  }

  String _initialsFor(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.characters.take(1).toString().toUpperCase();
    }
    final first = parts.first.characters.take(1).toString();
    final last  = parts.last.characters.take(1).toString();
    return (first + last).toUpperCase();
  }
}

/// Simple info card row with icon + label + child content.
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.black87),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
