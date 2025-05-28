import 'package:dio/dio.dart';

class GoogleMapsApiService {
  final Dio _dio;
  final String baseUrl;

  GoogleMapsApiService(this._dio,
      {this.baseUrl = "https://maps.googleapis.com/maps/api"});

  Future<Map<String, dynamic>> getDirections({
    required String origin,
    required String destination,
    String mode = "driving",
    required String apiKey,
  }) async {
    try {
      print(
          "Sending direction request: origin=$origin, destination=$destination");

      final response = await _dio.get(
        '$baseUrl/directions/json',
        queryParameters: {
          'origin': origin,
          'destination': destination,
          'mode': mode,
          'key': apiKey,
        },
      );

      print("Direction API status code: ${response.statusCode}");
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print("ERROR in getDirections API call: $e");
      // إعادة خطأ بتنسيق مألوف لواجهة API
      return {
        'status': 'REQUEST_FAILED',
        'error_message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> searchPlaces({
    required String input,
    String components = "country:eg",
    required String apiKey,
  }) async {
    final response = await _dio.get(
      '$baseUrl/place/autocomplete/json',
      queryParameters: {
        'input': input,
        'components': components,
        'key': apiKey,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getPlaceDetails({
    required String placeId,
    required String apiKey,
  }) async {
    final response = await _dio.get(
      '$baseUrl/place/details/json',
      queryParameters: {
        'place_id': placeId,
        'key': apiKey,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> reverseGeocode({
    required double lat,
    required double lng,
    required String apiKey,
  }) async {
    try {
      print('Calling Google Maps Reverse Geocoding API for $lat,$lng');
      final response = await _dio.get(
        '$baseUrl/geocode/json',
        queryParameters: {
          'latlng': '$lat,$lng',
          'key': apiKey,
        },
      );

      print('Reverse geocoding API status code: ${response.statusCode}');
      print('Response: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('ERROR in reverseGeocode API call: $e');
      return {
        'status': 'REQUEST_FAILED',
        'error_message': e.toString(),
      };
    }
  }
}
