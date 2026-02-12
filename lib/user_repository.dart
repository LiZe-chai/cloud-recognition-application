import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class UserRepository {
  Future<List<dynamic>> loadMockUsers() async {
    final jsonString = await rootBundle.loadString('assets/mock_users.json');
    return json.decode(jsonString);
  }

  Future<List<dynamic>> loadUsersFromApi() async {
    final response = await http.get(
      Uri.parse("https://your-api.com/users"),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load users from API");
    }
  }
}
