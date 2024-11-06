import 'package:flutter/foundation.dart';
import 'package:flutter_java_crud/gemini/models/chat_message_model.dart';

@immutable
sealed class ChatState {}

class ChatInitial extends ChatState {}

class ChatSuccessState extends ChatState {
  final List<ChatMessageModel> messages;
  ChatSuccessState({required this.messages});
}
