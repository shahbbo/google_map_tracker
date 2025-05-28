import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_map_tracker/domain/repositories/location_repository.dart';
import 'package:google_map_tracker/presentation/bloc/location/location_event.dart';
import 'package:google_map_tracker/presentation/bloc/location/location_state.dart';

import '../../../domain/entities/location_entity.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository _locationRepository;

  LocationBloc(this._locationRepository) : super(const LocationState()) {
    on<GetCurrentLocationEvent>(_onGetCurrentLocation);
    on<SearchPlacesEvent>(_onSearchPlaces);
    on<GetPlaceDetailsEvent>(_onGetPlaceDetails);
    on<SelectLocationEvent>(_onSelectLocation);
    on<ReverseGeocodeEvent>(_onReverseGeocode);
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    try {
      emit(state.copyWith(status: LocationStatus.loading));

      final location = await _locationRepository.getCurrentLocation();

      emit(state.copyWith(
        status: LocationStatus.loaded,
        currentLocation: location,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LocationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSearchPlaces(
    SearchPlacesEvent event,
    Emitter<LocationState> emit,
  ) async {
    try {
      emit(state.copyWith(status: LocationStatus.loading));

      final results = await _locationRepository.searchPlaces(event.query);

      emit(state.copyWith(
        status: LocationStatus.loaded,
        searchResults: results,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LocationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onGetPlaceDetails(
    GetPlaceDetailsEvent event,
    Emitter<LocationState> emit,
  ) async {
    try {
      emit(state.copyWith(status: LocationStatus.loading));

      final placeDetails =
          await _locationRepository.getPlaceDetails(event.placeId);

      if (placeDetails != null) {
        emit(state.copyWith(
          status: LocationStatus.loaded,
          selectedLocation: placeDetails,
        ));
      } else {
        emit(state.copyWith(
          status: LocationStatus.error,
          errorMessage: 'Failed to get place details',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: LocationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSelectLocation(
    SelectLocationEvent event,
    Emitter<LocationState> emit,
  ) {
    emit(state.copyWith(
      selectedLocation: event.location,
    ));
  }

  Future<void> _onReverseGeocode(
    ReverseGeocodeEvent event,
    Emitter<LocationState> emit,
  ) async {
    try {
      emit(state.copyWith(status: LocationStatus.loading));

      print(
          'LocationBloc: Reverse geocoding coordinates: ${event.latitude}, ${event.longitude}');

      // Get location with address from repository
      final locationWithAddress =
          await _locationRepository.getAddressFromCoordinates(
        event.latitude,
        event.longitude,
      );

      print(
          'LocationBloc: Got location with address: ${locationWithAddress.name}, ${locationWithAddress.address}');

      // Update state with the selected location
      emit(state.copyWith(
        status: LocationStatus.loaded,
        selectedLocation: locationWithAddress,
      ));
    } catch (e) {
      print('LocationBloc: Error in reverse geocoding: $e');
      // Create a basic location with the coordinates
      final basicLocation = LocationEntity(
        latitude: event.latitude,
        longitude: event.longitude,
        name: 'Selected Location',
        address: 'Address not available',
      );

      emit(state.copyWith(
        status: LocationStatus.error,
        errorMessage: e.toString(),
        selectedLocation: basicLocation,
      ));
    }
  }
}
