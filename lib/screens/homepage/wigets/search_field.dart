import 'package:flutter/material.dart';
class SearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.menu, size: 25),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
