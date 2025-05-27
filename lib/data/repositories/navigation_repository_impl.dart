import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_map_tracker/data/models/route_model.dart';
import 'package:google_map_tracker/data/services/google_maps_api_service.dart';
import 'package:google_map_tracker/domain/entities/location_entity.dart';
import 'package:google_map_tracker/domain/entities/route_entity.dart';
import 'package:google_map_tracker/domain/repositories/navigation_repository.dart';

class NavigationRepositoryImpl implements NavigationRepository {
  final GoogleMapsApiService _apiService;

  NavigationRepositoryImpl(this._apiService);

  @override
  Future<RouteEntity> getRoute(
      LocationEntity origin, LocationEntity destination) async {
    try {
      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;

      print(
          "Getting route from ${origin.latitude},${origin.longitude} to ${destination.latitude},${destination.longitude}");

      // إذا كان أحد الإحداثيات صفر، قد تكون هذه هي المشكلة
      if (destination.latitude == 0 || destination.longitude == 0) {
        print("ERROR: Destination coordinates are zero!");
        throw Exception('Invalid destination coordinates');
      }

      final originStr = '${origin.latitude},${origin.longitude}';
      final destinationStr = '${destination.latitude},${destination.longitude}';

      final response = await _apiService.getDirections(
        origin: originStr,
        destination: destinationStr,
        apiKey: apiKey,
      );

      // استخدام FromRouteResponse للاستجابات الجديدة
      if (response.containsKey('routes') &&
          response['routes'] is List &&
          response['routes'].isNotEmpty &&
          response['routes'][0].containsKey('polyline')) {
        return RouteModel.fromDirectionsResponse(response);
      }
      // طباعة الاستجابة للتحقق من المشاكل
      print("Directions API Response: ${response['status']}");

      if (response['status'] != 'OK') {
        print(
            "ERROR: Direction API returned ${response['status']} - ${response['error_message'] ?? 'No error message'}");
        throw Exception('Failed to get directions: ${response['status']}');
      }

      return RouteModel.fromDirectionsResponse(response);
    } catch (e) {
      print("ERROR in getRoute: $e");
      // إرجاع كائن مسار فارغ بدلاً من رمي استثناء
      return const RouteModel(
        polylinePoints: [],
        distance: 'N/A',
        duration: 'N/A',
      );
    }
  }
}
