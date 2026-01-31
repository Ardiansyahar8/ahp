import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ahp_result.dart';

class AHPService {
  final String baseUrl;

  AHPService(this.baseUrl);

  Future<AHPResult> calculate({
    required List<String> criteriaNames,
    required List<String> alternativeNames,
    required List<List<double>> criteriaMatrix,
    required List<List<List<double>>> alternativesMatrices,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/calculate');
      
      final requestBody = {
        'criteria_names': criteriaNames,
        'alternative_names': alternativeNames,
        'criteria_matrix': criteriaMatrix,
        'alternatives_matrices': alternativesMatrices,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return AHPResult.fromJson(jsonData);
      } else {
        throw Exception('Failed to calculate: ${response.statusCode}');
      }
    } catch (e) {
      return AHPResult(
        success: false,
        error: e.toString(),
        message: 'Error connecting to server: $e',
      );
    }
  }

  Future<bool> testConnection() async {
    try {
      final url = Uri.parse('$baseUrl/');
      final response = await http.get(url);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
