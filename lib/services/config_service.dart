import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/app_config.dart';

class ConfigService {
  // GANTI URL INI DENGAN RAW URL GITHUB GIST ANDA
  static const String gistRawUrl = 'https://gist.githubusercontent.com/Ardiansyahar8/4d9d74615300febe6b7a9b3ed7073dc5/raw/e8051010d5be02480d464a0418ebd5cb0e543efb/config.json';

  Future<AppConfig> fetchConfig() async {
    try {
      final response = await http.get(Uri.parse(gistRawUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return AppConfig.fromJson(jsonData);
      } else {
        throw Exception('Failed to load config: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching config: $e');
    }
  }
}
