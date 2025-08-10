import 'package:flutter/material.dart';
import 'restaurant_detail_page.dart';
import 'dummy_data.dart';
import 'restaurant.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Restaurant> filteredRestaurants = dummyRestaurants;

  void _search(String keyword) {
    setState(() {
      filteredRestaurants = dummyRestaurants.where((restaurant) {
        final lowerKeyword = keyword.toLowerCase();
        return restaurant.name.toLowerCase().contains(lowerKeyword) ||
            restaurant.address.toLowerCase().contains(lowerKeyword) ||
            restaurant.description.toLowerCase().contains(lowerKeyword) ||
            restaurant.cuisines.any(
              (cuisine) => cuisine.toLowerCase().contains(lowerKeyword),
            );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('STREETFEAST MELAKA'),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Search by name, address, cuisine...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
          Expanded(
            child: filteredRestaurants.isEmpty
                ? _buildNoResultWidget()
                : Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GridView.builder(
                      itemCount: filteredRestaurants.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2 / 2.6,
                      ),
                      itemBuilder: (context, index) {
                        final restaurant = filteredRestaurants[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RestaurantDetailPage(restaurant: restaurant),
                              ),
                            );
                          },
                          child: RestaurantCard(
                            imageUrl: restaurant.imageUrl,
                            name: restaurant.name,
                            location: restaurant.address,
                            cuisines: restaurant.cuisines.join(', '),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
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
          Text("We couldn't find anything that matches your search."),
        ],
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String location;
  final String cuisines;

  const RestaurantCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.location,
    required this.cuisines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
                const SizedBox(height: 4),
                Text(location, style: const TextStyle(fontSize: 12), maxLines: 2),
                const SizedBox(height: 4),
                Text(cuisines,
                    style: const TextStyle(fontSize: 12, color: Colors.deepOrange),
                    maxLines: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
