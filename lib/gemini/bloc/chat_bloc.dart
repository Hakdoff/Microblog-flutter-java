import 'dart:async';

import 'package:flutter_java_crud/gemini/bloc/chat_event.dart';
import 'package:flutter_java_crud/gemini/bloc/chat_state.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_java_crud/gemini/models/chat_message_model.dart';
import 'package:flutter_java_crud/gemini/repos/chat_repo.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatSuccessState(messages: [])) {
    on<ChatGenerationNewTextMessageEvent>(chatGenerateNewTextMessageEvent);
  }

  List<ChatMessageModel> messages = [];
  bool generating = false;

  FutureOr<void> chatGenerateNewTextMessageEvent(
      ChatGenerationNewTextMessageEvent event, Emitter<ChatState> emit) async {
    messages.add(ChatMessageModel(
        role: "user", parts: [ChatPartModel(text: event.inputMessage)]));
    emit(ChatSuccessState(messages: messages));
    generating = true;
    String generatedText = await ChatRepo.chatTextGenerationRepo(messages);
    if (generatedText.length > 0) {
      messages.add(ChatMessageModel(
          role: "model", parts: [ChatPartModel(text: generatedText)]));
      emit(ChatSuccessState(messages: messages));
    }
    generating = false;
  }
}
