import 'package:equatable/equatable.dart';
import 'package:google_map_tracker/domain/entities/location_entity.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();
  
  @override
  List<Object?> get props => [];
}

class GetRouteEvent extends NavigationEvent {
  final LocationEntity origin;
  final LocationEntity destination;
  
  const GetRouteEvent({
    required this.origin,
    required this.destination,
  });
  
  @override
  List<Object?> get props => [origin, destination];
}

class UpdateCurrentLocationEvent extends NavigationEvent {
  final LocationEntity currentLocation;
  
  const UpdateCurrentLocationEvent(this.currentLocation);
  
  @override
  List<Object?> get props => [currentLocation];
}

class ClearRouteEvent extends NavigationEvent {}