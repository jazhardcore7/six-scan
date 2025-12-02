import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import '../models/nutrition_model.dart';
import 'package:uuid/uuid.dart';

class ApiService {
  final Dio _dio = Dio();
  // Android emulator uses 10.0.2.2 to access host localhost
  final String _baseUrl = 'http://10.0.2.2:8000'; 

  Future<Map<String, dynamic>> predict(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      print('Sending request to $_baseUrl/predict');
      Response response = await _dio.post(
        '$_baseUrl/predict',
        data: formData,
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to predict: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error in ApiService: $e');
      throw Exception('Error connecting to backend: $e');
    }
  }
}
