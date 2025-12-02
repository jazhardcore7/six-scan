import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/entities/nutrition.dart';
import '../../domain/repositories/scan_repository.dart';

class ScanProvider with ChangeNotifier {
  final ScanRepository repository;

  ScanProvider({required this.repository});

  List<ScanResult> _history = [];
  List<ScanResult> get history => _history;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ScanResult? _currentResult;
  ScanResult? get currentResult => _currentResult;

  String? _error;
  String? get error => _error;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      _history = await repository.getHistory();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> scanImage(File imageFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentResult = await repository.scanImage(imageFile);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveCurrentScan() async {
    if (_currentResult == null) return;
    
    _isLoading = true;
    notifyListeners();
    try {
      await repository.saveScan(_currentResult!);
      await loadHistory(); // Refresh history
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteScan(String id) async {
    try {
      await repository.deleteScan(id);
      await loadHistory();
    } catch (e) {
      _error = e.toString();
    }
  }
  
  void clearCurrentResult() {
    _currentResult = null;
    notifyListeners();
  }
}
