import 'package:assignment_1/widgets/search_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CategoryGrid extends StatelessWidget {
  final List<CatItem> _items = const [
    CatItem(icon: Icons.hotel, label: 'Lodging'),
    CatItem(icon: Icons.restaurant_menu, label: 'Restaurants'),
    CatItem(icon: Icons.flight_takeoff, label: 'Aeroplane'),
    CatItem(icon: Icons.train, label: 'Train'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: GridView.builder(
        itemCount: _items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 1,
        ),
        itemBuilder: (_, i) => CatTile(item: _items[i]),
      ),
    );
  }
}

class CatItem {
  final IconData icon;
  final String label;

  const CatItem({required this.icon, required this.label});
}

class CatTile extends StatelessWidget {
  final CatItem item;
  const CatTile({super.key, required this.item});

  void _openCategory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DynamicSearchPage(category: item.label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Hero(
          tag: 'search-bar',
          child: Material(
            color: const Color(0xFF363535),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _openCategory(context),
              child: SizedBox(
                height: 70,
                width: 70,
                child: Icon(
                  item.icon,
                  size: 28,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.label,
          style: const TextStyle(color: Colors.black),
        ),
      ],
    );
  }
}

