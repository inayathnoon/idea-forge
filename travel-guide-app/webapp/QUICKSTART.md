# Quick Start Guide - Travel Guide Web App

## 🚀 Get Started in 3 Steps

### Step 1: Start the Backend

```bash
cd travel-guide-app/backend
python manage.py runserver
```

Keep this terminal running. Backend will be at: [http://localhost:8000](http://localhost:8000)

### Step 2: Start the Web App

Open a **new terminal**:

```bash
cd travel-guide-app/webapp
python3 -m http.server 3000
```

### Step 3: Open in Browser

Visit: [http://localhost:3000](http://localhost:3000)

**That's it!** 🎉

---

## 📱 What You'll See

### Home Page
- 📍 **Location Detection**: Automatically finds your city
- 🗂️ **Categories**: Food, Bike, Cultural, Adventure tours
- 🎯 **Featured Tours**: Tours in your area
- ⭐ **Expert Guides**: Top-rated local guides
- 🤖 **AI Chat**: Get personalized recommendations

### Tours Page
- 🔍 **Search**: Find tours by keywords
- 🎛️ **Filters**: Type, difficulty, price sorting
- 🖼️ **Tour Cards**: Click to see details, prices, duration

### Experts Page
- 🔍 **Search**: Find guides by name, location, language
- ✅ **Filters**: Verified guides, equipment (camera, car, bike)
- 👤 **Guide Profiles**: Experience, ratings, rates

### AI Chat
- 💬 **Interactive**: Tell it where you're going
- 🎯 **Smart**: Recommends tours based on your interests
- ⚡ **Instant**: Get personalized results in seconds

---

## 🛠️ Troubleshooting

### Backend Not Running?
```bash
cd backend
python manage.py migrate    # Run migrations first
python manage.py runserver  # Then start server
```

### Port 3000 Already in Use?
```bash
python3 -m http.server 8080  # Use different port
# Then visit http://localhost:8080
```

### Location Not Working?
- Click "Allow" when browser asks for location permission
- Or manually browse by city using search/filters

### No Data Showing?
1. ✅ Check backend is running at [http://localhost:8000/api/tours/](http://localhost:8000/api/tours/)
2. ✅ Check browser console (F12) for errors
3. ✅ Make sure you're using `http://localhost:3000` (not `file://`)

---

## 📖 Key Features

| Feature | Description |
|---------|-------------|
| **Responsive Design** | Works on desktop, tablet, mobile |
| **Real-time Search** | Instant results as you type |
| **Location-Based** | GPS-powered nearby tours/guides |
| **AI Recommendations** | Chatbot suggests personalized tours |
| **Modal Details** | Click cards for full information |
| **Advanced Filters** | Filter by type, difficulty, equipment |

---

## 🎨 Technology

- **Frontend**: Pure JavaScript (No frameworks!)
- **Styling**: Modern CSS3 with Grid & Flexbox
- **Backend API**: Django REST Framework
- **Location**: Browser Geolocation + OpenStreetMap
- **Icons**: Font Awesome 6.4.0

---

## 📂 Project Structure

```
webapp/
├── index.html           # Main page (239 lines)
├── css/
│   └── styles.css       # All styling (868 lines)
├── js/
│   ├── api.js          # Backend communication (105 lines)
│   ├── location.js     # GPS services (108 lines)
│   ├── ui.js           # UI components (414 lines)
│   ├── tours.js        # Tours page logic (105 lines)
│   ├── guides.js       # Guides page logic (117 lines)
│   ├── chat.js         # AI chatbot (216 lines)
│   └── app.js          # Main app init (112 lines)
└── README.md            # Full documentation

Total: 2,284 lines of code ✨
```

---

## 🎯 Next Steps

1. ✅ **Browse Tours**: Click on any tour to see details
2. ✅ **Find Guides**: Explore expert local guides
3. ✅ **Try AI Chat**: Get personalized recommendations
4. ✅ **Use Location**: Allow GPS for nearby results
5. ✅ **Test Filters**: Search and filter to find perfect tours

---

## 💡 Pro Tips

- **Mobile Testing**: Open DevTools (F12) → Toggle device toolbar
- **API Testing**: Visit [http://localhost:8000/api/](http://localhost:8000/api/)
- **Admin Panel**: Go to [http://localhost:8000/admin/](http://localhost:8000/admin/) (if backend has data)
- **Reload Data**: Refresh page to reset filters and search

---

## 📞 Need Help?

1. Check [README.md](README.md) for detailed documentation
2. Review browser console (F12) for error messages
3. Ensure both backend and frontend servers are running
4. Verify you're accessing via web server (not `file://`)

---

**Happy Traveling! 🌍✈️**
