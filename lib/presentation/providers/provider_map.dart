import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;

class ProviderMap extends ChangeNotifier {
  LatLng _selectedLocation = const LatLng(0, 0);

  LatLng get selectedLocation => _selectedLocation;

  set selectedLocation(LatLng location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void getCurrentLocation() async {
    geo.Position position = await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.high,
    );

    selectedLocation = LatLng(position.latitude, position.longitude);
  }
}

class ProviderControllerMap extends ChangeNotifier {
  GoogleMapController? _currentLocation;

  GoogleMapController? get selectedController => _currentLocation;

  set selectedController(GoogleMapController? location) {
    _currentLocation = location;
    notifyListeners();
  }
}