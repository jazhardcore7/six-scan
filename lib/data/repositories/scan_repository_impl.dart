import 'dart:io';
import 'package:uuid/uuid.dart';
import '../../domain/entities/nutrition.dart';
import '../../domain/repositories/scan_repository.dart';
import '../datasources/api_service.dart';
import '../datasources/database_helper.dart';
import '../models/nutrition_model.dart';

class ScanRepositoryImpl implements ScanRepository {
  final ApiService apiService;
  final DatabaseHelper databaseHelper;
  final Uuid uuid;

  ScanRepositoryImpl({
    required this.apiService,
    required this.databaseHelper,
    required this.uuid,
  });

  @override
  Future<ScanResult> scanImage(File imageFile) async {
    final response = await apiService.predict(imageFile);
    
    // In a real app, we might download the cropped image here.
    // For now, we use the URL returned by the mock.
    // Handle different response structures
    print('Repository received: $response');
    final data = response.containsKey('data') ? response['data'] : response;
    print('Parsed data object: $data');
    
    // Check for base64 image
    final croppedImageUrl = response['cropped_image_base64'] ?? 
                           data['cropped_image_base64'] ?? 
                           response['cropped_image_url'] ?? 
                           data['cropped_image_url'] ?? 
                           '';

    if (data == null) {
      throw Exception('Invalid response: Data is null');
    }

    final nutrition = NutritionModel(
      energy: data['energy']?.toString() ?? '0',
      fat: data['fat']?.toString() ?? '0',
      protein: data['protein']?.toString() ?? '0',
      carbs: data['carbs']?.toString() ?? '0',
      sugar: data['sugar']?.toString() ?? '0',
      salt: data['salt']?.toString() ?? '0',
    );

    // We create a temporary ScanResult. ID will be generated when saving?
    // Or we generate it now. Let's generate now.
    return ScanResultModel(
      id: uuid.v4(),
      imagePath: croppedImageUrl, // This is a URL in the mock
      timestamp: DateTime.now(),
      nutrition: nutrition,
    );
  }

  @override
  Future<void> saveScan(ScanResult scanResult) async {
    // Convert Entity to Model to save
    final model = ScanResultModel(
      id: scanResult.id,
      imagePath: scanResult.imagePath,
      timestamp: scanResult.timestamp,
      nutrition: NutritionModel(
        energy: scanResult.nutrition.energy,
        fat: scanResult.nutrition.fat,
        protein: scanResult.nutrition.protein,
        carbs: scanResult.nutrition.carbs,
        sugar: scanResult.nutrition.sugar,
        salt: scanResult.nutrition.salt,
      ),
    );
    await databaseHelper.create(model);
  }

  @override
  Future<List<ScanResult>> getHistory() async {
    return await databaseHelper.readAllScans();
  }

  @override
  Future<void> deleteScan(String id) async {
    await databaseHelper.delete(id);
  }
}
