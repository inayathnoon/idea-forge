# Quick Start Guide

Get your Travel Guide app up and running in minutes!

## Prerequisites

Make sure you have installed:
- Python 3.10+ ([Download](https://www.python.org/downloads/))
- Flutter SDK 3.0+ ([Install Guide](https://docs.flutter.dev/get-started/install))
- Git

## Step 1: Clone or Navigate to Project

```bash
cd travel-guide-app
```

## Step 2: Backend Setup (5 minutes)

### Option A: Using Setup Script (Mac/Linux)

```bash
cd backend
./setup.sh
```

### Option B: Manual Setup (All Platforms)

```bash
cd backend

# Create and activate virtual environment
python -m venv venv

# Mac/Linux:
source venv/bin/activate
# Windows:
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Create environment file
cp .env.example .env

# Run migrations
python manage.py makemigrations
python manage.py migrate

# Create admin user
python manage.py createsuperuser

# Start server
python manage.py runserver
```

Your backend is now running at `http://localhost:8000`!

## Step 3: Add Sample Data (Optional but Recommended)

1. Open your browser and go to `http://localhost:8000/admin`
2. Log in with your superuser credentials
3. Add some sample data:
   - **Categories**: Food Tasting, Bike Trip, Cultural, Adventure
   - **Users**: Create a few users to act as guides
   - **Guides**: Create guide profiles for the users
   - **Tours**: Add some tours and associate them with guides

## Step 4: Frontend Setup (5 minutes)

Open a new terminal window:

```bash
cd frontend

# Install Flutter dependencies
flutter pub get

# Check Flutter installation
flutter doctor
```

## Step 5: Configure API Connection

1. Find your machine's IP address:
   - **Mac/Linux**: Run `ifconfig | grep "inet " | grep -v 127.0.0.1`
   - **Windows**: Run `ipconfig`

2. Open `frontend/lib/services/api_service.dart`

3. Update the `baseUrl`:
   ```dart
   // For iOS Simulator or Android Emulator:
   static const String baseUrl = 'http://localhost:8000/api';

   // For Physical Device (replace with your IP):
   static const String baseUrl = 'http://YOUR_IP_ADDRESS:8000/api';
   ```

## Step 6: Run the Flutter App

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>

# Or just run (will ask you to choose)
flutter run
```

## Step 7: Test the App

### On Home Screen:
1. Tap the location button (top right) to get your current location
2. Browse the 4 main sections:
   - **Interested In**: Tap categories to filter tours
   - **Tours**: Scroll through available tours
   - **Expert Guides**: View top-rated guides
   - **Personalized Tour**: Try the AI chatbot

### Test Search:
1. Tap the search bar
2. Type a city name or tour type
3. View filtered results

### Try the Chatbot:
1. Tap "Personalized Tour" button
2. Enter a city name when asked
3. Enter your interests (e.g., "food and culture")
4. View personalized recommendations

## Troubleshooting

### Backend Issues

**Problem**: `ModuleNotFoundError` when running server
```bash
# Make sure virtual environment is activated
source venv/bin/activate  # Mac/Linux
venv\Scripts\activate     # Windows

# Reinstall dependencies
pip install -r requirements.txt
```

**Problem**: Database errors
```bash
# Delete database and start fresh
rm db.sqlite3
python manage.py makemigrations
python manage.py migrate
```

### Frontend Issues

**Problem**: Cannot connect to API
- Verify backend is running (`http://localhost:8000/api/`)
- Check API URL in `api_service.dart`
- For physical devices, use your machine's IP address, not `localhost`
- Ensure device and computer are on same WiFi network

**Problem**: Location not working
- Grant location permissions when prompted
- For iOS Simulator: Debug > Location > Custom Location
- For Android Emulator: Use emulator controls to set location

**Problem**: Images not loading
- Verify image URLs in admin panel
- Check backend media files are being served correctly
- Test API endpoint directly in browser

## Next Steps

### Add More Sample Data
Visit the admin panel at `http://localhost:8000/admin` and add:
- More categories
- More guides with different equipment and rates
- More tours in various cities
- Sample reviews for tours and guides

### Explore Features
- Browse tours by category
- View guide profiles with ratings
- Test the search functionality
- Try the AI chatbot for recommendations
- Check out tour and guide details

### Customize
- Update theme colors in `frontend/lib/main.dart`
- Modify tour categories
- Add your own cities and locations
- Create custom tour types

## Project URLs

- **Backend API**: http://localhost:8000/api/
- **Admin Panel**: http://localhost:8000/admin/
- **API Documentation**: Check the README files for endpoint details

## Getting Help

If you encounter issues:

1. Check the READMEs:
   - Main: `README.md`
   - Backend: `backend/README.md`
   - Frontend: `frontend/README.md`

2. Common commands:
   ```bash
   # Backend
   python manage.py runserver     # Start server
   python manage.py migrate       # Run migrations
   python manage.py createsuperuser  # Create admin user

   # Frontend
   flutter pub get               # Install dependencies
   flutter run                   # Run app
   flutter clean                 # Clean build files
   ```

3. Verify installations:
   ```bash
   python --version              # Should be 3.10+
   flutter --version             # Should be 3.0+
   flutter doctor               # Check Flutter setup
   ```

## Quick Reference

### Backend Commands
```bash
cd backend
source venv/bin/activate
python manage.py runserver
```

### Frontend Commands
```bash
cd frontend
flutter run
```

### Stop Everything
- Backend: Press `Ctrl+C` in backend terminal
- Frontend: Press `q` in Flutter terminal or `Ctrl+C`

Enjoy building with the Travel Guide App! 🚀
