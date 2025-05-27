import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_map_tracker/data/models/location_model.dart';
import 'package:google_map_tracker/data/services/google_maps_api_service.dart';
import 'package:google_map_tracker/domain/entities/location_entity.dart';
import 'package:google_map_tracker/domain/repositories/location_repository.dart';
import 'package:location/location.dart' as loc;

class LocationRepositoryImpl implements LocationRepository {
  final GoogleMapsApiService _apiService;
  final loc.Location _location;

  LocationRepositoryImpl(this._apiService, this._location);

  @override
  Future<LocationEntity> getCurrentLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }
    }

    var permission = await _location.hasPermission();
    if (permission == loc.PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != loc.PermissionStatus.granted) {
        throw Exception('Location permissions are denied.');
      }
    }

    final locationData = await _location.getLocation();
    final address = await getAddressFromLatLng(
      locationData.latitude!,
      locationData.longitude!,
    );

    return LocationModel(
      latitude: locationData.latitude!,
      longitude: locationData.longitude!,
      address: address,
      name: 'Current Location',
    );
  }

  @override
  Future<String?> getAddressFromLatLng(double lat, double lng) async {
    try {
      final placeMarks = await placemarkFromCoordinates(lat, lng);
      if (placeMarks.isNotEmpty) {
        final place = placeMarks.first;
        return '${place.street}, ${place.locality}, ${place.country}';
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<LocationEntity>> searchPlaces(String input) async {
    try {
      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
      final response = await _apiService.searchPlaces(
        input: input,
        apiKey: apiKey,
      );

      if (response['status'] == 'OK') {
        final predictions = response['predictions'] as List;
        final List<LocationEntity> results = <LocationEntity>[];

        for (var prediction in predictions) {
          final placeId = prediction['place_id'] as String;
          print("Getting details for place ID: $placeId");

          // نحصل على تفاصيل المكان بما في ذلك الإحداثيات
          final placeDetails = await getPlaceDetails(placeId);

          if (placeDetails != null) {
            results.add(placeDetails);
          }
        }

        return results;
      }

      print(
          "ERROR: Place API returned ${response['status']} - ${response['error_message'] ?? 'No error message'}");
      return [];
    } catch (e) {
      print("ERROR in searchPlaces: $e");
      return [];
    }
  }

  @override
  Future<LocationEntity?> getPlaceDetails(String placeId) async {
    try {
      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
      if (placeId.isEmpty) {
        print("ERROR: Place ID is empty");
        return null;
      }
      final response = await _apiService.getPlaceDetails(
        placeId: placeId,
        apiKey: apiKey,
      );

      if (response['status'] == 'OK') {
        final result = response['result'];
        final location = result['geometry']['location'];
        final lat = location['lat'] as double;
        final lng = location['lng'] as double;

        print("Found location at $lat,$lng for place ID: $placeId");

        return LocationModel(
          latitude: lat,
          longitude: lng,
          name: result['name'],
          address: result['formatted_address'],
        );
      }

      print(
          "ERROR: Place Details API returned ${response['status']} - ${response['error_message'] ?? 'No error message'}");
      return null;
    } catch (e) {
      print("ERROR in getPlaceDetails: $e");
      return null;
    }
  }
}
