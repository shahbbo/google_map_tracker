import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_map_tracker/di/injection_container.dart';
import 'package:google_map_tracker/presentation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize dependency injection
  await initDependencies();
  
  runApp(const MapTrackerApp());
}