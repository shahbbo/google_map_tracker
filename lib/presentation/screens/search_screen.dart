import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_map_tracker/presentation/bloc/location/location_bloc.dart';
import 'package:google_map_tracker/presentation/bloc/location/location_event.dart';
import 'package:google_map_tracker/presentation/bloc/location/location_state.dart';
import 'package:google_map_tracker/presentation/screens/map_screen.dart';
import 'package:lottie/lottie.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchPlaces(String query) {
    if (query.isEmpty) return;

    context.read<LocationBloc>().add(SearchPlacesEvent(query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Location').animate().fadeIn(duration: 500.ms),
      ),
      body: Column(
        children: [
          // Search Input
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a location...',
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: const Icon(Icons.clear),
                ),
              ),
              onChanged: (value) {
                if (value.length >= 3) {
                  _searchPlaces(value);
                }
              },
              onSubmitted: _searchPlaces,
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),

          // Search Results
          Expanded(
            child: BlocBuilder<LocationBloc, LocationState>(
              builder: (context, state) {
                if (state.status == LocationStatus.loading) {
                  return Center(
                    child: LottieBuilder.asset(
                        "assets/animations/map_loading.json"),
                  );
                }

                if (state.searchResults.isEmpty) {
                  return Center(
                    child: Text(
                      'No locations found',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ).animate().fadeIn(duration: 500.ms);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.searchResults.length,
                  itemBuilder: (context, index) {
                    final location = state.searchResults[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(
                          location.name ?? 'Unknown',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          location.address ?? 'No address',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          context.read<LocationBloc>().add(
                                SelectLocationEvent(location),
                              );

                          // Navigate to map screen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MapScreen(),
                            ),
                          );
                        },
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: (50 * index).ms)
                        .slideX(begin: -0.1, end: 0);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
