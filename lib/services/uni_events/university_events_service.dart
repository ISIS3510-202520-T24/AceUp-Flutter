import 'dart:convert';
import 'package:http/http.dart' as http; // ignore: uri_does_not_exist
import '../../models/uni_events/university_event_model.dart';

/// Service to fetch university events from eventos.uniandes.edu.co
/// Uses Eventtia API for reliable JSON data
class UniversityEventsService {
  static const String _baseUrl = 'https://connect.eventtia.com/en/api/v2/14686ebc-5e09-481f-8/events/list';
  static const Duration _timeout = Duration(seconds: 15);

  /// Fetch events from the Eventtia API
  Future<List<UniversityEvent>> fetchEvents({
    int pageSize = 50,
    String? categoryId,
    bool upcomingOnly = false,
  }) async {
    try {
      final queryParams = {
        'page_size': pageSize.toString(),
        'show_in_widget': 'true',
        'active': '1',
        if (categoryId != null && categoryId.isNotEmpty) 'category_id': categoryId,
        if (upcomingOnly) 'upcoming': '1',
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'AceUp/1.0',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final dynamic decodedBody = json.decode(response.body);

        // The API might return either a List or a Map with events inside
        List<dynamic> jsonData;

        if (decodedBody is List) {
          jsonData = decodedBody;
        } else if (decodedBody is Map<String, dynamic>) {
          // Try common response formats
          if (decodedBody.containsKey('events')) {
            jsonData = decodedBody['events'] as List<dynamic>;
          } else if (decodedBody.containsKey('data')) {
            jsonData = decodedBody['data'] as List<dynamic>;
          } else if (decodedBody.containsKey('results')) {
            jsonData = decodedBody['results'] as List<dynamic>;
          } else {
            // If the response is a single event, wrap it in a list
            jsonData = [decodedBody];
          }
        } else {
          throw Exception('Unexpected API response format');
        }

        return jsonData
            .map((json) => _parseEventFromApi(json as Map<String, dynamic>))
            .where((event) => event != null)
            .cast<UniversityEvent>()
            .toList();
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching university events: $e');
      rethrow; // Don't use mock data in production
    }
  }

  /// Parse event from Eventtia API response
  UniversityEvent? _parseEventFromApi(Map<String, dynamic> json) {
    try {
      final id = json['id']?.toString();
      final name = json['name'] as String?;
      final startDateStr = json['start_date'] as String?;

      if (id == null || name == null || startDateStr == null) {
        return null;
      }

      // Parse dates (format: "2025-12-04 08:00:00")
      final startDateTime = DateTime.parse(startDateStr.replaceAll(' ', 'T'));

      // Parse end date if available
      final endDateStr = json['end_date'] as String?;
      final endDateTime = endDateStr != null
          ? DateTime.parse(endDateStr.replaceAll(' ', 'T'))
          : DateTime.parse(startDateStr.replaceAll(' ', 'T'));

      final location = json['address_1'] as String?;

      // Get logo/image URL
      String? imageUrl;
      final logo = json['logo'] as Map<String, dynamic>?;
      final hero = json['hero'] as Map<String, dynamic>?;

      if (hero?['large_url'] != null) {
        imageUrl = hero!['large_url'] as String;
      } else if (logo?['large_url'] != null) {
        imageUrl = logo!['large_url'] as String;
      }

      return UniversityEvent(
        id: id,
        title: name,
        description: json['description'] as String? ?? '',
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        location: location,
        imageUrl: imageUrl,
        eventUrl: json['site_url'] as String?,
        category: json['category_name'] as String?,
        cachedAt: DateTime.now(),
      );
    } catch (e) {
      print('Error parsing event: $e');
      return null;
    }
  }

  /// Get available categories (you can expand this based on API discovery)
  List<String> getKnownCategories() {
    return [
      'Académico',
      'Cultural',
      'Deportivo',
      'Institucional',
      'Conferencia',
      'Taller',
    ];
  }
}