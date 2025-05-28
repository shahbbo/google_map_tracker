import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_map_tracker/domain/repositories/location_repository.dart';
import 'package:google_map_tracker/domain/entities/location_entity.dart';
import 'package:google_map_tracker/presentation/bloc/location/location_bloc.dart';
import 'package:google_map_tracker/presentation/bloc/location/location_event.dart';
import 'package:google_map_tracker/presentation/bloc/location/location_state.dart';
import 'package:google_map_tracker/presentation/bloc/navigation/navigation_bloc.dart';
import 'package:google_map_tracker/presentation/bloc/navigation/navigation_event.dart';
import 'package:google_map_tracker/presentation/bloc/navigation/navigation_state.dart';
import 'package:google_map_tracker/presentation/screens/search_screen.dart';
import 'package:location/location.dart' as loc;
import 'package:lottie/lottie.dart' hide Marker;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  StreamSubscription<loc.LocationData>? _locationSubscription;

  final GlobalKey<State<GoogleMap>> _mapKey = GlobalKey();

  final loc.Location _location = loc.Location();

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  void _startLocationUpdates() {
    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        final currentLocation = LocationEntity(
          latitude: locationData.latitude!,
          longitude: locationData.longitude!,
          name: 'Current Location',
        );

        context
            .read<NavigationBloc>()
            .add(UpdateCurrentLocationEvent(currentLocation));
      }
    });
  }

  Future<void> _updateMarkers(
      LocationState locationState, NavigationState navigationState) async {
    _markers.clear();

    // Add current location marker
    if (navigationState.currentLocation != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('origin_${DateTime.now().millisecondsSinceEpoch}'),
          position: navigationState.currentLocation!.toLatLng(),
          infoWindow: InfoWindow(
            title: 'Current Location',
            snippet: navigationState.currentLocation!.address,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    } else if (locationState.currentLocation != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('origin_${DateTime.now().millisecondsSinceEpoch}'),
          position: locationState.currentLocation!.toLatLng(),
          infoWindow: InfoWindow(
            title: 'Current Location',
            snippet: locationState.currentLocation!.address,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // Add destination marker if in navigation mode
    if (navigationState.destination != null) {
      _markers.add(
        Marker(
          markerId: MarkerId(
              'destination_${DateTime.now().millisecondsSinceEpoch}'), // معرف فريد لكل مرة
          position: navigationState.destination!.toLatLng(),
          infoWindow: InfoWindow(
            title: navigationState.destination!.name ?? 'Destination',
            snippet: navigationState.destination!.address,
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    // Add selected location marker if not in navigation mode
    if (navigationState.status == NavigationStatus.initial &&
        locationState.selectedLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: locationState.selectedLocation!.toLatLng(),
          infoWindow: InfoWindow(
            title: locationState.selectedLocation!.name ?? 'Selected Location',
            snippet: locationState.selectedLocation!.address,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }

  Future<void> _updatePolylines(NavigationState navigationState) async {
    _polylines.clear();

    if (navigationState.route != null &&
        navigationState.route!.polylinePoints.isNotEmpty) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('navigation_route'),
          color: Colors.blue,
          points: navigationState.route!.polylinePoints,
          width: 5,
        ),
      );
    }
  }

  Future<void> _animateToCurrentLocation() async {
    if (!_mapController.isCompleted) return;

    final GoogleMapController controller = await _mapController.future;
    final locationState = context.read<LocationBloc>().state;
    final navigationState = context.read<NavigationBloc>().state;

    if (navigationState.currentLocation != null) {
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: navigationState.currentLocation!.toLatLng(),
          zoom: 15,
        ),
      ));
    } else if (locationState.currentLocation != null) {
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: locationState.currentLocation!.toLatLng(),
          zoom: 15,
        ),
      ));
    }
  }

  Future<void> _fitMapToShowRoute() async {
    if (!_mapController.isCompleted) return;

    final GoogleMapController controller = await _mapController.future;
    final navigationState = context.read<NavigationBloc>().state;

    if (navigationState.route != null &&
        navigationState.route!.polylinePoints.isNotEmpty) {
      final points = navigationState.route!.polylinePoints;

      double minLat = points.first.latitude;
      double maxLat = points.first.latitude;
      double minLng = points.first.longitude;
      double maxLng = points.first.longitude;

      for (final point in points) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }

      controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          50, // padding
        ),
      );
    }
  }

  void _startNavigation() {
    final locationState = context.read<LocationBloc>().state;
    if (locationState.currentLocation != null &&
        locationState.selectedLocation != null) {
      context.read<NavigationBloc>().add(
            GetRouteEvent(
              origin: locationState.currentLocation!,
              destination: locationState.selectedLocation!,
            ),
          );
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _stopNavigation() {
    context.read<NavigationBloc>().add(ClearRouteEvent());
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Maps & Navigation').animate().fadeIn(duration: 500.ms),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<NavigationBloc>().add(ClearRouteEvent());
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _animateToCurrentLocation,
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<LocationBloc, LocationState>(
            listener: (context, state) {
              final messenger = ScaffoldMessenger.of(context);

              // Handle different location states
              if (state.status == LocationStatus.loaded) {
                _updateMarkers(state, context.read<NavigationBloc>().state);
              } else if (state.status == LocationStatus.error) {
                // Handle error state
                _updateMarkers(state, context.read<NavigationBloc>().state);
              }
            },
          ),
          BlocListener<NavigationBloc, NavigationState>(
            listener: (context, state) {
              if (state.status == NavigationStatus.navigating) {
                _updateMarkers(context.read<LocationBloc>().state, state);
                _updatePolylines(state);
                _fitMapToShowRoute();
              } else if (state.status == NavigationStatus.initial) {
                _updateMarkers(context.read<LocationBloc>().state, state);
                _updatePolylines(state);
              }
            },
          ),
        ],
        child: Stack(
          children: [
            // Google Map
            BlocBuilder<LocationBloc, LocationState>(
              builder: (context, locationState) {
                if (locationState.currentLocation == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return GoogleMap(
                  key: _mapKey,
                  initialCameraPosition: CameraPosition(
                    target: locationState.currentLocation!.toLatLng(),
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  compassEnabled: true,
                  markers: _markers,
                  polylines: _polylines,
                  onMapCreated: (controller) {
                    _mapController.complete(controller);
                    _updateMarkers(
                        locationState, context.read<NavigationBloc>().state);
                  },
                  onTap: (latLng) {
                    context.read<LocationBloc>().add(
                          ReverseGeocodeEvent(
                              latLng.latitude, latLng.longitude),
                        );
                  },
                );
              },
            ),

            // Navigation Info Panel
            BlocBuilder<NavigationBloc, NavigationState>(
              builder: (context, navigationState) {
                if (navigationState.status == NavigationStatus.error) {
                  return Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      color: Colors.red.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              "خطأ في الملاحة",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(navigationState.errorMessage ??
                                "حدث خطأ غير معروف"),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              child: const Text("حاول مرة أخرى"),
                              onPressed: () {
                                // إعادة المحاولة
                                if (navigationState.origin != null &&
                                    navigationState.destination != null) {
                                  context.read<NavigationBloc>().add(
                                        GetRouteEvent(
                                          origin: navigationState.origin!,
                                          destination:
                                              navigationState.destination!,
                                        ),
                                      );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                if (navigationState.status == NavigationStatus.navigating &&
                    navigationState.route != null) {
                  return Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Destination',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      Text(
                                        navigationState.destination?.name ??
                                            'Selected Location',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Distance',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      navigationState.route!.distance,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'ETA: ${navigationState.route!.duration}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.cancel),
                                  label: const Text('End'),
                                  onPressed: _stopNavigation,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.3, end: 0);
                }
                return const SizedBox.shrink();
              },
            ),

            // Location Selection Panel
            BlocBuilder<LocationBloc, LocationState>(
              builder: (context, locationState) {
                final navigationState = context.watch<NavigationBloc>().state;

                if (navigationState.status != NavigationStatus.navigating &&
                    locationState.selectedLocation != null) {
                  return Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              locationState.selectedLocation?.name ??
                                  'Selected Location',
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              locationState.selectedLocation?.address ??
                                  'Address not available',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: LottieBuilder.asset(
                                  height: 40,
                                  width: 40,
                                  'assets/animations/navigation.json'),
                              // icon: const Icon(Icons.navigation),
                              label: const Text('Start Navigation'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                              ),
                              onPressed: _startNavigation,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.3, end: 0);
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'search_fab',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
            child: const Icon(Icons.search),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'location_fab',
            onPressed: _animateToCurrentLocation,
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }
}
