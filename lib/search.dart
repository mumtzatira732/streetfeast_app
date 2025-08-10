import 'package:flutter/material.dart';
import '../restaurant.dart';        
import '../dummy_data.dart';       
import 'restaurant_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Restaurant> searchResults = [];

  @override
  void initState() {
    super.initState();
    searchResults = dummyRestaurants; 
  }

  void _search(String keyword) {
    final results = dummyRestaurants
        .where((restaurant) =>
            restaurant.name.toLowerCase().contains(keyword.toLowerCase()) ||
            restaurant.address.toLowerCase().contains(keyword.toLowerCase()) ||
            restaurant.description.toLowerCase().contains(keyword.toLowerCase()) ||
            restaurant.cuisines.any((cuisine) =>
                cuisine.toLowerCase().contains(keyword.toLowerCase())))
        .toList();

    setState(() {
      searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Search restaurant, address, food...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _search(_searchController.text),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: searchResults.isEmpty
                ? _buildNoResultWidget()
                : _buildResultList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultList() {
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final restaurant = searchResults[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 3,
          child: ListTile(
            leading: const Icon(Icons.restaurant, color: Colors.deepOrange),
            title: Text(restaurant.name),
            subtitle: Text(restaurant.address),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RestaurantDetailPage(restaurant: restaurant),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNoResultWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.orange),
          SizedBox(height: 20),
          Text(
            'No Result Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text("We can't find any item matching your search"),
        ],
      ),
    );
  }
}
