import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dummy_data.dart'; 

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;

  LatLng _center = const LatLng(2.1896, 102.2501); // Default center (Melaka)
  LatLng? _userLocation;

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  void _setMarkersFromDummy(LatLng userLocation) {
    const double radiusInMeters = 3000; 

    print("User Location: $userLocation");
    for (var restaurant in dummyRestaurants) {
      double distance = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        restaurant.latitude,
        restaurant.longitude,
      );

      print("${restaurant.name} => ${distance.toStringAsFixed(2)} meter");

      if (distance <= radiusInMeters) {
        _markers.add(
          Marker(
            markerId: MarkerId(restaurant.name),
            position: LatLng(restaurant.latitude, restaurant.longitude),
            infoWindow: InfoWindow(title: restaurant.name),
          ),
        );
      }
    }
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
      _center = _userLocation!;
      _markers.clear();

      // ✅ Tambah marker user
      _markers.add(
        Marker(
          markerId: const MarkerId('User'),
          position: _userLocation!,
          infoWindow: const InfoWindow(title: 'You are here'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );

      _setMarkersFromDummy(_userLocation!);
    });

    mapController.animateCamera(CameraUpdate.newLatLng(_userLocation!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Restaurants'),
        backgroundColor: Colors.deepOrange,
      ),
      body: GoogleMap(
        onMapCreated: (controller) => mapController = controller,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 14,
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
