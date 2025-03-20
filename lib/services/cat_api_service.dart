import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kototinder/models/cat.dart';

class CatApiService {
  static const String _baseUrl = 'https://api.thecatapi.com/v1';
  static const String _apiKey =
      'live_ESZ9VlBhCsNIaGyACF4EGtCVs7Wt3nwgKBtAn8javyWwrwo98QKwGL95L7qRwrya'; // Не забудьте указать ваш API ключ

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
    return null;
  }
}
