# Travel Guide App - Backend API

Django REST Framework backend for the Travel Guide mobile application that connects travelers with local guides.

## Features

- **Guide Management**: Local guide profiles with ratings, equipment, and availability
- **Tour Catalog**: Browse tours by type, location, and categories
- **Location-based Search**: Find guides and tours near your location
- **Reviews & Ratings**: User reviews for guides and tours
- **Booking System**: Request and manage tour bookings
- **AI Recommendations**: Personalized tour suggestions via chatbot
- **Expert Guides**: Top-rated guides sorted by location

## API Endpoints

### Categories
- `GET /api/categories/` - List all tour categories
- `GET /api/categories/{id}/` - Get category details

### Guides
- `GET /api/guides/` - List all guides (filterable)
- `GET /api/guides/{id}/` - Get guide details with reviews
- `GET /api/guides/nearby/` - Find guides near location (params: latitude, longitude, radius)
- `GET /api/guides/experts/` - Get top-rated guides (params: city)

### Tours
- `GET /api/tours/` - List all tours (filterable)
- `GET /api/tours/{id}/` - Get tour details
- `GET /api/tours/by_category/` - Filter tours by category (params: category_id)
- `GET /api/tours/by_location/` - Get tours in city (params: city)
- `GET /api/tours/nearby/` - Find tours near location (params: latitude, longitude, radius)

### Reviews
- `GET /api/reviews/` - List all reviews
- `POST /api/reviews/` - Create a new review
- `GET /api/reviews/{id}/` - Get review details
- `PUT /api/reviews/{id}/` - Update review
- `DELETE /api/reviews/{id}/` - Delete review

### Bookings
- `GET /api/bookings/` - List bookings
- `POST /api/bookings/` - Create booking request
- `GET /api/bookings/{id}/` - Get booking details
- `PUT /api/bookings/{id}/` - Update booking
- `DELETE /api/bookings/{id}/` - Cancel booking

### Chat Recommendations
- `POST /api/chat-recommendations/get_recommendations/` - Get AI-powered tour recommendations

## Setup Instructions

### Prerequisites
- Python 3.10+
- pip
- virtualenv (recommended)

### Installation

1. Create and activate virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Create environment file:
```bash
cp .env.example .env
```

4. Update settings in `.env` file (set SECRET_KEY, etc.)

5. Run migrations:
```bash
python manage.py makemigrations
python manage.py migrate
```

6. Create superuser:
```bash
python manage.py createsuperuser
```

7. Run development server:
```bash
python manage.py runserver
```

The API will be available at `http://localhost:8000/api/`

Admin panel: `http://localhost:8000/admin/`

## Database Models

### User
Custom user model with profile information

### Guide
- Location (city, country, coordinates)
- Description and languages
- Equipment (camera, car, bike, drone)
- Pricing (hourly/daily rates)
- Verification status

### Tour
- Tour details (title, description, type)
- Location and meeting point
- Duration, group size, difficulty
- Pricing and images
- Associated guides and categories

### Category
Tour categories (food, bike, cultural, adventure, etc.)

### Review
Ratings and reviews for guides and tours

### Booking
Tour booking requests and management

### ChatRecommendation
AI chatbot conversation history and recommendations

## Filtering & Search

Most endpoints support filtering, searching, and ordering:

**Guides:**
- Filter by: city, country, is_verified, has_camera, has_car, has_bike
- Search: name, description, city, languages
- Order by: hourly_rate, experience_years

**Tours:**
- Filter by: tour_type, city, country, difficulty_level
- Search: title, description, city
- Order by: price_per_person, duration_hours, created_at

**Example:**
```
GET /api/guides/?city=Paris&has_camera=true&ordering=-experience_years
GET /api/tours/?tour_type=food&city=Tokyo&search=sushi
```

## Development

### Running Tests
```bash
python manage.py test
```

### Creating Sample Data
Use Django admin panel or create a management command to populate sample data.

## Production Deployment

1. Set `DEBUG=False` in .env
2. Configure proper SECRET_KEY
3. Set up PostgreSQL database
4. Configure ALLOWED_HOSTS
5. Set up static file serving
6. Use a production WSGI server (gunicorn, uWSGI)
7. Set up HTTPS

## Technology Stack

- Django 5.0
- Django REST Framework
- PostgreSQL (production) / SQLite (development)
- GeoPy for location calculations
- Pillow for image handling
