import 'package:equatable/equatable.dart';
import 'package:google_map_tracker/domain/entities/location_entity.dart';
import 'package:google_map_tracker/domain/entities/route_entity.dart';

enum NavigationStatus { initial, loading, navigating, error }

class NavigationState extends Equatable {
  final NavigationStatus status;
  final LocationEntity? origin;
  final LocationEntity? destination;
  final LocationEntity? currentLocation;
  final RouteEntity? route;
  final String? errorMessage;
  
  const NavigationState({
    this.status = NavigationStatus.initial,
    this.origin,
    this.destination,
    this.currentLocation,
    this.route,
    this.errorMessage,
  });
  
  NavigationState copyWith({
    NavigationStatus? status,
    LocationEntity? origin,
    LocationEntity? destination,
    LocationEntity? currentLocation,
    RouteEntity? route,
    String? errorMessage,
  }) {
    return NavigationState(
      status: status ?? this.status,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      currentLocation: currentLocation ?? this.currentLocation,
      route: route ?? this.route,
      errorMessage: errorMessage,
    );
  }
  
  @override
  List<Object?> get props => [
    status, 
    origin, 
    destination, 
    currentLocation, 
    route, 
    errorMessage
  ];
}