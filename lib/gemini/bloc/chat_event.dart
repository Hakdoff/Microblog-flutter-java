import 'package:flutter/material.dart';

@immutable
sealed class ChatEvent {}

class ChatGenerationNewTextMessageEvent extends ChatEvent {
  final String inputMessage;
  ChatGenerationNewTextMessageEvent({required this.inputMessage});
}
