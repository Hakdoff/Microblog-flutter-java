import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';

class Service {
  Future<String> saveUser(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("http://192.168.0.164:8080/register"),
      headers: <String, String>{
        'Content-Type': "application/json; charset=UTF-8",
      },
      body: jsonEncode(
          <String, String>{'name': name, 'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return 'Email already exists';
    }
  }

  Future<String> loginUser(String email, String password) async {
    var uri = Uri.parse("http://192.168.0.164:8080/login");
    Map<String, String> headers = {"Content-Type": "application/json"};
    Map<String, String> data = {'email': email, 'password': password};
    var body = json.encode(data);

    try {
      var response = await http.post(uri, headers: headers, body: body);

      // Print the response status code and body for debugging
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Print the parsed response data
        print('Parsed Response Data: $responseData');

        final userId = responseData['userId'];
        final token = responseData['token'];

        // Print the userId and token to check for null values
        print('User ID: $userId');
        print('Token: $token');

        if (userId == null || token == null || token.isEmpty) {
          // If userId or token is null, return an error message
          print('Error: userId or token is null');
          return 'Invalid credentials';
        }

        // Save user ID and token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', userId);
        await prefs.setString('token', token);
        print('${token}');

        return "Login Successful";
      } else {
        return 'Invalid credentials';
      }
    } catch (e) {
      // Print the error to see what's causing the issue
      print('Error: ${e.toString()}');
      return 'Error: ${e.toString()}';
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<int?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    print('Retrieved User ID: $userId'); // Debug statement
    return userId;
  }

  Future<void> printUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    print('User ID: $userId');
  }

  Future<List<UserModel>> getAllUsers() async {
    var uri = Uri.parse("http://192.168.0.164:8080/users");
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((user) => UserModel.fromMap(user)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<String?> getProfilePicture(int userId) async {
    final response = await http
        .get(Uri.parse("http://192.168.0.164:8080/profilePictures/$userId"));
    if (response.statusCode == 200) {
      final url = response.body;
      // print('Profile picture URL fetched: $url'); // Debug print
      return url;
    } else {
      print('Failed to fetch profile picture URL: ${response.statusCode}');
      return null;
    }
  }
}
