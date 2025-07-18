import 'package:flutter/material.dart';
import 'package:assignment_1/screens/onboarding/widgets/onboard_slide.dart';
import 'package:assignment_1/widgets/bottom_nav_bar.dart';

class OnboardingSwipePage extends StatefulWidget {
  const OnboardingSwipePage({super.key});

  @override
  State<OnboardingSwipePage> createState() => _OnboardingSwipePageState();
}

class _OnboardingSwipePageState extends State<OnboardingSwipePage> {
  final PageController _pageController = PageController();
  static const _numPages = 3;

  void _advance() {
    final current = (_pageController.page ?? 0).round();
    final next = current + 1;
    if (next < _numPages) {
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const PageScrollPhysics(), // normal swipe still works
        children: [
          OnboardSlide(
            imageUrl: 'https://images.unsplash.com/photo-1501785888041-af3ef285b470',
            title: 'Explore the\nUnlimited\nWorld!',
            subtitle:
            "A world full of wonders awaits you. With advanced features and the best recommendations, your dream trip is now easier, faster and smarter.",
            ctaLabel: 'Swipe To Continue',
            onSwipeComplete: _advance,
          ),
          OnboardSlide(
            imageUrl: 'https://images.unsplash.com/photo-1549880338-65ddcdfd017b',
            title: 'Plan With\nConfidence',
            subtitle: 'Compare flights, stays & tours in one place.',
            ctaLabel: 'Swipe To Continue',
            onSwipeComplete: _advance,
          ),
          OnboardSlide(
            imageUrl: 'https://images.unsplash.com/photo-1526772662000-3f88f10405ff',
            title: "Let's Get\nStarted",
            subtitle: 'Sign in and build your perfect itinerary.',
            ctaLabel: 'Swipe To Start',
            onSwipeComplete: _goToHome,
          ),
        ],
      ),
    );
  }
}
