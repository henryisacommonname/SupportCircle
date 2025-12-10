import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Core/Services/Google_Maps.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          LocalResourceCard(),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

class CommunityMarker {
  final String id;
  final String name;
  final LatLng location;
  final String time;

  const CommunityMarker({
    required this.id,
    required this.name,
    required this.location,
    required this.time,
  });
}

class LocalResourceCard extends StatefulWidget {
  const LocalResourceCard({super.key});

  @override
  State<LocalResourceCard> createState() => localResourceCardState();
}

class localResourceCardState extends State<LocalResourceCard> {
  List<CommunityMarker> _events = const [];
  final GoogleMapsService OpportunityFinder = GoogleMapsService();

  GoogleMapController? mapController;
  Position? userPosition;
  bool RequestLocation = false;
  bool LocationDenied = false;
  String? statusmessage;
  bool LoadingPlaces = false;

  @override
  void initState() {
    super.initState();
    LocationRequester();
  }

  @override
  void initState() {
    super.initState();
    LocationRequester();
  }

  Future<void> LocationRequester() async {
    setState(() {
      RequestLocation = true;
      statusmessage = null;
    });

    try {
      final MapServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!MapServiceEnabled) {
        if (!mounted) return;
        setState(() {
          statusmessage = "Turn on Location Services to Enable Map!";
          LocationDenied = false;
        });
        showSnack("Turn on Location Services to Enable Map!");
        return;
      }

      var Permission = await Geolocator.checkPermission();
      if (Permission == LocationPermission.denied) {
        Permission = await Geolocator.requestPermission();
      }

      if (Permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          statusmessage =
              "Location is Blocked, If you wish to use Location Services, Please turn on Location.";
          LocationDenied = true;
        });
        return;
      }

      if (Permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() {
<<<<<<< HEAD
          statusmessage = "Location permission deneid";
=======
          statusmessage = "Location permission denied";
>>>>>>> 79d7cde9fa429ca0227fc79f5a189faee91cbe4a
          LocationDenied = true;
        });
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      if (!mounted) return;
      setState(() {
        userPosition = position;
        LocationDenied = false;
        statusmessage = "Showing possible Community Service opportunities!";  
      });
<<<<<<< HEAD
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 12,
=======
      await LoadingEvents(position);
      if (userPosition != null) {
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(userPosition!.latitude, userPosition!.longitude),
              zoom: 5.0,
            ),
>>>>>>> 79d7cde9fa429ca0227fc79f5a189faee91cbe4a
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        statusmessage = "General Location Inaccessable.";
      });
    } finally {
      if (mounted) {
        setState(() {
          RequestLocation = false;
        });
      }
    }
  }

  Future<void> LoadingEvents(Position userPosition) async {
    setState(() {
      LoadingPlaces = true;
      statusmessage = "Finding events near you!";
    });
    try {
      final places = await OpportunityFinder.findCommunityEvents(userPosition);
      if (!mounted) return;
      setState(() {
        _events = places
            .map(
              (place) => CommunityMarker(
                id: place.placeId,
                name: place.name,
                location: place.location,
                time: "WIP",
              ),
            )
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        statusmessage = "Could not find nearby opprtunities";
      });
    } finally {
      if (mounted) {
        setState(() {
          LoadingPlaces = false;
        });
      }
    }
  }

  Set<Marker> BuildMarkers() {
    final markers = _events
        .map(
          (event) => Marker(
            markerId: MarkerId(event.id),
            position: event.location,
            infoWindow: InfoWindow(title: event.name, snippet: event.time),
          ),
        )
        .toSet();

    final position = userPosition;
    if (position != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current-location'),
          position: LatLng(position.latitude, position.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
          infoWindow: const InfoWindow(title: "Current Location"),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    const nycCenter = LatLng(40.7128, -74.0060);

    final buttonLabel = LocationDenied
        ? 'Open Settings'
        : userPosition == null

        ? 'Enable Location'
        : 'Refresh';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 260,
                width: double.infinity,
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                          target: userPosition != null
                              ? LatLng(
                                  userPosition!.latitude,
                                  userPosition!.longitude,
                                )
                              : nycCenter,
                          zoom: 5,
                        ),
                        markers: BuildMarkers(),
                        onMapCreated: (controller) {
                          mapController = controller;
                          final position = userPosition;
                          if (position != null) {
                            mapController?.moveCamera(
                              CameraUpdate.newLatLng(
                                LatLng(position.latitude, position.longitude),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    Positioned(
                      child: Material(
                        child: IconButton(
                          onPressed: RequestLocation ? null : LocationRequester,
                          icon: const Icon(Icons.my_location),
                        ),
                      ),
                    ),
                    if (RequestLocation)
                      Positioned.fill(
                        child: Container(
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (statusmessage != null) Text(statusmessage!),
            const SizedBox(height: 8),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: RequestLocation
                      ? null
                      : () async {
                          if (LocationDenied) {
                            await Geolocator.openAppSettings();
                            return;
                          }
                          await LocationRequester();
                        },
                  icon: const Icon(Icons.location_searching),
                  label: Text(buttonLabel),
                ),
                const SizedBox(width: 12),
                if (userPosition != null)
                  Text(
                    'Lat: ${userPosition!.latitude.toStringAsFixed(3)}, '
                    'Lng: ${userPosition!.longitude.toStringAsFixed(3)}',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
