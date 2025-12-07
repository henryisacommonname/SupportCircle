import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [LocalResourceCard(), const SizedBox(height: 16)],
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
  final List<CommunityMarker> _events = const [
    CommunityMarker(
      id: 'samaritan-house',
      name: 'Samaritan House Pantry',
      time: '10:00 AM',
      location: LatLng(37.5566, -122.3042),
    ),
    CommunityMarker(
      id: 'shoreline',
      name: 'Shoreline Cleanup',
      time: '9:00 AM',
      location: LatLng(37.6397, -122.3980),
    ),
    CommunityMarker(
      id: 'library-tutoring',
      name: 'Library Study Buddies',
      time: '4:00 PM',
      location: LatLng(37.4852, -122.2364),
    ),
    CommunityMarker(
      id: 'community-garden',
      name: 'Community Garden Build',
      time: '8:30 AM',
      location: LatLng(37.4530, -122.1817),
    ),
    CommunityMarker(
      id: 'shelter-meal',
      name: 'Shelter Meal Service',
      time: '6:00 PM',
      location: LatLng(37.4969, -122.2197),
    ),
  ];

  GoogleMapController? mapController;
  Position? userPosition;
  bool RequestLocation = false;
  bool LocationDenied = false;
  String? statusmessage;

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
          statusmessage = "Location permission denied";
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
      if (userPosition != null) {
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(userPosition!.latitude, userPosition!.longitude),
              zoom: 5.0,
            ),
          ),
        );
      }
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
      ;
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
                ), const SizedBox(width: 12,),
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
