import 'package:assignment_1/widgets/shimmer_list.dart';
import 'package:flutter/material.dart';
class LoadingTabs extends StatelessWidget {
  final TabController controller;

  const LoadingTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        ShimmerList(itemCount: 3, itemHeight: 92),
        ShimmerList(itemCount: 3, itemHeight: 92),
        ShimmerList(itemCount: 3, itemHeight: 92),
      ],
    );
  }
}
