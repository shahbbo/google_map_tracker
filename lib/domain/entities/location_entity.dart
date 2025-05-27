import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationEntity extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;
  final String? name;
  
  const LocationEntity({
    required this.latitude,
    required this.longitude,
    this.address,
    this.name,
  });
  
  LatLng toLatLng() => LatLng(latitude, longitude);
  
  @override
  List<Object?> get props => [latitude, longitude, address, name];
}