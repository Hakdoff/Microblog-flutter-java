import 'dart:convert';

class PostModel {
  final int id;
  final String content;
  final int userId;
  final String createdAt;
  final String? imageUrl;

  PostModel(
      {required this.id,
      required this.content,
      required this.userId,
      required this.createdAt,
      required this.imageUrl});

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
        id: map['id'],
        content: map['content'] as String? ?? '',
        userId: map['userId'] as int? ?? 0,
        createdAt: map['createdAt'] as String? ?? '',
        imageUrl: map['imageUrl']);
  }

  factory PostModel.fromJson(String source) =>
      PostModel.fromMap(json.decode(source));
}
