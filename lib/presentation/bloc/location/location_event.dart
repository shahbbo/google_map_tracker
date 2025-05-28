import 'package:equatable/equatable.dart';
import 'package:google_map_tracker/domain/entities/location_entity.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();
  
  @override
  List<Object?> get props => [];
}

class GetCurrentLocationEvent extends LocationEvent {}

class SearchPlacesEvent extends LocationEvent {
  final String query;
  
  const SearchPlacesEvent(this.query);
  
  @override
  List<Object?> get props => [query];
}

class GetPlaceDetailsEvent extends LocationEvent {
  final String placeId;
  
  const GetPlaceDetailsEvent(this.placeId);
  
  @override
  List<Object?> get props => [placeId];
}

class SelectLocationEvent extends LocationEvent {
  final LocationEntity location;
  
  const SelectLocationEvent(this.location);
  
  @override
  List<Object?> get props => [location];
}

class ReverseGeocodeEvent extends LocationEvent {
  final double latitude;
  final double longitude;
  
  const ReverseGeocodeEvent(this.latitude, this.longitude);
  
  @override
  List<Object?> get props => [latitude, longitude];
}