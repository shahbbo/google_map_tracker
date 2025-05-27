import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_map_tracker/core/themes/app_theme.dart';
import 'package:google_map_tracker/di/injection_container.dart';
import 'package:google_map_tracker/presentation/bloc/location/location_bloc.dart';
import 'package:google_map_tracker/presentation/bloc/navigation/navigation_bloc.dart';
import 'package:google_map_tracker/presentation/screens/home_screen.dart';

class MapTrackerApp extends StatelessWidget {
  const MapTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<LocationBloc>()),
        BlocProvider(create: (_) => sl<NavigationBloc>()),
      ],
      child: MaterialApp(
        title: 'Google Map Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
