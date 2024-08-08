import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_java_crud/microblog/model/post_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class PostService {
  Future<String> createPost(String content, int userId) async {
    final response = await http.post(
      Uri.parse("http://localhost:8080/post"),
      headers: <String, String>{
        'Content-Type': "application/json; charset=UTF-8",
      },
      body: jsonEncode(<String, dynamic>{'content': content, 'userId': userId}),
    );

    if (response.statusCode == 200) {
      return "Post successfully created";
    } else if (response.statusCode == 400) {
      return 'Unauthorized: Invalid user';
    } else {
      return 'Error: $response.reasonPhrase';
    }
  }

  Future<List<PostModel>> getallPosts() async {
    var uri = Uri.parse("http://localhost:8080/getPosts");
    var response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((post) => PostModel.fromMap(post)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<List<PostModel>> getPostsByUserId(int userId) async {
    var uri = Uri.parse("http://localhost:8080/postByUser/$userId");
    var response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((post) => PostModel.fromMap(post)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<String> updatePost(int postId, String content) async {
    final response = await http.put(
      Uri.parse("http://localhost:8080/post/$postId"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, dynamic>{'content': content}),
    );

    if (response.statusCode == 200) {
      return "Post succesfully updated";
    } else if (response.statusCode == 404) {
      return 'Post not found';
    } else {
      return 'Error: ${response.reasonPhrase}';
    }
  }

  Future<String> deletePost(int postId) async {
    final response =
        await http.delete(Uri.parse("http://localhost:8080/post/$postId"));

    if (response.statusCode == 200) {
      return 'Post successfully deleted';
    } else if (response.statusCode == 404) {
      return 'Post not found';
    } else {
      return 'Error: ${response.reasonPhrase}';
    }
  }

  Future<String?> getProfilePicture(int userId) async {
    final response = await http
        .get(Uri.parse("http://localhost:8080/profilePictures/$userId"));
    if (response.statusCode == 200) {
      final url = response.body;
      print('Profile picture URL fetched: $url'); // Debug print
      return url;
    } else {
      print('Failed to fetch profile picture URL: ${response.statusCode}');
      return null;
    }
  }

  Future<String?> uploadProfilePicture(
      int userId, Uint8List bytes, String filename) async {
    final request = http.MultipartRequest(
        'POST', Uri.parse("http://localhost:8080/uploadProfilePicture"));
    request.fields['userId'] = userId.toString();
    request.files.add(await http.MultipartFile.fromBytes('file', bytes,
        filename: filename, contentType: MediaType('image', 'jpeg')));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      print('Uploaded successful $responseBody');
      return responseBody;
    } else {
      print('Upload failed with status: ${response.statusCode}');
      print('Response: ${await response.stream.bytesToString()}');
      return null;
    }
  }
}
