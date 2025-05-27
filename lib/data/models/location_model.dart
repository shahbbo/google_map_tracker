import 'package:google_map_tracker/domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  const LocationModel({
    required double latitude,
    required double longitude,
    String? address,
    String? name,
  }) : super(
          latitude: latitude,
          longitude: longitude,
          address: address,
          name: name,
        );

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'name': name,
      };

  factory LocationModel.fromEntity(LocationEntity entity) {
    return LocationModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      address: entity.address,
      name: entity.name,
    );
  }
}
