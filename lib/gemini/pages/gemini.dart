import 'package:flutter/material.dart';
import 'package:flutter_java_crud/gemini/bloc/chat_event.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_java_crud/gemini/bloc/chat_bloc.dart';
import 'package:flutter_java_crud/gemini/bloc/chat_state.dart';
import 'package:flutter_java_crud/gemini/models/chat_message_model.dart';

class Gemini extends StatefulWidget {
  Gemini({super.key});

  @override
  State<Gemini> createState() => _GeminiState();
}

class _GeminiState extends State<Gemini> {
  final ChatBloc chatBloc = ChatBloc();
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini AI'),
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        bloc: chatBloc,
        listener: (context, state) {},
        builder: (context, state) {
          switch (state.runtimeType) {
            case ChatSuccessState:
              List<ChatMessageModel> messages =
                  (state as ChatSuccessState).messages;
              return Container(
                width: double.maxFinite,
                height: double.maxFinite,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: ListView.builder(
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(
                                    bottom: 12, left: 16, right: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.amber.withOpacity(0.1)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      messages[index].role == "user"
                                          ? "User"
                                          : "Space Pod",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: messages[index].role == "user"
                                              ? Colors.amber
                                              : Colors.pink),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    Text(
                                      messages[index].parts.first.text,
                                      style: const TextStyle(height: 1.2),
                                    )
                                  ],
                                ),
                              );
                            })),
                    if (chatBloc.generating)
                      const Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          SizedBox(width: 20),
                          Text("Loading...")
                        ],
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                              child: TextField(
                            controller: textEditingController,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100)),
                                fillColor: Colors.white,
                                hintText: "Ask something",
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade400),
                                filled: true,
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100),
                                    borderSide: BorderSide(
                                        color:
                                            Theme.of(context).primaryColor))),
                          )),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () {
                              if (textEditingController.text.isNotEmpty) {
                                String text = textEditingController.text;
                                textEditingController.clear();
                                chatBloc.add(ChatGenerationNewTextMessageEvent(
                                    inputMessage: text));
                              }
                            },
                            child: CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Theme.of(context).primaryColor,
                                child: const Center(
                                  child: Icon(Icons.send, color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );

            default:
              return const SizedBox();
          }
        },
      ),
    );
  }
}
