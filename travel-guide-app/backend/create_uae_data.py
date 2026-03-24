#!/usr/bin/env python
"""Create real UAE tour data for the Travel Guide app"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'travel_guide.settings')
django.setup()

from api.models import User, Category, Guide, Tour

print("🇦🇪 Creating UAE tour data...")

# Create users (tour guides)
print("👥 Creating tour guides...")

guides_data = [
    {
        'username': 'ahmed_dubai',
        'email': 'ahmed@uaeguides.com',
        'first_name': 'Ahmed',
        'last_name': 'Al Maktoum',
        'city': 'Dubai',
        'country': 'UAE',
        'lat': 25.2048,
        'lon': 55.2708,
        'description': 'Born and raised in Dubai, I have 10 years of experience showing tourists the magic of the city. Certified desert safari guide and professional photographer.',
        'languages': 'Arabic, English, Hindi, Urdu',
        'experience': 10,
        'camera': True,
        'car': True,
        'bike': False,
        'drone': True,
        'hourly': 85.00,
        'daily': 600.00
    },
    {
        'username': 'fatima_abudhabi',
        'email': 'fatima@uaeguides.com',
        'first_name': 'Fatima',
        'last_name': 'Al Nahyan',
        'city': 'Abu Dhabi',
        'country': 'UAE',
        'lat': 24.4539,
        'lon': 54.3773,
        'description': 'Cultural heritage specialist and certified tour guide. Expert in Islamic architecture and Emirati traditions with 8 years experience.',
        'languages': 'Arabic, English, French',
        'experience': 8,
        'camera': True,
        'car': True,
        'bike': False,
        'drone': False,
        'hourly': 75.00,
        'daily': 550.00
    },
    {
        'username': 'rashid_adventure',
        'email': 'rashid@uaeguides.com',
        'first_name': 'Rashid',
        'last_name': 'Mohammed',
        'city': 'Dubai',
        'country': 'UAE',
        'lat': 25.1972,
        'lon': 55.2744,
        'description': 'Adventure specialist with 12 years in desert safaris, dune bashing, and extreme sports. Licensed 4x4 driver and safety instructor.',
        'languages': 'Arabic, English, German',
        'experience': 12,
        'camera': True,
        'car': True,
        'bike': True,
        'drone': True,
        'hourly': 90.00,
        'daily': 650.00
    },
    {
        'username': 'layla_foodie',
        'email': 'layla@uaeguides.com',
        'first_name': 'Layla',
        'last_name': 'Hassan',
        'city': 'Dubai',
        'country': 'UAE',
        'lat': 25.2048,
        'lon': 55.2708,
        'description': 'Food tour specialist and culinary expert. Passionate about Emirati cuisine and Middle Eastern flavors with 6 years guiding food tours.',
        'languages': 'Arabic, English, Spanish',
        'experience': 6,
        'camera': True,
        'car': False,
        'bike': False,
        'drone': False,
        'hourly': 70.00,
        'daily': 500.00
    },
    {
        'username': 'omar_marina',
        'email': 'omar@uaeguides.com',
        'first_name': 'Omar',
        'last_name': 'Abdullah',
        'city': 'Dubai',
        'country': 'UAE',
        'lat': 25.0770,
        'lon': 55.1347,
        'description': 'Marine tourism expert specializing in dhow cruises and water activities. Licensed boat captain with 9 years experience.',
        'languages': 'Arabic, English, Russian',
        'experience': 9,
        'camera': True,
        'car': False,
        'bike': False,
        'drone': False,
        'hourly': 80.00,
        'daily': 580.00
    }
]

user_guide_map = {}
for guide_data in guides_data:
    user = User.objects.create_user(
        username=guide_data['username'],
        email=guide_data['email'],
        password='password123',
        first_name=guide_data['first_name'],
        last_name=guide_data['last_name']
    )

    guide = Guide.objects.create(
        user=user,
        city=guide_data['city'],
        country=guide_data['country'],
        latitude=guide_data['lat'],
        longitude=guide_data['lon'],
        description=guide_data['description'],
        languages=guide_data['languages'],
        experience_years=guide_data['experience'],
        has_camera=guide_data['camera'],
        has_car=guide_data['car'],
        has_bike=guide_data['bike'],
        has_drone=guide_data['drone'],
        hourly_rate=guide_data['hourly'],
        daily_rate=guide_data['daily'],
        is_verified=True,
        is_available=True
    )
    user_guide_map[guide_data['username']] = guide

# Create categories
print("📁 Creating categories...")
categories = {
    'adventure': Category.objects.create(
        name='Adventure & Desert Safari',
        description='Thrilling desert experiences, dune bashing, and adventure sports'
    ),
    'cultural': Category.objects.create(
        name='Cultural & Heritage',
        description='Explore UAE culture, traditions, and historical sites'
    ),
    'food': Category.objects.create(
        name='Food & Dining',
        description='Culinary tours and authentic Middle Eastern cuisine'
    ),
    'luxury': Category.objects.create(
        name='Luxury Experiences',
        description='Premium tours and VIP experiences'
    ),
    'water': Category.objects.create(
        name='Water Activities',
        description='Marina cruises, dhow dinners, and water sports'
    ),
    'architecture': Category.objects.create(
        name='Modern Architecture',
        description='Iconic buildings and contemporary landmarks'
    ),
}

# Create real UAE tours based on research
print("🎯 Creating authentic UAE tours...")

tours_data = [
    {
        'title': 'Dubai Desert Safari with Dune Bashing & BBQ Dinner',
        'description': 'Experience the ultimate desert adventure! Includes thrilling 4x4 dune bashing, camel riding, sandboarding, traditional henna painting, belly dance show, Tanoura performance, fire show, and authentic BBQ buffet dinner under the stars.',
        'type': 'adventure',
        'categories': ['adventure', 'cultural', 'food'],
        'city': 'Dubai',
        'country': 'UAE',
        'meeting': 'Hotel pickup from Dubai',
        'lat': 25.0833,
        'lon': 55.7500,
        'duration': 6.0,
        'max_group': 15,
        'min_age': 5,
        'difficulty': 'moderate',
        'price': 130.00,
        'guide': 'rashid_adventure'
    },
    {
        'title': 'Premium Morning Desert Safari with Breakfast',
        'description': 'Start your day with sunrise desert adventure! Enjoy dune bashing, sand boarding, camel riding, and falconry experience followed by traditional Arabic breakfast at a Bedouin camp.',
        'type': 'adventure',
        'categories': ['adventure', 'cultural'],
        'city': 'Dubai',
        'country': 'UAE',
        'meeting': 'Hotel pickup - Dubai',
        'lat': 25.0833,
        'lon': 55.7500,
        'duration': 4.0,
        'max_group': 12,
        'min_age': 8,
        'difficulty': 'moderate',
        'price': 175.00,
        'guide': 'rashid_adventure'
    },
    {
        'title': 'Burj Khalifa: At The Top - Sky Level 124 & 125',
        'description': 'Visit the world\'s tallest building! Fast-track access to observation decks on floors 124 and 125 with breathtaking 360-degree views of Dubai. Learn about Dubai\'s transformation with multimedia presentations.',
        'type': 'cultural',
        'categories': ['architecture', 'luxury'],
        'city': 'Dubai',
        'country': 'UAE',
        'meeting': 'Burj Khalifa Entrance',
        'lat': 25.1972,
        'lon': 55.2744,
        'duration': 2.0,
        'max_group': 20,
        'min_age': 0,
        'difficulty': 'easy',
        'price': 173.00,
        'guide': 'ahmed_dubai'
    },
    {
        'title': 'Sheikh Zayed Grand Mosque Tour from Dubai',
        'description': 'Visit the stunning Sheikh Zayed Grand Mosque in Abu Dhabi - one of the world\'s largest mosques. Marvel at pristine white marble, gold chandeliers, and the world\'s largest hand-knotted carpet. Includes guided tour, modest dress code assistance, and return transfers.',
        'type': 'cultural',
        'categories': ['cultural', 'architecture'],
        'city': 'Abu Dhabi',
        'country': 'UAE',
        'meeting': 'Dubai Hotel Pickup',
        'lat': 24.4128,
        'lon': 54.4747,
        'duration': 5.5,
        'max_group': 25,
        'min_age': 0,
        'difficulty': 'easy',
        'price': 158.00,
        'guide': 'fatima_abudhabi'
    },
    {
        'title': 'Dubai Marina Dhow Cruise Dinner with Live Entertainment',
        'description': '2-hour traditional wooden dhow cruise along Dubai Marina with stunning skyscraper views. Enjoy international buffet dinner, unlimited soft drinks, live Tanoura show, traditional music, and romantic atmosphere perfect for couples and families.',
        'type': 'food',
        'categories': ['water', 'food', 'cultural'],
        'city': 'Dubai',
        'country': 'UAE',
        'meeting': 'Dubai Marina Walk',
        'lat': 25.0770,
        'lon': 55.1347,
        'duration': 2.0,
        'max_group': 30,
        'min_age': 0,
        'difficulty': 'easy',
        'price': 120.00,
        'guide': 'omar_marina'
    },
    {
        'title': 'Old Dubai Walking Tour: Souks, Creek & Heritage',
        'description': 'Explore historic Dubai on foot! Visit the Gold Souk, Spice Souk, and Textile markets. Traditional abra boat ride across Dubai Creek. Discover Al Fahidi Historical District with wind-tower houses, Dubai Museum, and authentic Emirati architecture.',
        'type': 'cultural',
        'categories': ['cultural', 'architecture'],
        'city': 'Dubai',
        'country': 'UAE',
        'meeting': 'Gold Souk Entrance',
        'lat': 25.2691,
        'lon': 55.2967,
        'duration': 3.0,
        'max_group': 15,
        'min_age': 8,
        'difficulty': 'easy',
        'price': 95.00,
        'guide': 'ahmed_dubai'
    },
    {
        'title': 'Dubai Food Tour: Emirati Cuisine & Local Flavors',
        'description': 'Taste authentic Emirati cuisine and Middle Eastern delicacies! Visit 6 local eateries, try Al Harees, Machboos, Luqaimat, Arabic coffee, dates, and shawarma. Learn about food traditions and culture from a local foodie guide.',
        'type': 'food',
        'categories': ['food', 'cultural'],
        'city': 'Dubai',
        'country': 'UAE',
        'meeting': 'Al Seef Area',
        'lat': 25.2631,
        'lon': 55.3048,
        'duration': 3.5,
        'max_group': 10,
        'min_age': 12,
        'difficulty': 'easy',
        'price': 145.00,
        'guide': 'layla_foodie'
    },
    {
        'title': 'Dubai City Tour: Burj Al Arab, Palm & Atlantis',
        'description': 'Full-day Dubai highlights tour! Visit iconic Burj Al Arab (photo stop), drive along Palm Jumeirah, Atlantis Hotel, Dubai Mall, Burj Khalifa exterior, Jumeirah Mosque, and Dubai Frame. Air-conditioned transport with expert guide.',
        'type': 'cultural',
        'categories': ['architecture', 'cultural', 'luxury'],
        'city': 'Dubai',
        'country': 'UAE',
        'meeting': 'Hotel Pickup - Dubai',
        'lat': 25.1972,
        'lon': 55.2744,
        'duration': 8.0,
        'max_group': 20,
        'min_age': 0,
        'difficulty': 'easy',
        'price': 180.00,
        'guide': 'ahmed_dubai'
    },
    {
        'title': 'VIP Desert Safari: Private 4x4 with Premium Dinner',
        'description': 'Exclusive private desert experience! Private 4x4 vehicle with personal driver, premium dune bashing, private camel ride, VIP seating at camp, dedicated butler service, gourmet BBQ dinner, and exclusive access to all entertainment shows.',
        'type': 'adventure',
        'categories': ['adventure', 'luxury', 'food'],
        'city': 'Dubai',
        'country': 'UAE',
        'meeting': 'Private Hotel Pickup',
        'lat': 25.0833,
        'lon': 55.7500,
        'duration': 6.0,
        'max_group': 6,
        'min_age': 0,
        'difficulty': 'moderate',
        'price': 425.00,
        'guide': 'rashid_adventure'
    },
    {
        'title': 'Abu Dhabi Full Day Tour: Mosque, Palace & Heritage',
        'description': 'Complete Abu Dhabi experience! Visit Sheikh Zayed Grand Mosque, Emirates Palace (photo), Qasr Al Watan Presidential Palace, Heritage Village, Corniche, Louvre Abu Dhabi (exterior), and Date Market. Lunch included.',
        'type': 'cultural',
        'categories': ['cultural', 'architecture', 'luxury'],
        'city': 'Abu Dhabi',
        'country': 'UAE',
        'meeting': 'Dubai Hotel Pickup',
        'lat': 24.4539,
        'lon': 54.3773,
        'duration': 10.0,
        'max_group': 18,
        'min_age': 0,
        'difficulty': 'easy',
        'price': 359.00,
        'guide': 'fatima_abudhabi'
    },
    {
        'title': 'Dune Buggy Desert Adventure with BBQ',
        'description': 'Extreme desert thrills! Drive your own dune buggy through the red dunes (600-950 AED depending on buggy type). Includes safety training, helmet, goggles, sandboarding, camel ride, and BBQ dinner at desert camp.',
        'type': 'adventure',
        'categories': ['adventure', 'food'],
        'city': 'Dubai',
        'country': 'UAE',
        'meeting': 'Desert Camp - Pickup Available',
        'lat': 25.0833,
        'lon': 55.7500,
        'duration': 5.0,
        'max_group': 8,
        'min_age': 18,
        'difficulty': 'hard',
        'price': 750.00,
        'guide': 'rashid_adventure'
    },
    {
        'title': 'Dubai Creek Dinner Cruise with Traditional Show',
        'description': 'Traditional dhow cruise on historic Dubai Creek. Glide past illuminated souks and heritage sites while enjoying international buffet dinner, unlimited beverages, live music, and authentic Arabic entertainment.',
        'type': 'food',
        'categories': ['water', 'food', 'cultural'],
        'city': 'Dubai',
        'country': 'UAE',
        'meeting': 'Dubai Creek Harbor',
        'lat': 25.2631,
        'lon': 55.3048,
        'duration': 2.0,
        'max_group': 35,
        'min_age': 0,
        'difficulty': 'easy',
        'price': 100.00,
        'guide': 'omar_marina'
    },
    {
        'title': 'Dubai Mall & Aquarium Tour with Fountain Show',
        'description': 'Explore the world\'s largest mall! Visit Dubai Aquarium & Underwater Zoo, shop luxury brands, see the spectacular Dubai Fountain show (musical fountain), and enjoy VIP mall navigation with shopping tips from local guide.',
        'type': 'cultural',
        'categories': ['luxury', 'cultural'],
        'city': 'Dubai',
        'country': 'UAE',
        'meeting': 'Dubai Mall Main Entrance',
        'lat': 25.1972,
        'lon': 55.2783,
        'duration': 4.0,
        'max_group': 12,
        'min_age': 0,
        'difficulty': 'easy',
        'price': 110.00,
        'guide': 'ahmed_dubai'
    },
    {
        'title': 'Hot Air Balloon Desert Sunrise Experience',
        'description': 'Magical sunrise hot air balloon flight over Dubai desert! Float above golden dunes, spot Arabian wildlife (oryx, gazelles), enjoy falcon show, gourmet breakfast, and receive flight certificate. Unforgettable experience!',
        'type': 'adventure',
        'categories': ['adventure', 'luxury', 'food'],
        'city': 'Dubai',
        'country': 'UAE',
        'meeting': 'Desert Meeting Point - Pickup Included',
        'lat': 24.8500,
        'lon': 55.5000,
        'duration': 4.0,
        'max_group': 20,
        'min_age': 5,
        'difficulty': 'easy',
        'price': 1050.00,
        'guide': 'rashid_adventure'
    },
    {
        'title': 'Emirati Cooking Class: Traditional Dishes',
        'description': 'Learn to cook authentic Emirati cuisine! Hands-on class making Machboos (spiced rice), Harees, Luqaimat (sweet dumplings), and Arabic coffee. Enjoy your creations with the group. Take home recipe booklet.',
        'type': 'food',
        'categories': ['food', 'cultural'],
        'city': 'Dubai',
        'country': 'UAE',
        'meeting': 'Cooking Studio - Old Dubai',
        'lat': 25.2631,
        'lon': 55.3048,
        'duration': 3.0,
        'max_group': 8,
        'min_age': 15,
        'difficulty': 'easy',
        'price': 195.00,
        'guide': 'layla_foodie'
    }
]

# Create tours
for tour_data in tours_data:
    tour = Tour.objects.create(
        title=tour_data['title'],
        description=tour_data['description'],
        tour_type=tour_data['type'],
        city=tour_data['city'],
        country=tour_data['country'],
        meeting_point=tour_data['meeting'],
        latitude=tour_data['lat'],
        longitude=tour_data['lon'],
        duration_hours=tour_data['duration'],
        max_group_size=tour_data['max_group'],
        min_age=tour_data['min_age'],
        difficulty_level=tour_data['difficulty'],
        price_per_person=tour_data['price']
    )

    # Add categories
    for cat_name in tour_data['categories']:
        tour.categories.add(categories[cat_name])

    # Add guide
    guide = user_guide_map[tour_data['guide']]
    tour.guides.add(guide)

print("✅ UAE tour data created successfully!")
print(f"   - {User.objects.count()} users")
print(f"   - {Category.objects.count()} categories")
print(f"   - {Guide.objects.count()} guides")
print(f"   - {Tour.objects.count()} tours")
print("\n🎉 Database ready with authentic UAE tours!")
print("\nYou can now start the servers:")
print("  Backend: python manage.py runserver")
print("  Web App: cd ../webapp && python3 -m http.server 3000")
