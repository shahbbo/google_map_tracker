# Google Map Tracker

<div align="center">
  <img src="https://storage.googleapis.com/cms-storage-bucket/6e19fee6b47b36ca613f.png" height="80" alt="Flutter Logo">
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://developers.google.com/maps/images/maps-icon.svg" height="80" alt="Google Maps Logo">
</div>


## Overview

Google Map Tracker is an open-source mobile application built with Flutter that provides mapping and navigation services. The app leverages Google Maps APIs to deliver a seamless navigation experience with features such as place search, route display, and live navigation information.

## Key Features

- **Interactive Maps**: Utilizes Google Maps for responsive map display
- **Current Location Tracking**: Precisely pinpoints user's location on the map
- **Place Search**: Find destinations using Google Places API
- **Tap-to-Select Destination**: Select destinations by directly tapping on the map
- **Route Display**: Shows the optimal route from current location to selected destination
- **Navigation Information**: Displays distance and estimated time of arrival
- **Intuitive UI**: User-friendly design with smooth animations

## Technical Architecture

The application is built using:

- **Flutter**: Cross-platform framework for mobile app development
- **Bloc**: State management pattern for separating business logic from UI
- **Google Maps API**: Mapping and navigation services from Google
- **Google Places API**: Place information and search functionality
- **Geocoding API**: Convert coordinates to addresses and vice versa
- **Directions API**: Obtain routes and directions between locations

## Project Structure

The application follows Clean Architecture principles to ensure scalability and testability:

```
lib/
  ├── data/                  # Data layer
  │   ├── models/            # Data models
  │   └── repositories/      # Repository implementations
  │
  ├── domain/                # Business logic layer
  │   ├── entities/          # Domain entities
  │   └── repositories/      # Repository interfaces
  │
  └── presentation/          # Presentation layer
      ├── bloc/              # Bloc components for state management
      ├── screens/           # Application screens
      └── widgets/           # Reusable UI components
```

## Installation Requirements

- Flutter SDK (version 3.0.0 or higher)
- Dart SDK (version 2.17.0 or higher)
- Google Maps API key with the following APIs enabled:
  - Maps SDK for Android
  - Maps SDK for iOS
  - Places API
  - Directions API
  - Geocoding API

## Setup and Running

1. **Clone the repository**
   ```bash
   git clone https://github.com/shahbbo/google_map_tracker.git
   cd google_map_tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up API key**
   - Create a `.env` file in the root directory
   - Add your Google Maps API key:
     ```
     GOOGLE_MAPS_API_KEY=your_api_key_here
     ```

4. **Android platform setup**
   - Add API key in `android/app/src/main/AndroidManifest.xml`:
     ```xml
     <meta-data
         android:name="com.google.android.geo.API_KEY"
         android:value="YOUR_API_KEY_HERE"/>
     ```

5. **iOS platform setup**
   - Add API key in `ios/Runner/AppDelegate.swift`:
     ```swift
     GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
     ```

6. **Run the application**
   ```bash
   flutter run
   ```

## Usage Guide

1. **Launch**: When starting the app, the map will display your current location
2. **Search**: Tap the search button to find a destination
3. **Select Point**: Tap any location on the map to select it as a destination
4. **View Details**: An information box will appear with selected location details
5. **Start Navigation**: Tap "Start Navigation" to display route, distance, and estimated time
6. **End Navigation**: Tap "End" to stop navigation and return to normal mode

## Contributing

Contributions are welcome! If you'd like to contribute:

1. Fork the project
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.

## Credits and Acknowledgements

- [Flutter](https://flutter.dev/)
- [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)
- [Flutter Bloc](https://pub.dev/packages/flutter_bloc)
- [Google Maps Webservice](https://pub.dev/packages/google_maps_webservice)
- [Geocoding](https://pub.dev/packages/geocoding)
- [Flutter Animate](https://pub.dev/packages/flutter_animate)

## Last Updated

2023-05-27

## Developer

[shahbbo](https://github.com/shahbbo)
