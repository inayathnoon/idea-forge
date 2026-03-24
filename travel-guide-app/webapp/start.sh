#!/bin/bash

# Travel Guide Web App - Quick Start Script

echo "🚀 Starting Travel Guide Web App..."
echo ""

# Check if backend is running
echo "📡 Checking backend..."
if curl -s http://localhost:8000/api/tours/ > /dev/null 2>&1; then
    echo "✅ Backend is running at http://localhost:8000"
else
    echo "⚠️  Backend is NOT running!"
    echo ""
    echo "Please start the backend first:"
    echo "  cd ../backend"
    echo "  python manage.py runserver"
    echo ""
    read -p "Press Enter when backend is ready..."
fi

echo ""
echo "🌐 Starting web server on port 3000..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🎉 Web App Running!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Open in browser:"
echo "  👉 http://localhost:3000"
echo ""
echo "  Press Ctrl+C to stop"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Start Python HTTP server
python3 -m http.server 3000
