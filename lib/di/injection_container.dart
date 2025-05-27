import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:google_map_tracker/data/repositories/location_repository_impl.dart';
import 'package:google_map_tracker/data/repositories/navigation_repository_impl.dart';
import 'package:google_map_tracker/data/services/google_maps_api_service.dart';
import 'package:google_map_tracker/domain/repositories/location_repository.dart';
import 'package:google_map_tracker/domain/repositories/navigation_repository.dart';
import 'package:google_map_tracker/presentation/bloc/location/location_bloc.dart';
import 'package:google_map_tracker/presentation/bloc/navigation/navigation_bloc.dart';
import 'package:location/location.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => Location());

  // Services
  sl.registerLazySingleton<GoogleMapsApiService>(
      () => GoogleMapsApiService(sl<Dio>()));

  // Repositories
  sl.registerLazySingleton<LocationRepository>(
      () => LocationRepositoryImpl(sl<GoogleMapsApiService>(), sl<Location>()));
  sl.registerLazySingleton<NavigationRepository>(
      () => NavigationRepositoryImpl(sl<GoogleMapsApiService>()));

  // Blocs
  sl.registerFactory(() => LocationBloc(sl<LocationRepository>()));
  sl.registerFactory(() => NavigationBloc(sl<NavigationRepository>()));
}
