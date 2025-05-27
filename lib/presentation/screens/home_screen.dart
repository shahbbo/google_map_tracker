import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_map_tracker/presentation/bloc/location/location_bloc.dart';
import 'package:google_map_tracker/presentation/bloc/location/location_event.dart';
import 'package:google_map_tracker/presentation/bloc/location/location_state.dart';
import 'package:google_map_tracker/presentation/screens/map_screen.dart';
import 'package:google_map_tracker/presentation/screens/search_screen.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Get current location when app starts
    context.read<LocationBloc>().add(GetCurrentLocationEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map Tracker')
            .animate()
            .fadeIn(duration: 800.ms)
            .slideY(begin: -0.2, end: 0),
      ),
      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
          if (state.status == LocationStatus.initial ||
              state.status == LocationStatus.loading) {
            return Center(
              child: LottieBuilder.asset(
                  "assets/animations/google_maps_loading.json"),
            );
          } else if (state.status == LocationStatus.error) {
            return Center(
              child: Text(
                'Error: ${state.errorMessage}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            );
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Location pin animation
                  LottieBuilder.asset("assets/animations/location_pin.json"),

                  const SizedBox(height: 30),

                  Text(
                    'Welcome to Google Map Tracker',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 300.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 15),
                  Text(
                    'Navigate between locations with real-time tracking',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 800.ms, delay: 500.ms),
                  const SizedBox(height: 40),

                  // Open Map button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MapScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map),
                        SizedBox(width: 8),
                        Text('Open Map'),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 700.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 16),

                  // Search Location button
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.colorScheme.primary),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search),
                        SizedBox(width: 8),
                        Text('Search Location'),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 900.ms)
                      .slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
