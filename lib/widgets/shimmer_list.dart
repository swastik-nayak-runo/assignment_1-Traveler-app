import 'package:assignment_1/widgets/custome_shimmer.dart';
import 'package:flutter/material.dart';

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double borderRadius;

  const ShimmerList({
    Key? key,
    this.itemCount = 3,
    this.itemHeight = 80,
    this.borderRadius = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => CustomShimmer(
        width: double.infinity,
        height: itemHeight,
        borderRadius: borderRadius,
      ),
    );
  }
}
