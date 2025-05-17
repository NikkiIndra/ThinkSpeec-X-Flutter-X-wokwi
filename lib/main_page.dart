import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'thingspeak_service.dart';
import 'map_widget.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final ThingSpeakService thingSpeakService = ThingSpeakService(
    channelId: '2965388',
    readApiKey: 'KRBIG8BM8GML5H1P',
  );
  
  late Timer _timer;
  Map<String, dynamic>? _currentData;
  List<Map<String, dynamic>> _historicalData = [];
  List<LatLng> polylineCoordinates = [];
  LatLng currentPosition = LatLng(0, 0); // Default position
  
  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(Duration(seconds: 20), (timer) => _fetchData());
  }
  
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  
  Future<void> _fetchData() async {
    try {
      final data = await thingSpeakService.fetchData();
      final historical = await thingSpeakService.fetchHistoricalData();
      
      setState(() {
        _currentData = data;
        _historicalData = historical;
        _updatePosition();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  void _updatePosition() {
    if (_currentData == null) return;
    
    final feeds = _currentData!['feeds'] as List;
    if (feeds.isEmpty) return;
    
    final latestFeed = feeds.first;
    final lat = double.tryParse(latestFeed['field1'] ?? '0');
    final lng = double.tryParse(latestFeed['field2'] ?? '0');
    
    if (lat == null || lng == null) return;
    
    setState(() {
      currentPosition = LatLng(lat, lng);
    });
    
    // Update polyline
    polylineCoordinates.clear();
    for (var feed in _historicalData) {
      final feedLat = double.tryParse(feed['field1'] ?? '0');
      final feedLng = double.tryParse(feed['field2'] ?? '0');
      if (feedLat != null && feedLng != null) {
        polylineCoordinates.add(LatLng(feedLat, feedLng));
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Monitoring Real-time')),
      body: _currentData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Peta dengan OpenStreetMap
                  Container(
                    height: 300,
                    child: OpenStreetMapWidget(
                      currentPosition: currentPosition,
                      polylinePoints: polylineCoordinates,
                    ),
                  ),
                  
                  // Card untuk data sensor
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildDataRow('Suhu', '${_currentData!['feeds'][0]['field4']} °C', Icons.thermostat),
                            _buildDataRow('Kelembaban', '${_currentData!['feeds'][0]['field3']} %', Icons.water_drop),
                            _buildDataRow('Baterai', '${_currentData!['feeds'][0]['field5']} %', Icons.battery_full),
                            _buildDataRow('Latitude', '${_currentData!['feeds'][0]['field1']}', Icons.location_on),
                            _buildDataRow('Longitude', '${_currentData!['feeds'][0]['field2']}', Icons.location_on),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchData,
        child: Icon(Icons.refresh),
      ),
    );
  }
  
  Widget _buildDataRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 30),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}