class Guide {
  final int id;
  final User user;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final String description;
  final List<String> languages;
  final int experienceYears;
  final bool hasCamera;
  final bool hasCar;
  final bool hasBike;
  final bool hasDrone;
  final double hourlyRate;
  final double? dailyRate;
  final bool isVerified;
  final bool isAvailable;
  final double averageRating;
  final int totalReviews;

  Guide({
    required this.id,
    required this.user,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.languages,
    required this.experienceYears,
    required this.hasCamera,
    required this.hasCar,
    required this.hasBike,
    required this.hasDrone,
    required this.hourlyRate,
    this.dailyRate,
    required this.isVerified,
    required this.isAvailable,
    required this.averageRating,
    required this.totalReviews,
  });

  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      id: json['id'],
      user: User.fromJson(json['user']),
      city: json['city'],
      country: json['country'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      description: json['description'],
      languages: json['languages'].toString().split(',').map((e) => e.trim()).toList(),
      experienceYears: json['experience_years'],
      hasCamera: json['has_camera'],
      hasCar: json['has_car'],
      hasBike: json['has_bike'],
      hasDrone: json['has_drone'],
      hourlyRate: double.parse(json['hourly_rate'].toString()),
      dailyRate: json['daily_rate'] != null ? double.parse(json['daily_rate'].toString()) : null,
      isVerified: json['is_verified'],
      isAvailable: json['is_available'],
      averageRating: json['average_rating'].toDouble(),
      totalReviews: json['total_reviews'],
    );
  }

  List<String> get equipment {
    List<String> items = [];
    if (hasCamera) items.add('Camera');
    if (hasCar) items.add('Car');
    if (hasBike) items.add('Bike');
    if (hasDrone) items.add('Drone');
    return items;
  }
}

class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? profilePicture;
  final String? bio;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.profilePicture,
    this.bio,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone'],
      profilePicture: json['profile_picture'],
      bio: json['bio'],
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}
