import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteEntity extends Equatable {
  final List<LatLng> polylinePoints;
  final String distance;
  final String duration;
  
  const RouteEntity({
    required this.polylinePoints,
    required this.distance,
    required this.duration,
  });
  
  @override
  List<Object> get props => [polylinePoints, distance, duration];
}