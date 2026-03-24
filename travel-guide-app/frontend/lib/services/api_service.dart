import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tour.dart';
import '../models/guide.dart';

class ApiService {
  // Update this to your backend URL
  static const String baseUrl = 'http://localhost:8000/api';

  // Tours
  Future<List<Tour>> getTours({String? city, String? tourType}) async {
    var uri = Uri.parse('$baseUrl/tours/');

    Map<String, String> queryParams = {};
    if (city != null) queryParams['city'] = city;
    if (tourType != null) queryParams['tour_type'] = tourType;

    if (queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((json) => Tour.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tours');
    }
  }

  Future<List<Tour>> getToursByLocation(String city) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tours/by_location/?city=$city'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => Tour.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tours');
    }
  }

  Future<List<Tour>> searchTours(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tours/?search=$query'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((json) => Tour.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search tours');
    }
  }

  // Guides
  Future<List<Guide>> getGuides({String? city}) async {
    var uri = Uri.parse('$baseUrl/guides/');

    if (city != null) {
      uri = uri.replace(queryParameters: {'city': city});
    }

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((json) => Guide.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load guides');
    }
  }

  Future<List<Guide>> getExpertGuides(String city) async {
    final response = await http.get(
      Uri.parse('$baseUrl/guides/experts/?city=$city'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => Guide.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load expert guides');
    }
  }

  Future<List<Guide>> getNearbyGuides(
    double latitude,
    double longitude, {
    double radius = 50,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/guides/nearby/?latitude=$latitude&longitude=$longitude&radius=$radius'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => Guide.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load nearby guides');
    }
  }

  // Categories
  Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories/'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Chat Recommendations
  Future<Map<String, dynamic>> getChatRecommendations(
    Map<String, dynamic> preferences,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat-recommendations/get_recommendations/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'preferences': preferences}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get recommendations');
    }
  }
}
