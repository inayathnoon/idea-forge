# Travel Guide App

A full-stack mobile application connecting travelers with local guides for personalized tours and experiences.

## Overview

This application helps travelers discover authentic local experiences by connecting them with verified local guides. Users can browse tours, find expert guides, and get personalized recommendations through an AI-powered chatbot.

## Key Features

- **Local Guide Marketplace**: Connect with verified local guides in any city
- **Tour Discovery**: Browse tours by category (food, bike, cultural, adventure, etc.)
- **Location-Based Search**: Find tours and guides near your current location
- **Expert Guides**: View top-rated guides with ratings, reviews, and detailed profiles
- **AI Recommendations**: Personalized tour suggestions via interactive chatbot
- **Guide Profiles**: Detailed information including equipment, languages, experience
- **Booking System**: Request and manage tour bookings

## Architecture

This is a full-stack application with:

- **Backend**: Django REST Framework API
- **Frontend**: Flutter mobile app (iOS & Android)
- **Database**: PostgreSQL (production) / SQLite (development)

## Project Structure

```
travel-guide-app/
├── backend/              # Django REST Framework API
│   ├── api/             # Main API app
│   ├── travel_guide/    # Django project settings
│   ├── requirements.txt
│   └── README.md
├── frontend/            # Flutter mobile app
│   ├── lib/
│   │   ├── models/     # Data models
│   │   ├── services/   # API services
│   │   ├── providers/  # State management
│   │   └── screens/    # UI screens
│   ├── pubspec.yaml
│   └── README.md
└── README.md           # This file
```

## Quick Start

### Prerequisites

- Python 3.10+
- Flutter SDK 3.0+
- PostgreSQL (for production) or SQLite (for development)

### Backend Setup

1. Navigate to backend directory:
```bash
cd backend
```

2. Create virtual environment and install dependencies:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

3. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your settings
```

4. Run migrations:
```bash
python manage.py makemigrations
python manage.py migrate
```

5. Create superuser:
```bash
python manage.py createsuperuser
```

6. Start development server:
```bash
python manage.py runserver
```

The API will be available at `http://localhost:8000/api/`

### Frontend Setup

1. Navigate to frontend directory:
```bash
cd frontend
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. Update API URL in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:8000/api';
```

4. Run the app:
```bash
flutter run
```

## User Flow

### 1. Home Screen
- User opens app and grants location permission
- App displays current city
- Four main sections are presented:
  - **Interested In**: Categories (Food, Bike, Cultural, Adventure)
  - **Tours**: Carousel of available tours
  - **Expert Guides**: Top-rated guides in the area
  - **Personalized Tour**: AI chatbot button

### 2. Browse Tours
- User can tap on categories to filter tours
- Or use search bar to find specific tours
- Tap on a tour to view full details
- See multiple guides offering each tour
- View pricing, duration, difficulty, and reviews

### 3. Discover Expert Guides
- Browse top-rated guides in current location
- View guide profiles with:
  - Ratings and review count
  - Experience and languages
  - Equipment (camera, car, bike, drone)
  - Hourly and daily rates
  - Verification status

### 4. Get Personalized Recommendations
- Tap "Personalized Tour" to open AI chatbot
- Chat specifies destination city
- User shares interests (food, culture, adventure, etc.)
- AI provides curated list of tours and guides
- User can tap recommendations to view details

### 5. Book a Tour/Guide
- User selects a tour or guide
- Views full details and pricing
- Taps "Book Now" or "Book Guide"
- Submits booking request

## API Endpoints

### Categories
- `GET /api/categories/` - List all categories

### Tours
- `GET /api/tours/` - List tours (with filters)
- `GET /api/tours/{id}/` - Tour details
- `GET /api/tours/by_location/?city={city}` - Tours by city
- `GET /api/tours/nearby/?latitude={lat}&longitude={lon}` - Nearby tours

### Guides
- `GET /api/guides/` - List guides (with filters)
- `GET /api/guides/{id}/` - Guide details
- `GET /api/guides/experts/?city={city}` - Top-rated guides
- `GET /api/guides/nearby/?latitude={lat}&longitude={lon}` - Nearby guides

### Reviews
- `GET /api/reviews/` - List reviews
- `POST /api/reviews/` - Create review

### Bookings
- `GET /api/bookings/` - List bookings
- `POST /api/bookings/` - Create booking

### Chat
- `POST /api/chat-recommendations/get_recommendations/` - Get AI recommendations

## Database Schema

### Core Models

**User** - Custom user model with profile info

**Guide** - Local guide profiles
- User (one-to-one)
- Location (city, country, coordinates)
- Description, languages, experience
- Equipment (camera, car, bike, drone)
- Rates (hourly, daily)
- Verification status

**Tour** - Tours offered by guides
- Title, description, type
- Location and meeting point
- Duration, group size, difficulty
- Pricing and images
- Associated guides and categories

**Category** - Tour categories (food, bike, cultural, etc.)

**Review** - Ratings and reviews for guides/tours

**Booking** - Tour booking requests

**ChatRecommendation** - AI chatbot conversations and recommendations

## Technology Stack

### Backend
- Django 5.0
- Django REST Framework
- PostgreSQL / SQLite
- GeoPy (location calculations)
- CORS Headers

### Frontend
- Flutter 3.0+
- Provider (state management)
- HTTP/Dio (networking)
- Geolocator (GPS)
- Google Maps Flutter
- Cached Network Image

## Development

### Running Tests

Backend:
```bash
cd backend
python manage.py test
```

Frontend:
```bash
cd frontend
flutter test
```

### Admin Panel

Access Django admin at `http://localhost:8000/admin/`

Use this to:
- Add sample tours and guides
- Manage categories
- View bookings and reviews
- Verify guides

## Deployment

### Backend Deployment

1. Set up production database (PostgreSQL)
2. Configure environment variables
3. Set `DEBUG=False`
4. Collect static files: `python manage.py collectstatic`
5. Use gunicorn or uWSGI as WSGI server
6. Set up nginx as reverse proxy
7. Configure HTTPS with Let's Encrypt

### Frontend Deployment

Build release versions:

Android:
```bash
cd frontend
flutter build apk --release
```

iOS:
```bash
cd frontend
flutter build ios --release
```

## Future Enhancements

- [ ] User authentication (JWT tokens)
- [ ] Payment integration (Stripe/PayPal)
- [ ] Real-time messaging between users and guides
- [ ] Push notifications for bookings
- [ ] Advanced AI recommendations with ML models
- [ ] Social features (share tours, follow guides)
- [ ] Multi-language support
- [ ] Calendar integration
- [ ] Weather information
- [ ] Offline mode
- [ ] Video calls with guides
- [ ] Tour packages and deals
- [ ] Loyalty rewards program

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write tests
5. Submit a pull request

## License

MIT License

## Support

For issues and questions:
- Backend: See `backend/README.md`
- Frontend: See `frontend/README.md`

## Screenshots

(Add screenshots of your app here once it's running)

## Contact

For more information or collaboration opportunities, please reach out!
