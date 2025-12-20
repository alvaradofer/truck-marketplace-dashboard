import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MaterialApp(home: TruckMap()));

class TruckMap extends StatefulWidget {
  @override
  _TruckMapState createState() => _TruckMapState();
}

class _TruckMapState extends State<TruckMap> {
  List<LatLng> routePoints = [];

  // YOUR API KEY
  final String apiKey =
      "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjIxNGY4OGQ3YzQ3OTQwOTA5YjU3ZjQwMmI3Zjg2ZjE1IiwiaCI6Im11cm11cjY0In0=";

  Future<void> getRoute() async {
    // Cloud URL for Heavy Vehicle (HGV)
    final String url =
        "https://api.openrouteservice.org/v2/directions/driving-hgv"
        "?api_key=$apiKey"
        "&start=-106.485,31.7619" // El Paso
        "&end=-96.797,32.7767"; // Dallas

    try {
      print("Requesting Cloud Route...");
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> coords =
            data['features'][0]['geometry']['coordinates'];

        setState(() {
          routePoints = coords
              .map((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
              .toList();
        });
        print("Success: Route received from Cloud!");
      } else {
        print("Cloud Error: ${response.statusCode}");
        print("Body: ${response.body}");
      }
    } catch (e) {
      print("Network Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Truck Route (Cloud)")),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(31.7619, -106.485), // El Paso
          zoom: 6,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          // The Line Layer
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                strokeWidth: 5,
                color: Colors.blue,
              ),
            ],
          ),
          // The Marker Layer (Added here)
          MarkerLayer(
            markers: [
              // Start Marker (Green)
              Marker(
                point: LatLng(31.7619, -106.485),
                width: 40,
                height: 40,
                child: Icon(Icons.location_on, color: Colors.green, size: 40),
              ),
              // End Marker (Red)
              Marker(
                point: LatLng(32.7767, -96.797),
                width: 40,
                height: 40,
                child: Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getRoute,
        child: Icon(Icons.local_shipping),
      ),
    );
  }
}
