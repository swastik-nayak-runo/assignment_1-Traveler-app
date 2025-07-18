import 'package:flutter/material.dart';

class OnboardSlide extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback? onSwipeComplete; // fired when user swipes CTA knob far enough

  const OnboardSlide({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    this.onSwipeComplete,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(imageUrl, fit: BoxFit.cover),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(.0),
                Colors.black.withOpacity(.8),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24, size.height * .15, 24, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  height: 1.35,
                ),
              ),
              const Spacer(),
              Center(
                child: _SwipeButton(
                  label: ctaLabel,
                  onSwipeComplete: onSwipeComplete,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SwipeButton extends StatefulWidget {
  final String label;
  final VoidCallback? onSwipeComplete; // called when drag threshold reached

  const _SwipeButton({
    required this.label,
    this.onSwipeComplete,
  });

  @override
  State<_SwipeButton> createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<_SwipeButton> {
  double _drag = 0; // 0..1

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 48; // match outer padding
    const height = 56.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: (details) {
        setState(() {
          _drag = (_drag + (details.primaryDelta ?? 0) / width).clamp(0, 1);
        });
      },
      onHorizontalDragEnd: (_) {
        // fire when user drags far enough (adjust threshold as desired)
        if (_drag >= 0.15) {
          widget.onSwipeComplete?.call();
        }
        setState(() => _drag = 0);
      },
      child: Stack(
        children: [
          // Track
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.25),
              borderRadius: BorderRadius.circular(height / 2),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Knob
          Positioned(
            left: _drag * (width - height),
            child: Container(
              width: height,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(height / 2),
              ),
              child: const Icon(Icons.arrow_forward_ios, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
