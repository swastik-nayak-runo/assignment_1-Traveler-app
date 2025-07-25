import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const CustomShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.black45,
      highlightColor: Colors.black26,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
