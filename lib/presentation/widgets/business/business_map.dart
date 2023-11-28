import 'dart:async';
import 'package:appointment_app/presentation/providers/provider_map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart' as geo;

class BusinessMap extends StatefulWidget {
  const BusinessMap({super.key});

  @override
  State<BusinessMap> createState() => _BusinessMapState();
}

class _BusinessMapState extends State<BusinessMap> {
  Set<Marker> markers = {};
  GoogleMapController? _mapController;
  LocationData? _currentLocation;

  String extraerNumerosDeLatLng(String cadena) {
    RegExp regex = RegExp(r"(-?\d+\.\d+)");
    Iterable<Match> matches = regex.allMatches(cadena);
    List<String?> numeros = matches.map((match) => match.group(0)).toList();
    return numeros.join(", ");
  }
  Future<void> _getLocation() async {
    var location = Location();
    try {
      _currentLocation = await location.getLocation();
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
              zoom: 15.0,
            ),
          ),
        );
      }
    } catch (e) {
      e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    double screen = MediaQuery.of(context).size.height;
    final locationMap = context.watch<ProviderMap>();
    final controllerMap = context.watch<ProviderControllerMap>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              if (_currentLocation != null) {
                locationMap.selectedLocation = LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);      
              }
              _mapController = controllerMap.selectedController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(
                locationMap.selectedLocation.latitude,
                locationMap.selectedLocation.longitude,
              ),
              zoom: 15,
            ),            
            onTap: (LatLng location) {
              locationMap.selectedLocation = location;
              markers.add(
                Marker(
                  markerId: const MarkerId("Location 2"),
                  position: locationMap.selectedLocation,
                  infoWindow: const InfoWindow(
                    title: 'Select location',
                  ),
                )
              );
            },
            markers: markers,
          ),
          Positioned(
            top: screen * 0.7, // ? Debería adaptarse
            left: screen * 0.39,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pop(context, extraerNumerosDeLatLng( locationMap.selectedLocation.toString() ));
              },
              child: const Icon(Icons.save),
            )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'CurrentLocation',
        onPressed: () async {
          geo.Position position = await geo.Geolocator.getCurrentPosition(
            desiredAccuracy: geo.LocationAccuracy.best,
          );
          LatLng currentLocation = LatLng(position.latitude, position.longitude);
          _mapController!.animateCamera(CameraUpdate.newLatLng(currentLocation));
        },
        child: const Icon(Icons.location_searching),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

}