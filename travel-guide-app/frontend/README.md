# Travel Guide App - Flutter Frontend

Flutter mobile application for connecting travelers with local guides.

## Features

### Home Screen
- **Search Bar**: Search for tours, guides, or cities
- **Location Button**: Get current location and find nearby tours/guides
- **4 Main Sections**:
  1. **Interested In**: Quick access to tour categories (Food, Bike, Cultural, Adventure)
  2. **Tours**: Browse all available tours with filtering
  3. **Expert Guides**: Top-rated guides in your location
  4. **Personalized Tour**: AI chatbot for personalized recommendations

### Tours Screen
- Browse all tours with filtering by type
- View tour details including:
  - Duration, group size, difficulty level
  - Price per person
  - Multiple guides offering the tour
  - Ratings and reviews

### Expert Guides Screen
- View top-rated guides in your location
- Guide profiles showing:
  - Ratings and number of reviews
  - Experience level
  - Languages spoken
  - Equipment (camera, car, bike, drone)
  - Hourly/daily rates
  - Verified status

### Chat Screen (AI Assistant)
- Interactive chatbot for personalized recommendations
- Asks about destination and preferences
- Provides curated list of tours and guides
- Real-time recommendations based on user input

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── models/                        # Data models
│   ├── guide.dart                # Guide and User models
│   └── tour.dart                 # Tour and Category models
├── services/                      # Backend services
│   └── api_service.dart          # API client
├── providers/                     # State management
│   ├── location_provider.dart    # Location services
│   ├── tour_provider.dart        # Tour data management
│   └── guide_provider.dart       # Guide data management
└── screens/                       # UI screens
    ├── home_screen.dart          # Main home screen
    ├── tours_screen.dart         # Tours listing
    ├── experts_screen.dart       # Expert guides
    └── chat_screen.dart          # AI chatbot
```

## Setup Instructions

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- iOS Simulator / Android Emulator or physical device
- Backend API running (see ../backend/README.md)

### Installation

1. Navigate to the frontend directory:
```bash
cd frontend
```

2. Install dependencies:
```bash
flutter pub get
```

3. Update the API base URL in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:8000/api';
```
Replace `YOUR_IP` with your machine's IP address if testing on a physical device, or use `localhost` for emulators.

4. Run the app:
```bash
flutter run
```

### Platform-Specific Setup

#### iOS
Location permissions are required. The app already includes necessary configurations in `Info.plist`.

#### Android
Location permissions are required. The app already includes necessary configurations in `AndroidManifest.xml`.

## Dependencies

### UI & Design
- `google_fonts`: Custom typography
- `flutter_svg`: SVG icon support
- `cached_network_image`: Image caching

### State Management
- `provider`: State management solution

### Networking
- `http`: HTTP requests
- `dio`: Advanced HTTP client

### Location Services
- `geolocator`: GPS location
- `geocoding`: Reverse geocoding
- `google_maps_flutter`: Map integration

### Storage
- `shared_preferences`: Local data storage

### Chat
- `flutter_chat_ui`: Chat interface components

### Utilities
- `intl`: Internationalization and formatting
- `url_launcher`: Open URLs

## API Integration

The app connects to the Django REST API backend. All endpoints are defined in `api_service.dart`:

### Tours
- `getTours()`: Fetch all tours
- `getToursByLocation()`: Get tours in specific city
- `searchTours()`: Search tours by query

### Guides
- `getGuides()`: Fetch all guides
- `getExpertGuides()`: Get top-rated guides
- `getNearbyGuides()`: Find guides near location

### Categories
- `getCategories()`: Get all tour categories

### Chat
- `getChatRecommendations()`: Get AI-powered recommendations

## State Management

The app uses Provider for state management with three main providers:

1. **LocationProvider**: Manages user location and city selection
2. **TourProvider**: Handles tour data and search
3. **GuideProvider**: Manages guide data and filtering

## Customization

### Theme
Update the theme in `main.dart`:
```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF2196F3),  // Change primary color
    // ...
  ),
)
```

### API Configuration
Update the base URL in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://your-api-url/api';
```

## Testing

Run tests:
```bash
flutter test
```

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Troubleshooting

### Location Not Working
- Ensure location permissions are granted
- Check that location services are enabled on device
- For iOS simulator, set a custom location in Debug > Location

### API Connection Issues
- Verify backend is running
- Check the API base URL is correct
- For physical devices, use your machine's IP address, not localhost
- Ensure device and machine are on the same network

### Images Not Loading
- Verify image URLs from API are correct
- Check internet connection
- Ensure CORS is properly configured in backend

## Future Enhancements

- [ ] User authentication and profiles
- [ ] Booking payment integration
- [ ] Real-time chat with guides
- [ ] Review and rating submission
- [ ] Favorite tours and guides
- [ ] Offline mode with cached data
- [ ] Push notifications for bookings
- [ ] Map view of tours and guides
- [ ] Multi-language support
- [ ] Dark mode theme

## License

MIT License
