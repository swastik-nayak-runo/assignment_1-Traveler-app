import 'package:flutter/material.dart';

class DynamicSearchPage extends StatelessWidget {
  final String category;
  const DynamicSearchPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Hero(
          tag: 'search-bar',
          child: Material(
            color: Colors.transparent,
            child: TextField(
              autofocus: true,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintText: 'Search for nearby $category',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
