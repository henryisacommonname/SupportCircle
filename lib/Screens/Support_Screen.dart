import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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

class LocalResourceCard extends StatelessWidget {
  const LocalResourceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Local Resources'),
            const SizedBox(height: 10),
            ClipRRect(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map_outlined, size: 48),
                      const SizedBox(height: 10),
                      Text('Map COMING SOON'),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),Row(children: [const Icon(Icons.location_on_outlined),const SizedBox(width: 8),const Spacer(),FilledButton.icon(onPressed: null, label: Text('Enable Location'),icon: Icon(Icons.my_location),)])
          ],
        ),
      ),
    );
  }
}
