# Travel Guide Web Application

A modern, responsive web application for connecting travelers with verified local guides. Browse tours, discover expert guides, and get AI-powered recommendations for your next adventure.

## Features

- **Browse Tours**: Explore tours by category, location, difficulty, and price
- **Find Expert Guides**: Discover verified local guides with ratings, languages, and equipment
- **Smart Search**: Filter and search tours and guides with advanced filters
- **Location-Based**: Automatic location detection to find nearby tours and guides
- **AI Chat Assistant**: Get personalized tour and guide recommendations through an interactive chatbot
- **Responsive Design**: Works seamlessly on desktop, tablet, and mobile devices
- **Modern UI**: Beautiful, intuitive interface with smooth animations

## Technology Stack

- **Frontend**: Vanilla JavaScript (ES6+), HTML5, CSS3
- **Backend**: Django REST Framework (see [../backend/](../backend/))
- **APIs**:
  - Browser Geolocation API for location services
  - OpenStreetMap Nominatim for reverse geocoding
  - Django REST API for all data
- **Icons**: Font Awesome 6.4.0
- **No Framework Dependencies**: Pure JavaScript for maximum performance

## Project Structure

```
webapp/
├── index.html              # Main HTML file with all sections
├── css/
│   └── styles.css          # Complete styling with responsive design
├── js/
│   ├── api.js              # API client for backend communication
│   ├── location.js         # Location services (GPS, geocoding)
│   ├── ui.js               # UI utilities and component rendering
│   ├── tours.js            # Tours page controller
│   ├── guides.js           # Guides page controller
│   ├── chat.js             # AI chat controller
│   └── app.js              # Main application initialization
└── README.md               # This file
```

## Quick Start

### Prerequisites

1. **Backend Running**: Make sure the Django backend is running on `http://localhost:8000`
   ```bash
   cd ../backend
   python manage.py runserver
   ```

2. **Web Server**: You need a local web server to run the app (browsers block file:// for security)

### Option 1: Python HTTP Server (Recommended)

```bash
cd webapp
python3 -m http.server 3000
```

Then open: [http://localhost:3000](http://localhost:3000)

### Option 2: Node.js HTTP Server

```bash
cd webapp
npx http-server -p 3000
```

Then open: [http://localhost:3000](http://localhost:3000)

### Option 3: PHP Built-in Server

```bash
cd webapp
php -S localhost:3000
```

Then open: [http://localhost:3000](http://localhost:3000)

### Option 4: VS Code Live Server Extension

1. Install "Live Server" extension in VS Code
2. Right-click on `index.html`
3. Select "Open with Live Server"

## Configuration

### API Endpoint

The default API endpoint is set to `http://localhost:8000/api`. To change it, edit [js/api.js](js/api.js):

```javascript
const API_BASE_URL = 'http://your-backend-url:8000/api';
```

### CORS Settings

Make sure your Django backend allows requests from your web app origin. The backend should already be configured with CORS support in [../backend/travel_guide/settings.py](../backend/travel_guide/settings.py:125-132).

If you're running on a different port, update the backend settings:

```python
CORS_ALLOWED_ORIGINS = [
    'http://localhost:3000',
    'http://127.0.0.1:3000',
    # Add your custom origins here
]
```

## Usage Guide

### Home Page

- **Categories**: Click on any category to filter tours
- **Featured Tours**: Browse tours in your current location
- **Expert Guides**: View top-rated guides in your area
- **Get Location**: Click to use your GPS location for personalized results

### Tours Page

1. **Search**: Type keywords to search tour titles and descriptions
2. **Filters**:
   - Tour Type (Food, Bike, Cultural, etc.)
   - Difficulty Level (Easy, Moderate, Hard)
   - Sort by price, duration, or date
3. **Tour Cards**: Click any tour to see full details

### Experts Page

1. **Search**: Find guides by name, location, or languages
2. **Filters**:
   - Verified guides only
   - Equipment (Camera, Car, Bike, Drone)
3. **Guide Cards**: Click any guide to see their full profile

### AI Chat Assistant

1. Navigate to the Chat section
2. Tell the chatbot:
   - Which city you're visiting
   - What activities you're interested in
3. Get personalized tour and guide recommendations
4. Click on recommendations to see details

## Features Breakdown

### Location Services

The app uses browser Geolocation API to:
- Detect your current location automatically
- Find nearby tours and guides
- Show relevant content for your area
- Use OpenStreetMap for city/country lookup

**Note**: You'll need to allow location access when prompted by your browser.

### Search & Filtering

**Tours:**
- Full-text search across title, description, and location
- Filter by tour type, difficulty, city
- Sort by price, duration, or date
- Real-time results as you type

**Guides:**
- Search by name, description, city, languages
- Filter by verification status
- Filter by available equipment
- Show only available guides

### Modals

Click on any tour or guide card to see a detailed modal with:
- **Tours**: Full description, duration, group size, price, meeting point, guides
- **Guides**: Bio, experience, ratings, languages, equipment, rates

### Responsive Design

The app adapts to all screen sizes:
- **Desktop** (1200px+): Multi-column grids, full navigation
- **Tablet** (768px-1199px): Adjusted grids, collapsible filters
- **Mobile** (< 768px): Single column, stacked navigation, touch-optimized

## API Endpoints Used

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/categories/` | GET | Get all tour categories |
| `/api/tours/` | GET | Get tours with filters |
| `/api/tours/{id}/` | GET | Get tour details |
| `/api/tours/by_category/` | GET | Tours by category |
| `/api/tours/by_location/` | GET | Tours in specific city |
| `/api/tours/nearby/` | GET | Tours within radius |
| `/api/guides/` | GET | Get guides with filters |
| `/api/guides/{id}/` | GET | Get guide details |
| `/api/guides/experts/` | GET | Top-rated guides by city |
| `/api/guides/nearby/` | GET | Guides within radius |
| `/api/chat-recommendations/get_recommendations/` | POST | AI recommendations |

## Browser Support

- Chrome 90+ ✅
- Firefox 88+ ✅
- Safari 14+ ✅
- Edge 90+ ✅

**Required Features:**
- ES6+ JavaScript (Classes, async/await, arrow functions)
- CSS Grid & Flexbox
- Fetch API
- Geolocation API

## Development

### File Organization

The codebase follows a modular pattern:

- **api.js**: Handles all HTTP requests to backend
- **location.js**: GPS and geocoding services
- **ui.js**: Reusable UI components and rendering
- **tours.js**: Tours page logic and state
- **guides.js**: Guides page logic and state
- **chat.js**: Chatbot conversation logic
- **app.js**: Main application orchestration

### Adding New Features

1. **New API Endpoint**: Add method to `APIClient` class in [js/api.js](js/api.js)
2. **New UI Component**: Add to `UIManager` class in [js/ui.js](js/ui.js)
3. **New Page**: Create controller class similar to [js/tours.js](js/tours.js)

### Debugging

Open browser Developer Tools (F12) to:
- View console logs for API calls and errors
- Inspect network requests to backend
- Check responsive design in device emulation mode

## Performance

- **Lazy Loading**: Images load on-demand with fallbacks
- **Debounced Search**: 500ms delay to reduce API calls
- **Minimal Dependencies**: No heavy frameworks
- **Efficient Rendering**: Only updates changed elements

## Security

- All user input is sanitized when rendering
- CORS properly configured between frontend and backend
- Location access requires explicit user permission
- No sensitive data stored in localStorage

## Troubleshooting

### "Failed to load tours/guides"

**Cause**: Backend not running or CORS issue

**Solution**:
1. Ensure Django backend is running: `cd ../backend && python manage.py runserver`
2. Check browser console for specific error
3. Verify CORS settings in Django

### "Location not working"

**Cause**: Browser permissions or HTTPS requirement

**Solution**:
1. Allow location access when prompted
2. Some browsers require HTTPS for geolocation (localhost is exempt)
3. Fallback to default city (New York) if location fails

### "Blank page or JS errors"

**Cause**: Not using a web server, using file:// protocol

**Solution**:
1. Must run through a web server (see Quick Start)
2. Cannot open `index.html` directly in browser

### Images not loading

**Cause**: Backend media files not configured or missing

**Solution**:
1. Placeholder images will show automatically
2. Check Django `MEDIA_ROOT` and `MEDIA_URL` settings
3. Ensure `python manage.py runserver` serves media files

## Deployment

### Frontend Deployment

Deploy to any static hosting service:

**Netlify:**
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
cd webapp
netlify deploy --prod
```

**GitHub Pages:**
```bash
# Push webapp directory to gh-pages branch
git subtree push --prefix webapp origin gh-pages
```

**Vercel:**
```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
cd webapp
vercel --prod
```

**Important**: Update `API_BASE_URL` in [js/api.js](js/api.js) to your production backend URL before deploying.

### Backend Deployment

See [../backend/README.md](../backend/README.md) for backend deployment instructions.

## Next Steps

Possible enhancements:

- [ ] User authentication and profiles
- [ ] Booking system with payment integration
- [ ] Review submission functionality
- [ ] Real-time chat with guides
- [ ] Tour calendar and availability
- [ ] Favorites and wishlists
- [ ] Social sharing
- [ ] Multi-language support
- [ ] Google Maps integration for tours
- [ ] Photo galleries for tours

## Support

For issues or questions:

1. Check the [backend README](../backend/README.md)
2. Review browser console for errors
3. Ensure all prerequisites are met
4. Verify backend is running and accessible

## License

This project is part of the Travel Guide App. See main project README for license information.

---

**Built with ❤️ using Vanilla JavaScript**
