import 'package:assignment_1/widgets/search_page.dart';
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const DynamicSearchPage(
              category: 'Restros, Lodgings, Travel Destinations',
            ),
          ),
        ),
        child: const Hero(
          tag: 'search-bar', // Hero tag
          child: Material(
            color: Colors.transparent, // Important for Hero to animate properly
            child: AbsorbPointer(
              child: TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText:
                  'Search for nearby Restros, Lodgings, Travel Destinations',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
