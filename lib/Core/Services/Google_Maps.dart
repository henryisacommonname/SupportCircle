import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'google_maps_config.dart' show googleMapsApiKey;

class GoogleMapsService {
  final String apiKey;

  GoogleMapsService({String? apiKeyOverride})
    : apiKey =
          apiKeyOverride ??
          googleMapsApiKey.ifEmpty(
            const String.fromEnvironment('GOOGLE_MAPS_API_KEY'),
          );

  Future<List<PlaceResult>> findCommunityEvents(Position userPosition) async {
    if (apiKey.isEmpty) {
      throw Exception('Google Maps API key missing');
    }
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/nearbysearch/json',
      <String, String>{
        'location': '${userPosition.latitude},${userPosition.longitude}',
        'radius': '32000', // ~20 miles
        'keyword': 'community service volunteer nonprofit food bank shelter',
        'opennow': 'true',
        'key': apiKey,
      },
    );

    if (kDebugMode) {
      final sanitizedQuery = Map<String, String>.from(uri.queryParameters)
        ..remove('key');
      final sanitizedUri = uri.replace(queryParameters: sanitizedQuery);
      debugPrint('[GoogleMapsService] Places nearbysearch GET $sanitizedUri');
    }

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      final bodyPreview = response.body.length > 400
          ? '${response.body.substring(0, 400)}...'
          : response.body;
      throw Exception(
        'Places API HTTP ${response.statusCode}. Body: $bodyPreview',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
      throw Exception('Places API error: ${data['status']}');
    }
    if (kDebugMode) {
      debugPrint('[GoogleMapsService] Places status=${data['status']}');
    }

    final results = data['results'] as List<dynamic>? ?? <dynamic>[];
    return results.map((raw) => PlaceResult.fromJson(raw)).toList();
  }
}

extension StringFallbackExtension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

class PlaceResult {
  final String placeId;
  final String name;
  final String? address;
  final LatLng location;
  final double? rating;
  final bool? isOpen;
  final List<String> types;
  final double? distance;

  PlaceResult({
    required this.placeId,
    required this.name,
    required this.location,
    this.address,
    this.rating,
    this.isOpen,
    this.types = const [],
    this.distance,
  });

  factory PlaceResult.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>? ?? {};
    final location = geometry['location'] as Map<String, dynamic>? ?? {};
    final openingHours = json['opening_hours'] as Map<String, dynamic>?;
    return PlaceResult(
      placeId: json['place_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Community Service Event',
      address: json['vicinity'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      isOpen: openingHours != null ? openingHours['open_now'] as bool? : null,
      types:
          (json['types'] as List<dynamic>?)
              ?.map((type) => type.toString())
              .toList() ??
          const [],
      location: LatLng(
        (location['lat'] as num?)?.toDouble() ?? 0,
        (location['lng'] as num?)?.toDouble() ?? 0,
      ),
      distance: null,
    );
  }

  PlaceResult copyWith({
    double? distance,
    String? address,
    double? rating,
    bool? isOpen,
    List<String>? types,
  }) {
    return PlaceResult(
      placeId: placeId,
      name: name,
      location: location,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      isOpen: isOpen ?? this.isOpen,
      types: types ?? this.types,
      distance: distance ?? this.distance,
    );
  }
}
