import 'package:google_map_tracker/domain/entities/route_entity.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteModel extends RouteEntity {
  const RouteModel({
    required List<LatLng> polylinePoints,
    required String distance,
    required String duration,
  }) : super(
          polylinePoints: polylinePoints,
          distance: distance,
          duration: duration,
        );

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      polylinePoints: [], // This would need proper conversion
      distance: json['distance'] as String,
      duration: json['duration'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'distance': distance,
        'duration': duration,
        // Note: polylinePoints is not serialized here as it's complex
      };

  factory RouteModel.fromDirectionsResponse(Map<String, dynamic> json) {
    try {
      // طباعة البيانات للتحقق
      print("Parsing directions response with status: ${json['status']}");

      final routes = json['routes'] as List?;
      if (routes == null || routes.isEmpty) {
        print("ERROR: No routes found in the response");
        return RouteModel(
          polylinePoints: const [],
          distance: 'N/A',
          duration: 'N/A',
        );
      }

      final route = routes[0];
      final legs = route['legs'] as List?;

      if (legs == null || legs.isEmpty) {
        print("ERROR: No legs found in the route");
        return RouteModel(
          polylinePoints: const [],
          distance: 'N/A',
          duration: 'N/A',
        );
      }

      final leg = legs[0];

      // التحقق من وجود بيانات المسافة والوقت
      final distance =
          leg['distance'] != null ? leg['distance']['text'] as String : 'N/A';
      final duration =
          leg['duration'] != null ? leg['duration']['text'] as String : 'N/A';

      print("Found distance: $distance, duration: $duration");

      // التحقق من وجود بيانات المسار
      final polyline = route['overview_polyline']?['points'];
      if (polyline == null) {
        print("ERROR: No polyline points found in the response");
        return RouteModel(
          polylinePoints: const [],
          distance: distance,
          duration: duration,
        );
      }

      // تحليل نقاط المسار
      final polylinePoints = _decodePolyline(polyline as String);
      print("Decoded ${polylinePoints.length} polyline points");

      return RouteModel(
        polylinePoints: polylinePoints,
        distance: distance,
        duration: duration,
      );
    } catch (e) {
      print("ERROR in RouteModel.fromDirectionsResponse: $e");
      return RouteModel(
        polylinePoints: const [],
        distance: 'N/A',
        duration: 'N/A',
      );
    }
  }

  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latDouble = lat / 1e5;
      double lngDouble = lng / 1e5;
      poly.add(LatLng(latDouble, lngDouble));
    }

    return poly;
  }
}
