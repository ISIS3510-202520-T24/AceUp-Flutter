import 'dart:convert';
import 'package:http/http.dart' as http; // ignore: uri_does_not_exist
import '../models/holiday_model.dart';

class HolidayService {
  static const String _baseUrl = 'https://date.nager.at/api/v3';

  /// Fetches holidays for a specific country and year
  ///
  /// [countryCode] - ISO 3166-1 alpha-2 country code (e.g., 'CO' for Colombia)
  /// [year] - Year to fetch holidays for
  Future<List<Holiday>> getHolidaysForCountry(
      String countryCode,
      int year,
      ) async {
    try {
      final url = '$_baseUrl/PublicHolidays/$year/$countryCode';
      final uri = Uri.parse(url);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // The API returns an array directly
        final List<dynamic> jsonData = json.decode(response.body);

        // Convert each JSON object to a Holiday
        return jsonData
            .map((json) => Holiday.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 404) {
        throw Exception('Country not found or no holidays available for this year. Please check the country code.');
      } else {
        throw Exception('Failed to load holidays: ${response.statusCode}\nResponse: ${response.body}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error fetching holidays: $e');
    }
  }

  /// Fetches holidays for current year and next year for a specific country
  Future<List<Holiday>> getHolidaysForCurrentAndNextYear(String countryCode) async {
    final currentYear = DateTime.now().year;
    final nextYear = currentYear + 1;

    try {
      // Fetch holidays for both years concurrently
      final results = await Future.wait([
        getHolidaysForCountry(countryCode, currentYear),
        getHolidaysForCountry(countryCode, nextYear),
      ]);

      // Combine and sort by date
      final allHolidays = [...results[0], ...results[1]];
      allHolidays.sort((a, b) => a.date.compareTo(b.date));

      return allHolidays;
    } catch (e) {
      throw Exception('Error fetching holidays for multiple years: $e');
    }
  }

  /// Fetches holidays for a specific date
  /// Returns true if the date is a public holiday
  Future<bool> isPublicHoliday(String countryCode, DateTime date) async {
    try {
      // Nager.Date endpoint: /api/v3/IsTodayPublicHoliday/{countryCode}
      // For specific date: we need to get the year's holidays and check
      final holidays = await getHolidaysForCountry(countryCode, date.year);

      return holidays.any((holiday) =>
      holiday.date.year == date.year &&
          holiday.date.month == date.month &&
          holiday.date.day == date.day
      );
    } catch (e) {
      throw Exception('Error checking if date is holiday: $e');
    }
  }

  /// Gets the next upcoming public holidays (up to 5)
  Future<List<Holiday>> getNextPublicHolidays(String countryCode) async {
    final now = DateTime.now();
    final currentYear = now.year;

    try {
      // Get holidays for current year
      final holidays = await getHolidaysForCountry(countryCode, currentYear);

      // Filter upcoming holidays
      final upcoming = holidays.where((h) => h.date.isAfter(now)).toList();

      // If less than 5, get some from next year
      if (upcoming.length < 5) {
        final nextYearHolidays = await getHolidaysForCountry(countryCode, currentYear + 1);
        upcoming.addAll(nextYearHolidays.take(5 - upcoming.length));
      }

      return upcoming.take(5).toList();
    } catch (e) {
      throw Exception('Error fetching next holidays: $e');
    }
  }

  /// Gets list of available countries
  /// Returns a list of country codes and names
  Future<List<Map<String, String>>> getAvailableCountries() async {
    try {
      final url = '$_baseUrl/AvailableCountries';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        return jsonData.map((json) => {
          'code': json['countryCode'] as String,
          'name': json['name'] as String,
        }).toList();
      } else {
        throw Exception('Failed to load countries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching countries: $e');
    }
  }
}