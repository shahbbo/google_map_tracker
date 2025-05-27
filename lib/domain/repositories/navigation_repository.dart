import 'package:google_map_tracker/domain/entities/location_entity.dart';
import 'package:google_map_tracker/domain/entities/route_entity.dart';

abstract class NavigationRepository {
  Future<RouteEntity> getRoute(LocationEntity origin, LocationEntity destination);
}