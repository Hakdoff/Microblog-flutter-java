import 'dart:convert';
import 'dart:async';
import 'package:flutter_java_crud/microblog/model/post_model.dart';
import 'package:http/http.dart' as http;

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
    final response = await http.put(Uri.parse("http://localhost:8080/post/$postId"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8'
    }, body: jsonEncode(<String, dynamic>{'content': content}),);

    if (response.statusCode == 200) {
      return "Post succesfully updated";
    } else if (response.statusCode == 404) {
      return 'Post not found';
    } else {
      return 'Error: ${response.reasonPhrase}';
    }
  }

  Future<String> deletePost(int postId) async {
    final response = await http.delete(Uri.parse("http://localhost:8080/post/$postId"));

    if (response.statusCode == 200) {
      return 'Post successfully deleted';
    } else if (response.statusCode == 404) {
      return 'Post not found';
    } else {
      return 'Error: ${response.reasonPhrase}';
    }
  }
}
