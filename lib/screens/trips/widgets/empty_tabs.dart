import 'package:flutter/material.dart';
class EmptyTabs extends StatelessWidget {
  final String message;
  final TabController controller;

  const EmptyTabs({required this.message, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        EmptyState(message: message),
        EmptyState(message: message),
        EmptyState(message: message),

      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  final String message;

  const EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: TextStyle(color: Colors.black)),
    );
  }
}
