import 'package:flutter/material.dart';
import '../models/tour.dart';
import '../services/api_service.dart';

class TourProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Tour> _tours = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Tour> get tours => _tours;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTours({String? city, String? tourType}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tours = await _apiService.getTours(city: city, tourType: tourType);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadToursByLocation(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tours = await _apiService.getToursByLocation(city);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchTours(String query) async {
    if (query.isEmpty) {
      _tours = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tours = await _apiService.searchTours(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _apiService.getCategories();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
