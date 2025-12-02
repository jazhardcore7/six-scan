import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
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
    String croppedImageBase64 = response['cropped_image_base64'] ?? 
                           data['cropped_image_base64'] ?? 
                           '';
    
    String localImagePath = '';
    if (croppedImageBase64.isNotEmpty) {
      try {
        // Remove data URI scheme if present (e.g., "data:image/jpeg;base64,")
        if (croppedImageBase64.contains(',')) {
          croppedImageBase64 = croppedImageBase64.split(',').last;
        }
        
        final bytes = base64Decode(croppedImageBase64);
        final directory = await getApplicationDocumentsDirectory();
        final fileName = '${uuid.v4()}.jpg';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(bytes);
        localImagePath = file.path;
      } catch (e) {
        print('Error saving image: $e');
      }
    } else {
       // Fallback for URL if needed, or keep empty
       localImagePath = response['cropped_image_url'] ?? 
                        data['cropped_image_url'] ?? 
                        '';
    }

    if (data == null) {
      throw Exception('Invalid response: Data is null');
    }

    print('Available keys in data: ${data.keys.toList()}');
    print('Full data object: $data');

    // Handle nested nutrition_data if present
    final nutritionData = data['nutrition_data'] ?? data;
    print('Using nutrition data source: $nutritionData');

    final nutrition = NutritionModel(
      energy: _parseValue(nutritionData, ['energy', 'Energi Total', 'energi_total', 'energi']),
      fat: _parseValue(nutritionData, ['fat', 'Lemak Total', 'lemak_total', 'lemak']),
      protein: _parseValue(nutritionData, ['protein', 'Protein']),
      carbs: _parseValue(nutritionData, ['carbs', 'Karbohidrat Total', 'karbohidrat_total', 'karbohidrat']),
      sugar: _parseValue(nutritionData, ['sugar', 'Gula Total', 'gula_total', 'gula']),
      salt: _parseValue(nutritionData, ['salt', 'Garam', 'garam']),
    );
    
    print('Parsed Nutrition: ${nutrition.energy}, ${nutrition.fat}, ${nutrition.protein}');

    final timestamp = DateTime.now();
    return ScanResultModel(
      id: uuid.v4(),
      name: 'Scan ${DateFormat('dd/MM/yyyy HH:mm').format(timestamp)}',
      imagePath: localImagePath,
      timestamp: timestamp,
      nutrition: nutrition,
    );
  }

  String _parseValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      if (data.containsKey(key)) {
        final value = data[key];
        if (value != null) {
          return value.toString();
        }
      }
    }
    return '0';
  }

  @override
  Future<void> saveScan(ScanResult scanResult) async {
    // Convert Entity to Model to save
    final model = ScanResultModel(
      id: scanResult.id,
      name: scanResult.name,
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
