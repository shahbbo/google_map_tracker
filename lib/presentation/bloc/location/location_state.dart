import 'package:equatable/equatable.dart';
import 'package:google_map_tracker/domain/entities/location_entity.dart';

enum LocationStatus { initial, loading, loaded, error }

class LocationState extends Equatable {
  final LocationStatus status;
  final LocationEntity? currentLocation;
  final LocationEntity? selectedLocation;
  final List<LocationEntity> searchResults;
  final String? errorMessage;
  
  const LocationState({
    this.status = LocationStatus.initial,
    this.currentLocation,
    this.selectedLocation,
    this.searchResults = const [],
    this.errorMessage,
  });
  
  LocationState copyWith({
    LocationStatus? status,
    LocationEntity? currentLocation,
    LocationEntity? selectedLocation,
    List<LocationEntity>? searchResults,
    String? errorMessage,
  }) {
    return LocationState(
      status: status ?? this.status,
      currentLocation: currentLocation ?? this.currentLocation,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      searchResults: searchResults ?? this.searchResults,
      errorMessage: errorMessage,
    );
  }
  
  @override
  List<Object?> get props => [
    status, 
    currentLocation, 
    selectedLocation, 
    searchResults, 
    errorMessage
  ];
}