import 'dart:convert';

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
      throw Exception("Google Maps API key missing");
    }
    final URI = Uri.https(
      "maps.googleapis.com",
      "/maps/api/nearbysearch/json",
      <String, String>{
        "location": "${userPosition.latitude}, ${userPosition.longitude}",
        "radius": "32000",
        "keyword": "community service, kitchen, cleanup, non-profit, volunteer",
        "opennow": "true",
        "key": apiKey,
      },
    );

    final Response = await http.get(URI);
    if (Response.statusCode != 200) {
      throw Exception("Expection: places API failed, ${Response.statusCode}}");
    }

    final data = jsonDecode(Response.body) as Map<String, dynamic>;

    if (data['status'] != "OK" && data['status'] != "ZERO_RESULTS") {
      throw Exception('Places API error: ${data['status']}');
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

  PlaceResult({
    required this.placeId,
    required this.name,
    required this.location,
    this.address,
    this.rating,
  });

  factory PlaceResult.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>? ?? {};
    final location = json['geometry'] as Map<String, dynamic>? ?? {};
    return PlaceResult(
      placeId: json['place_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? "community Service Event!",
      address: json['vicinity'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      location: LatLng(
        (location['lat'] as num?)?.toDouble() ?? 0,
        (location['lng'] as num?)?.toDouble() ?? 0,
      ),
    );
  }
}
