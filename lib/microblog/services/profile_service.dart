import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ProfileService {
  final String baseUrl = 'http://localhost:8080/api/profiles';

  Future<http.Response> uploadProfile({
    required int userId,
    File? profPic,
    File? coverPic,
    required String bio,
  }) async {
    var uri = Uri.parse('$baseUrl/pic');
    var request = http.MultipartRequest('POST', uri);
    request.fields['userId'] = userId.toString();
    request.fields['bio'];

    if (profPic != null) {
      request.files
          .add(await http.MultipartFile.fromPath('profPic', profPic.path));
    }

    if (coverPic != null) {
      request.files
          .add(await http.MultipartFile.fromPath('coverpic', coverPic.path));
    }

    var response = await request.send();
    return http.Response.fromStream(response);
  }

  Future<Map<String, dynamic>> getProfile(int userId) async {
    var uri = Uri.parse('$baseUrl/$userId');
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }
}
