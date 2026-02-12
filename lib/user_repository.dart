import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class UserRepository {
  //demo function
  Future<List<dynamic>> loadMockUsers() async {
    final jsonString = await rootBundle.loadString('assets/mock_users.json');
    return json.decode(jsonString);
  }
  Future<bool> mockUserExists(String email) async {
    final jsonString = await rootBundle.loadString('assets/mock_users.json');
    final List<dynamic> users = jsonDecode(jsonString);
    final exists = users.any((user) => user['email'] == email);
    return exists;
  }
  //backend function
  Future<bool> isUserExist(String email) async {
    final response = await http.post(
      Uri.parse("http://10.0.2.2:8080/api/users/exist"),
      body: {
        'email': email,
      },
    );

    if (response.statusCode == 200) {
      return response.body.toLowerCase() == 'true'; //
    } else {
      throw Exception("Failed to login: ${response.statusCode}");
    }
  }

  Future<String> requestLogin(String email, String password) async {
    final response = await http.post(
      Uri.parse("http://10.0.2.2:8080/api/users/login"),
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return response.body; //
    } else {
      throw Exception("Failed to login: ${response.statusCode}");
    }
  }

  Future<String> resetPassword(String email, String password,String confirmPassword) async {
    final response = await http.post(
      Uri.parse("http://10.0.2.2:8080/api/users/resetPassword"),
      body: {
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );

    if (response.statusCode == 200) {
      return response.body; //
    } else {
      throw Exception("Failed to login: ${response.statusCode}");
    }
  }

  Future<String> requestRegistration(String email, String password,String confirmPassword) async {
    final response = await http.post(
      Uri.parse("http://10.0.2.2:8080/api/users/registration"),
      body: {
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );

    if (response.statusCode == 200) {
      return response.body; //
    } else {
      throw Exception("Failed to login: ${response.statusCode}");
    }
  }

  Future<bool> verifyEmail(String email, String code, String mode) async {
    final response = await http.post(
      Uri.parse("http://10.0.2.2:8080/api/verification/verify"),
      body: {
        'email': email,
        'code' : code,
        'mode' : mode,
      },
    );
    if (response.statusCode == 200) {
      return response.body.toLowerCase() == 'true';
    } else {
      throw Exception("Failed to login: ${response.statusCode}");
    }
  }
  Future<String?> loginWithGoogle(String idToken) async {
    final response = await http.post(
      Uri.parse("http://10.0.2.2:8080/api/auth/google"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"idToken": idToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["token"];
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }

  Future<bool> userExists(String email) async {
    final response = await http.get(
      Uri.parse("http://your-backend.com/api/users/exists?email=$email"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['exists'];
    } else {
      throw Exception("Failed to check user");
    }
  }
  Future<void> addUser(String email, String password) async {
    final response = await http.post(
      Uri.parse("http://your-backend.com/api/users/add"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      print("User added successfully: ${response.body}");
    } else {
      print("Failed to add user: ${response.body}");
    }
  }
  bool isPasswordValid(String password) {
    final passwordRegex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$'
    );

    return passwordRegex.hasMatch(password);
  }

}
