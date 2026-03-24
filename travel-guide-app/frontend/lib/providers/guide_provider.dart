import 'package:flutter/material.dart';
import '../models/guide.dart';
import '../services/api_service.dart';

class GuideProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Guide> _guides = [];
  List<Guide> _expertGuides = [];
  bool _isLoading = false;
  String? _error;

  List<Guide> get guides => _guides;
  List<Guide> get expertGuides => _expertGuides;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadGuides({String? city}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _guides = await _apiService.getGuides(city: city);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadExpertGuides(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expertGuides = await _apiService.getExpertGuides(city);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNearbyGuides(double latitude, double longitude) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _guides = await _apiService.getNearbyGuides(latitude, longitude);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
