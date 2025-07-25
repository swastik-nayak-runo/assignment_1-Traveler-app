import 'package:flutter/material.dart';
class ErrorTabs extends StatelessWidget {
  final String error;
  final TabController controller;

  const ErrorTabs({required this.error, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _ErrorState(error: error),
        _ErrorState(error: error),
        _ErrorState(error: error),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Error: $error",
          style: TextStyle(color: Colors.black)),
    );
  }
}
