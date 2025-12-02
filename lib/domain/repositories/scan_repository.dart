import 'dart:io';
import '../entities/nutrition.dart';

abstract class ScanRepository {
  /// Uploads image to backend and returns the processed result (cropped image url + nutrition data)
  /// Returns a [ScanResult] with temporary image path (or url) and nutrition data.
  Future<ScanResult> scanImage(File imageFile);

  /// Saves the scan result to local database
  Future<void> saveScan(ScanResult scanResult);

  /// Retrieves all saved scans from local database
  Future<List<ScanResult>> getHistory();
  
  /// Deletes a scan from history
  Future<void> deleteScan(String id);
}
