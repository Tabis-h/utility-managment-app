import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utiliwise/src/search_and_filter.dart'; // Import the new file
import 'package:utiliwise/src/worker_card.dart'; // Import the WorkerCard widget

class UserHomeScreen extends ConsumerStatefulWidget {
  const UserHomeScreen({super.key});

  @override
  ConsumerState<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends ConsumerState<UserHomeScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortBy = 'None';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchAndFilter(
          onSearch: (query) => setState(() => _searchQuery = query),
          onCategorySelected: (category) => setState(() => _selectedCategory = category),
          onSortBySelected: (sortBy) => setState(() => _sortBy = sortBy),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('workers')
                .where('isAvailable', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }

              final workers = snapshot.data!.docs;

              if (workers.isEmpty) {
                return const Center(
                  child: Text(
                    'No workers available at the moment',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              // Apply search, category filter, and sorting
              final filteredWorkers = workers.where((worker) {
                final name = worker['name'].toString().toLowerCase();
                final workType = worker['workType'].toString().toLowerCase();
                final matchesSearch = name.contains(_searchQuery.toLowerCase()) ||
                    workType.contains(_searchQuery.toLowerCase());
                final matchesCategory = _selectedCategory == 'All' ||
                    workType == _selectedCategory.toLowerCase();
                return matchesSearch && matchesCategory;
              }).toList();

              // Sort by price
              if (_sortBy == 'Price: Low to High') {
                filteredWorkers.sort((a, b) => a['workPrice'].compareTo(b['workPrice']));
              } else if (_sortBy == 'Price: High to Low') {
                filteredWorkers.sort((a, b) => b['workPrice'].compareTo(a['workPrice']));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredWorkers.length,
                itemBuilder: (context, index) {
                  final worker = filteredWorkers[index];
                  return WorkerCard(
                    workerId: worker.id,
                    name: worker['name'],
                    workPrice: worker['workPrice'],
                    workType: worker['workType'],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
