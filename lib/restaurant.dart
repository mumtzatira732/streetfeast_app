class Restaurant {
  final String id;
  final String name;
  final String address;
  final String description;
  final String operationHour;
  final List<String> cuisines;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String googleMapsLink; 

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    required this.operationHour,
    required this.cuisines,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.googleMapsLink, 
  });

  factory Restaurant.fromFirestore(Map<String, dynamic> data, String id) {
    return Restaurant(
      id: id,
      name: data['name'] ?? 'No name',
      address: data['address'] ?? 'No address',
      description: data['description'] ?? 'No description',
      operationHour: data['operationHour'] ?? 'Not available',
      cuisines: List<String>.from(data['cuisines'] ?? []),
      imageUrl: data['imageUrl'] ?? '',
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      googleMapsLink: data['googleMapsLink'] ?? '', 
    );
  }
}
