import 'package:flutter/material.dart';

class SearchAndFilter extends StatelessWidget {
  final Function(String) onSearch;
  final Function(String) onCategorySelected;
  final Function(String) onSortBySelected;

  const SearchAndFilter({
    required this.onSearch,
    required this.onCategorySelected,
    required this.onSortBySelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search workers...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: onSearch,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip('All', onCategorySelected),
              _buildFilterChip('Plumber', onCategorySelected),
              _buildFilterChip('Electrician', onCategorySelected),
              _buildFilterChip('Mechanic', onCategorySelected),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DropdownButtonFormField<String>(
            value: 'None',
            decoration: InputDecoration(
              labelText: 'Sort by',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'None', child: Text('None')),
              DropdownMenuItem(value: 'Price: Low to High', child: Text('Price: Low to High')),
              DropdownMenuItem(value: 'Price: High to Low', child: Text('Price: High to Low')),
            ],
            onChanged: (value) => onSortBySelected(value!),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, Function(String) onSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        onSelected: (bool selected) => onSelected(label),
      ),
    );
  }
}
