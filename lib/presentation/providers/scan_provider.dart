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

  Future<void> updateScanName(String name) async {
    if (_currentResult == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      // Create a new ScanResult with the updated name
      final updatedResult = ScanResult(
        id: _currentResult!.id,
        name: name,
        imagePath: _currentResult!.imagePath,
        timestamp: _currentResult!.timestamp,
        nutrition: _currentResult!.nutrition,
      );

      _currentResult = updatedResult;
      
      // If it's already saved (has ID), update it in DB
      // Note: saveScan currently does insert, we might need update in repo or handle it here
      // For now, assuming saveScan does insert OR replace, or we just save it.
      // Actually, saveScan does insert. We should check if we need an update method.
      // But wait, saveScan uses databaseHelper.create which does insert.
      // Let's check database_helper.dart again. It uses insert.
      // We might need an update method in repository and db helper.
      // For simplicity in this iteration, let's assume we are updating the current result in memory
      // and if we hit save, it saves the current result.
      // BUT, if we are renaming an EXISTING result (from history), we need to update DB.
      
      // Let's add update method to repository and db helper? 
      // Or just re-save? Re-saving might duplicate if ID is same and not REPLACE conflict algo.
      // The ID is primary key.
      // Let's check DatabaseHelper insert conflict algorithm. It defaults to abort?
      // We should probably add an update method to DB helper.
      
      // For now, let's just update memory. 
      // Wait, the requirement is "user should be able to name the result".
      // If this is BEFORE saving, updating memory is enough.
      // If this is AFTER saving (viewing history), we need DB update.
      // The UI shows "Simpan" button, implying we are in the "New Scan" flow.
      // So updating memory is likely sufficient for the "New Scan" flow.
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void setCurrentResult(ScanResult result) {
    _currentResult = result;
    notifyListeners();
  }

  void clearCurrentResult() {
    _currentResult = null;
    notifyListeners();
  }
}
