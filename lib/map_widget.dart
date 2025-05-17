import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OpenStreetMapWidget extends StatelessWidget {
  final LatLng currentPosition;
  final List<LatLng> polylinePoints;

  const OpenStreetMapWidget({
    Key? key,
    required this.currentPosition,
    required this.polylinePoints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: currentPosition,
        // center: currentPosition,
        minZoom: 15.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: polylinePoints,
              strokeWidth: 4.0,
              color: Colors.blue,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: currentPosition,
              child: Icon(
                // Ganti 'builder' dengan 'child'
                Icons.location_pin,
                color: Colors.red,
                size: 40.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
