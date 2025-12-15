import 'dart:io';
import 'package:dio/dio.dart';

class MLVegetableService {
  final Dio _dio = Dio();

  // 🔧 CONFIG: Ubah ke true untuk gunakan server production
  static const bool useProduction = true;

  // Production URL (Railway deployment)
  static const String productionUrl =
      'https://modelannkel6-production.up.railway.app';

  // Local development URLs
  static const String localUrl = 'http://10.0.2.2:8000'; // Android emulator

  // Auto select URL
  String get baseUrl => useProduction ? productionUrl : localUrl;

  MLVegetableService() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  /// Check if backend is running and available
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('$baseUrl/');
      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }

  /// Predict vegetable quality from image
  /// Returns map with:
  /// - prediction: 'Utuh' or 'Rusak'
  /// - confidence: probability percentage (0-100)
  Future<Map<String, dynamic>> predictQuality(File imageFile) async {
    try {
      // Create form data with image
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      // Send POST request to /predict endpoint
      final response = await _dio.post(
        '$baseUrl/predict',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Debug: Show actual response
        print('✅ Backend Response: $data');
        print('✅ Response type: ${data.runtimeType}');

        // Validate response structure
        if (data == null) {
          throw Exception('Response data is null');
        }

        // Handle different response formats
        String? prediction;
        double? confidence;

        // Backend response format:
        // {"success": true, "quality": "Rusak/Utuh", "confidence": 0.9996}

        // Try to extract prediction from 'quality' field
        if (data.containsKey('quality')) {
          prediction = data['quality']?.toString();
          print('📊 Extracted from "quality": "$prediction"');
        } else if (data.containsKey('prediction')) {
          prediction = data['prediction']?.toString();
          print('📊 Extracted from "prediction": "$prediction"');
        } else if (data.containsKey('Prediction')) {
          prediction = data['Prediction']?.toString();
          print('📊 Extracted from "Prediction": "$prediction"');
        } else if (data.containsKey('class')) {
          prediction = data['class']?.toString();
          print('📊 Extracted from "class": "$prediction"');
        } else if (data.containsKey('label')) {
          prediction = data['label']?.toString();
          print('📊 Extracted from "label": "$prediction"');
        } else {
          throw Exception(
            'Response missing prediction field. Available keys: ${data.keys.join(", ")}',
          );
        }

        // Try to extract confidence (backend returns 0-1, we need 0-100)
        if (data.containsKey('confidence')) {
          final confValue = (data['confidence'] as num?)?.toDouble();
          // Convert from 0-1 to 0-100 percentage
          confidence = confValue != null ? confValue * 100 : null;
        } else if (data.containsKey('Confidence')) {
          final confValue = (data['Confidence'] as num?)?.toDouble();
          confidence = confValue != null ? confValue * 100 : null;
        } else if (data.containsKey('probability')) {
          final confValue = (data['probability'] as num?)?.toDouble();
          confidence = confValue != null ? confValue * 100 : null;
        } else if (data.containsKey('score')) {
          final confValue = (data['score'] as num?)?.toDouble();
          confidence = confValue != null ? confValue * 100 : null;
        } else {
          throw Exception(
            'Response missing confidence field. Available keys: ${data.keys.join(", ")}',
          );
        }

        if (prediction == null || confidence == null) {
          throw Exception(
            'Prediction or confidence is null. prediction=$prediction, confidence=$confidence',
          );
        }

        return {'prediction': prediction, 'confidence': confidence};
      } else {
        throw Exception(
          'Prediction failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Pastikan backend sedang running.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout. Backend terlalu lama merespon.');
      } else if (e.response?.statusCode == 500) {
        throw Exception(
          'Server error: ${e.response?.data['detail'] ?? 'Unknown error'}',
        );
      } else {
        throw Exception(
          'Tidak dapat terhubung ke server ML. Error: ${e.message}',
        );
      }
    } catch (e) {
      throw Exception('Error saat prediksi: $e');
    }
  }
}
