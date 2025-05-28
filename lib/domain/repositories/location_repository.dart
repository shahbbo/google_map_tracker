import 'package:google_map_tracker/domain/entities/location_entity.dart';

abstract class LocationRepository {
  Future<LocationEntity> getCurrentLocation();
  Future<String?> getAddressFromLatLng(double lat, double lng);
  Future<LocationEntity> getAddressFromCoordinates(double lat, double lng);
  Future<List<LocationEntity>> searchPlaces(String query);
  Future<LocationEntity?> getPlaceDetails(String placeId);
}