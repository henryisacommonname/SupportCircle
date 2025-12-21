import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Core/Services/Google_Maps.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find volunteer opportunities nears you!'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [LocalResourceCard(), SizedBox(height: 16)],
      ),
    );
  }
}

class LocalResourceCard extends StatefulWidget {
  const LocalResourceCard({super.key});

  @override
  State<LocalResourceCard> createState() => _LocalResourceCardState();
}

class _LocalResourceCardState extends State<LocalResourceCard> {
  List<PlaceResult> _places = const [];
  final GoogleMapsService _mapsService = GoogleMapsService();

  GoogleMapController? mapController;
  Position? userPosition;
  bool RequestLocation = false;
  bool LocationDenied = false;
  String? statusmessage;
  bool LoadingPlaces = false;

  DateTime? _placesCallStartedAt;
  Duration? _placesCallDuration;
  int? _placesLastResultCount;
  String? _placesLastError;
  bool _placesCallInFlight = false;

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
          statusmessage = 'Turn on Location Services to Enable Map!';
          LocationDenied = false;
        });
        showSnack('Turn on Location Services to Enable Map!');
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
              'Location is Blocked, If you wish to use Location Services, Please turn on Location.';
          LocationDenied = true;
        });
        return;
      }

      if (Permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() {
          statusmessage = 'Location permission denied';
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
        statusmessage = 'Showing possible Community Service opportunities!';
      });
      await LoadingEvents(position);
      if (userPosition != null) {
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(userPosition!.latitude, userPosition!.longitude),
              zoom: 13.0,
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        statusmessage = 'General Location Inaccessible.';
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
      statusmessage = 'Finding events near you!';
      _placesCallInFlight = true;
      _placesCallStartedAt = DateTime.now();
      _placesCallDuration = null;
      _placesLastResultCount = null;
      _placesLastError = null;
    });
    try {
      final stopwatch = Stopwatch()..start();
      if (kDebugMode) {
        debugPrint(
          '[SupportScreen] Calling Places API via GoogleMapsService.findCommunityEvents() '
          'lat=${userPosition.latitude}, lng=${userPosition.longitude}',
        );
      }
      final places = await _mapsService.findCommunityEvents(userPosition);
      final Placeswithdistance = _sortPlacesByDistance(
        places
            .map(
              (place) => place.copyWith(
                distance: Geolocator.distanceBetween(
                  userPosition.latitude,
                  userPosition.longitude,
                  place.location.latitude,
                  place.location.longitude,
                ),
              ),
            )
            .toList(),
      );
      if (!mounted) return;
      setState(() {
        _places = Placeswithdistance;
        _placesLastResultCount = places.length;
        _placesCallDuration = stopwatch.elapsed;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        statusmessage = 'Could not find nearby opportunities';
        _placesLastError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          LoadingPlaces = false;
          _placesCallInFlight = false;
        });
      }
    }
  }

  Set<Marker> BuildMarkers() {
    final markers = _places
        .map(
          (place) => Marker(
            markerId: MarkerId(place.placeId),
            position: place.location,
            infoWindow: InfoWindow(
              title: place.name,
              snippet: place.address ?? '',
            ),
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
          infoWindow: const InfoWindow(title: 'Current Location'),
        ),
      );
    }
    return markers;
  }

  String distanceLabel(PlaceResult place) {
    final distance = place.distance;
    if (distance == null) {
      return 'Distance unavailable';
    }
    final miles = distance / 1609.34;
    return '${miles.toStringAsFixed(2)} mi';
  }

  Color _statusColor(PlaceResult place, BuildContext context) {
    if (place.isOpen == true) {
      return Colors.green.shade600;
    }
    if (place.isOpen == false) {
      return Colors.red.shade600;
    }
    return Theme.of(context).colorScheme.outline;
  }

  String _statusLabel(PlaceResult place) {
    if (place.isOpen == true) return 'Open';
    if (place.isOpen == false) return 'Closed';
    return 'Status unknown';
  }

  List<Widget> _buildChips(PlaceResult place) {
    const ignored = {'point_of_interest', 'establishment', 'premise', 'food'};
    final tags = place.types.where((t) => !ignored.contains(t)).take(3).map((
      type,
    ) {
      final label = type.replaceAll('_', ' ');
      return Chip(
        label: Text(label),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 6),
      );
    }).toList();

    if (tags.isEmpty) {
      return [
        Chip(
          label: Text(
            'Community service',
            style: TextStyle(color: Colors.blue.shade900),
          ),
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 6),
        ),
      ];
    }
    return tags;
  }

  Widget buildplacecard(BuildContext context, PlaceResult place) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            distanceLabel(place),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: _statusColor(place, context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _statusLabel(place),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: _statusColor(place, context)),
                          ),
                          if (place.rating != null) ...[
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 18,
                            ),
                            Text(place.rating!.toStringAsFixed(1)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: -8,
                        children: _buildChips(place),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        place.address ?? 'Address unavailable',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Center on map',
                  icon: const Icon(Icons.map_outlined),
                  onPressed: () {
                    mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(place.location, 14),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(place.location, 15),
                  );
                },
                child: const Text('Get Directions'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PlaceResult> _sortPlacesByDistance(List<PlaceResult> places) {
    return List<PlaceResult>.from(places)..sort(
      (a, b) => (a.distance ?? double.infinity).compareTo(
        b.distance ?? double.infinity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const nycCenter = LatLng(40.7128, -74.0060);
    final mapHeight = max(360.0, MediaQuery.sizeOf(context).height * 0.55);

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
                height: mapHeight,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GoogleMap(
                        mapType: MapType.normal,
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
                        initialCameraPosition: CameraPosition(
                          target: userPosition != null
                              ? LatLng(
                                  userPosition!.latitude,
                                  userPosition!.longitude,
                                )
                              : nycCenter,
                          zoom: userPosition != null ? 13 : 5,
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
                      top: 12,
                      left: 12,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Text(
                            '${_places.length} locations nearby',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    if (RequestLocation)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black12,
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
            if (kDebugMode) ...[
              const SizedBox(height: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: DefaultTextStyle.merge(
                    style: const TextStyle(fontFamily: 'monospace'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('DEBUG: Places API'),
                        const SizedBox(height: 6),
                        Text(
                          'called: ${_placesCallStartedAt != null ? 'yes' : 'no'}'
                          '${_placesCallStartedAt != null ? ' @ ${_placesCallStartedAt!.toIso8601String()}' : ''}',
                        ),
                        Text('inFlight: $_placesCallInFlight'),
                        Text(
                          'duration: ${_placesCallDuration != null ? '${_placesCallDuration!.inMilliseconds}ms' : '-'}',
                        ),
                        Text(
                          'resultCount: ${_placesLastResultCount != null ? _placesLastResultCount.toString() : '-'}',
                        ),
                        Text(
                          'apiKeyPresent: ${_mapsService.apiKey.isNotEmpty}',
                        ),
                        if (_placesLastError != null)
                          Text('error: $_placesLastError'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nearby locations',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_places.length} found',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _places = _sortPlacesByDistance(_places);
                    });
                  },
                  child: const Text('Sort by distance'),
                ),
              ],
            ),
            if (LoadingPlaces) const LinearProgressIndicator(minHeight: 4),
            if (!LoadingPlaces && _places.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No nearby locations found yet.'),
              ),
            ..._places.map((place) => buildplacecard(context, place)),
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
