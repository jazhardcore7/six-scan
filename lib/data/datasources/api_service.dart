import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import '../models/nutrition_model.dart';
import 'package:uuid/uuid.dart';

class ApiService {
  final Dio _dio = Dio();
  // Android emulator uses 10.0.2.2 to access host localhost
  // Android emulator uses 10.0.2.2 to access host localhost
  // For physical device, use the laptop's LAN IP
  final String _baseUrl = 'http://192.168.1.93:8000'; 

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
        options: Options(
          validateStatus: (status) {
            return status! < 500; // Allow 404 to be handled manually
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 404) {
        throw Exception('No nutrition label detected in the image.');
      } else {
        throw Exception('Failed to predict: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error in ApiService: $e');
      throw Exception('Error connecting to backend: $e');
    }
  }
}
