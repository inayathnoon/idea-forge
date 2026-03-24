class Tour {
  final int id;
  final String title;
  final String description;
  final String tourType;
  final List<Category> categories;
  final String city;
  final String country;
  final String meetingPoint;
  final double latitude;
  final double longitude;
  final double durationHours;
  final int maxGroupSize;
  final int minAge;
  final String difficultyLevel;
  final double pricePerPerson;
  final String coverImage;
  final int guideCount;
  final double averageRating;

  Tour({
    required this.id,
    required this.title,
    required this.description,
    required this.tourType,
    required this.categories,
    required this.city,
    required this.country,
    required this.meetingPoint,
    required this.latitude,
    required this.longitude,
    required this.durationHours,
    required this.maxGroupSize,
    required this.minAge,
    required this.difficultyLevel,
    required this.pricePerPerson,
    required this.coverImage,
    required this.guideCount,
    required this.averageRating,
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      tourType: json['tour_type'],
      categories: (json['categories'] as List?)
              ?.map((c) => Category.fromJson(c))
              .toList() ??
          [],
      city: json['city'],
      country: json['country'],
      meetingPoint: json['meeting_point'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      durationHours: json['duration_hours']?.toDouble() ?? 0.0,
      maxGroupSize: json['max_group_size'] ?? 0,
      minAge: json['min_age'] ?? 0,
      difficultyLevel: json['difficulty_level'] ?? 'easy',
      pricePerPerson: double.parse(json['price_per_person']?.toString() ?? '0'),
      coverImage: json['cover_image'] ?? '',
      guideCount: json['guide_count'] ?? 0,
      averageRating: json['average_rating']?.toDouble() ?? 0.0,
    );
  }

  String get tourTypeDisplay {
    switch (tourType) {
      case 'food':
        return 'Food Trip';
      case 'bike':
        return 'Bike Trip';
      case 'hike':
        return 'Hike & Photos';
      case 'cultural':
        return 'Cultural';
      case 'adventure':
        return 'Adventure';
      case 'historical':
        return 'Historical';
      case 'nightlife':
        return 'Nightlife';
      default:
        return 'Custom';
    }
  }

  String get difficultyDisplay {
    return difficultyLevel[0].toUpperCase() + difficultyLevel.substring(1);
  }
}

class Category {
  final int id;
  final String name;
  final String? icon;
  final String description;

  Category({
    required this.id,
    required this.name,
    this.icon,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      description: json['description'] ?? '',
    );
  }
}
