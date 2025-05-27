import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_map_tracker/domain/repositories/navigation_repository.dart';
import 'package:google_map_tracker/presentation/bloc/navigation/navigation_event.dart';
import 'package:google_map_tracker/presentation/bloc/navigation/navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  final NavigationRepository _navigationRepository;

  NavigationBloc(this._navigationRepository) : super(const NavigationState()) {
    on<GetRouteEvent>(_onGetRoute);
    on<UpdateCurrentLocationEvent>(_onUpdateCurrentLocation);
    on<ClearRouteEvent>(_onClearRoute);
  }

  Future<void> _onGetRoute(
    GetRouteEvent event,
    Emitter<NavigationState> emit,
  ) async {
    try {
      // تسجيل بيانات التحقق
      print(
          "Getting route - Origin: ${event.origin.latitude},${event.origin.longitude}");
      print(
          "Getting route - Destination: ${event.destination.latitude},${event.destination.longitude}");

      // تأكد من أن الإحداثيات صالحة
      if (event.origin.latitude == 0 ||
          event.origin.longitude == 0 ||
          event.destination.latitude == 0 ||
          event.destination.longitude == 0) {
        emit(state.copyWith(
          status: NavigationStatus.error,
          errorMessage: "Invalid coordinates (zero values detected)",
        ));
        return;
      }

      emit(state.copyWith(
        status: NavigationStatus.loading,
        origin: event.origin,
        destination: event.destination,
        currentLocation: event.origin,
      ));

      final route = await _navigationRepository.getRoute(
        event.origin,
        event.destination,
      );

      // تحقق مما إذا كانت المسارات فارغة
      if (route.polylinePoints.isEmpty) {
        emit(state.copyWith(
          status: NavigationStatus.error,
          errorMessage: "Couldn't find a route between these locations",
          route: route,
        ));
        return;
      }

      emit(state.copyWith(
        status: NavigationStatus.navigating,
        route: route,
      ));
    } catch (e) {
      print("Error in NavigationBloc._onGetRoute: $e");
      emit(state.copyWith(
        status: NavigationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onUpdateCurrentLocation(
    UpdateCurrentLocationEvent event,
    Emitter<NavigationState> emit,
  ) {
    if (state.status == NavigationStatus.navigating) {
      emit(state.copyWith(
        currentLocation: event.currentLocation,
      ));
    }
  }

  void _onClearRoute(
    ClearRouteEvent event,
    Emitter<NavigationState> emit,
  ) {
    emit(const NavigationState());
  }
}
