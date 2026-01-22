import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/maps_service.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find volunteer opportunities near you!')),
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
  final MapsService _mapsService = MapsService();

  GoogleMapController? _mapController;
  Position? _userPosition;
  bool _requestingLocation = false;
  bool _locationDenied = false;
  String? _statusMessage;
  bool _loadingPlaces = false;

  DateTime? _placesCallStartedAt;
  Duration? _placesCallDuration;
  int? _placesLastResultCount;
  String? _placesLastError;
  bool _placesCallInFlight = false;

  @override
  void initState() {
    super.initState();
    _requestLocation();
  }

  Future<void> _requestLocation() async {
    setState(() {
      _requestingLocation = true;
      _statusMessage = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _statusMessage = 'Turn on Location Services to Enable Map!';
          _locationDenied = false;
        });
        _showSnack('Turn on Location Services to Enable Map!');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _statusMessage =
              'Location is Blocked. If you wish to use Location Services, please turn on Location.';
          _locationDenied = true;
        });
        return;
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() {
          _statusMessage = 'Location permission denied';
          _locationDenied = true;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      if (!mounted) return;
      setState(() {
        _userPosition = position;
        _locationDenied = false;
        _statusMessage = 'Showing possible Community Service opportunities!';
      });

      await _loadEvents(position);
      if (_userPosition != null) {
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(_userPosition!.latitude, _userPosition!.longitude),
              zoom: 13.0,
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _statusMessage = 'General Location Inaccessible.');
    } finally {
      if (mounted) setState(() => _requestingLocation = false);
    }
  }

  Future<void> _loadEvents(Position userPosition) async {
    setState(() {
      _loadingPlaces = true;
      _statusMessage = 'Finding events near you!';
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
          '[SupportScreen] Calling Places API via MapsService.findCommunityEvents() '
          'lat=${userPosition.latitude}, lng=${userPosition.longitude}',
        );
      }

      final places = await _mapsService.findCommunityEvents(userPosition);
      final placesWithDistance = _sortPlacesByDistance(
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
        _places = placesWithDistance;
        _placesLastResultCount = places.length;
        _placesCallDuration = stopwatch.elapsed;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Could not find nearby opportunities';
        _placesLastError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingPlaces = false;
          _placesCallInFlight = false;
        });
      }
    }
  }

  Set<Marker> _buildMarkers() {
    final markers = _places
        .map(
          (place) => Marker(
            markerId: MarkerId(place.placeId),
            position: place.location,
            infoWindow: InfoWindow(title: place.name, snippet: place.address ?? ''),
          ),
        )
        .toSet();

    final position = _userPosition;
    if (position != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current-location'),
          position: LatLng(position.latitude, position.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          infoWindow: const InfoWindow(title: 'Current Location'),
        ),
      );
    }
    return markers;
  }

  String _distanceLabel(PlaceResult place) {
    final distance = place.distance;
    if (distance == null) return 'Distance unavailable';
    final miles = distance / 1609.34;
    return '${miles.toStringAsFixed(2)} mi';
  }

  Color _statusColor(PlaceResult place, BuildContext context) {
    if (place.isOpen == true) return Colors.green.shade600;
    if (place.isOpen == false) return Colors.red.shade600;
    return Theme.of(context).colorScheme.outline;
  }

  String _statusLabel(PlaceResult place) {
    if (place.isOpen == true) return 'Open';
    if (place.isOpen == false) return 'Closed';
    return 'Status unknown';
  }

  ({Color bg, Color text}) _tagColors(String type) {
    final t = type.toLowerCase();

    // Health-related
    if (t.contains('health') || t.contains('hospital') || t.contains('doctor') ||
        t.contains('pharmacy') || t.contains('medical') || t.contains('clinic')) {
      return (bg: Colors.red.shade100, text: Colors.red.shade900);
    }

    // Food-related
    if (t.contains('food') || t.contains('meal') || t.contains('restaurant') ||
        t.contains('grocery') || t.contains('bakery') || t.contains('cafe')) {
      return (bg: Colors.orange.shade100, text: Colors.orange.shade900);
    }

    // Education-related
    if (t.contains('school') || t.contains('education') || t.contains('university') ||
        t.contains('library') || t.contains('tutor') || t.contains('learning')) {
      return (bg: Colors.purple.shade100, text: Colors.purple.shade900);
    }

    // Charity/nonprofit
    if (t.contains('charity') || t.contains('nonprofit') || t.contains('donation') ||
        t.contains('volunteer') || t.contains('foundation')) {
      return (bg: Colors.green.shade100, text: Colors.green.shade900);
    }

    // Religious/church
    if (t.contains('church') || t.contains('mosque') || t.contains('synagogue') ||
        t.contains('temple') || t.contains('religious') || t.contains('worship')) {
      return (bg: Colors.indigo.shade100, text: Colors.indigo.shade900);
    }

    // Social services
    if (t.contains('social') || t.contains('shelter') || t.contains('housing') ||
        t.contains('welfare') || t.contains('assistance')) {
      return (bg: Colors.teal.shade100, text: Colors.teal.shade900);
    }

    // Environment/nature
    if (t.contains('park') || t.contains('garden') || t.contains('environment') ||
        t.contains('nature') || t.contains('conservation')) {
      return (bg: Colors.lightGreen.shade100, text: Colors.lightGreen.shade900);
    }

    // Default blue
    return (bg: Colors.blue.shade100, text: Colors.blue.shade900);
  }

  List<Widget> _buildChips(PlaceResult place) {
    const ignored = {'point_of_interest', 'establishment', 'premise'};
    final tags = place.types.where((t) => !ignored.contains(t)).take(3).map((type) {
      final label = type.replaceAll('_', ' ');
      final colors = _tagColors(type);
      return Chip(
        label: Text(
          label,
          style: TextStyle(color: colors.text, fontSize: 12),
        ),
        backgroundColor: colors.bg,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        side: BorderSide.none,
      );
    }).toList();

    if (tags.isEmpty) {
      return [
        Chip(
          label: Text(
            'Community service',
            style: TextStyle(color: Colors.blue.shade900, fontSize: 12),
          ),
          backgroundColor: Colors.blue.shade100,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          side: BorderSide.none,
        ),
      ];
    }
    return tags;
  }

  Widget _buildPlaceCard(BuildContext context, PlaceResult place) {
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
                      Text(place.name, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _distanceLabel(place),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.circle, size: 8, color: _statusColor(place, context)),
                          const SizedBox(width: 4),
                          Text(
                            _statusLabel(place),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: _statusColor(place, context)),
                          ),
                          if (place.rating != null) ...[
                            const SizedBox(width: 12),
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                            Text(place.rating!.toStringAsFixed(1)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(spacing: 6, runSpacing: -8, children: _buildChips(place)),
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
                    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(place.location, 14));
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openDirections(place),
                icon: const Icon(Icons.directions),
                label: const Text('Get Directions'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PlaceResult> _sortPlacesByDistance(List<PlaceResult> places) {
    return List<PlaceResult>.from(places)
      ..sort((a, b) =>
          (a.distance ?? double.infinity).compareTo(b.distance ?? double.infinity));
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openDirections(PlaceResult place) async {
    final lat = place.location.latitude;
    final lng = place.location.longitude;
    final destination = Uri.encodeComponent(place.address ?? '$lat,$lng');

    // Try Apple Maps first (iOS), fallback to Google Maps
    final appleMapsUrl = Uri.parse(
      'https://maps.apple.com/?daddr=$destination&dirflg=d',
    );
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );

    try {
      if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        _showSnack('Could not open maps application');
      }
    } catch (e) {
      _showSnack('Error opening directions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const nycCenter = LatLng(40.7128, -74.0060);
    final mapHeight = max(360.0, MediaQuery.sizeOf(context).height * 0.55);

    final buttonLabel = _locationDenied
        ? 'Open Settings'
        : _userPosition == null
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
                          target: _userPosition != null
                              ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
                              : nycCenter,
                          zoom: _userPosition != null ? 13 : 5,
                        ),
                        markers: _buildMarkers(),
                        onMapCreated: (controller) {
                          _mapController = controller;
                          final position = _userPosition;
                          if (position != null) {
                            _mapController?.moveCamera(
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
                          color: Colors.white.withAlpha(230),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Text(
                            '${_places.length} locations nearby',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    if (_requestingLocation)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black12,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_statusMessage != null) Text(_statusMessage!),
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
                        Text('resultCount: ${_placesLastResultCount?.toString() ?? '-'}'),
                        Text('apiKeyPresent: ${_mapsService.apiKey.isNotEmpty}'),
                        if (_placesLastError != null) Text('error: $_placesLastError'),
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
                  onPressed: _requestingLocation
                      ? null
                      : () async {
                          if (_locationDenied) {
                            await Geolocator.openAppSettings();
                            return;
                          }
                          await _requestLocation();
                        },
                  icon: const Icon(Icons.location_searching),
                  label: Text(buttonLabel),
                ),
                const SizedBox(width: 12),
                if (_userPosition != null)
                  Text(
                    'Lat: ${_userPosition!.latitude.toStringAsFixed(3)}, '
                    'Lng: ${_userPosition!.longitude.toStringAsFixed(3)}',
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
                    Text('Nearby locations', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text('${_places.length} found', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                TextButton(
                  onPressed: () => setState(() => _places = _sortPlacesByDistance(_places)),
                  child: const Text('Sort by distance'),
                ),
              ],
            ),
            if (_loadingPlaces) const LinearProgressIndicator(minHeight: 4),
            if (!_loadingPlaces && _places.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No nearby locations found yet.'),
              ),
            ..._places.map((place) => _buildPlaceCard(context, place)),
          ],
        ),
      ),
    );
  }
}
