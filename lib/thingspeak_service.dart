import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ThingSpeakService {
  final String channelId;
  final String readApiKey;
  
  ThingSpeakService({required this.channelId, required this.readApiKey});
  
  Future<Map<String, dynamic>> fetchData() async {
    final url = Uri.parse(
      'https://api.thingspeak.com/channels/$channelId/feeds.json?api_key=$readApiKey&results=1'
    );
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('Channel not found');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Check your API key');
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Data format error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  Future<List<Map<String, dynamic>>> fetchHistoricalData({int results = 100}) async {
    if (results < 1 || results > 8000) {
      throw ArgumentError('Results must be between 1 and 8000');
    }
    
    final url = Uri.parse(
      'https://api.thingspeak.com/channels/$channelId/feeds.json?api_key=$readApiKey&results=$results'
    );
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final feeds = data['feeds'] as List;
        return feeds.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load historical data. Status code: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Data format error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}