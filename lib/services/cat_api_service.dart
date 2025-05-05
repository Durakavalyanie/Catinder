import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:kototinder/models/cat.dart';

class CatApiService {
  static const String _baseUrl = 'https://api.thecatapi.com/v1';

  String get _apiKey => dotenv.env['CAT_API_KEY'] ?? '';

  Future<Cat?> fetchRandomCat() async {
    final url = Uri.parse('$_baseUrl/images/search?has_breeds=1');
    final response = await http.get(
      url,
      headers: {'x-api-key': _apiKey},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        return Cat.fromJson(data[0]);
      }
    }
    throw Exception('Ошибка сети');
  }
}
