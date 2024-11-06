import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_java_crud/rick_n_morty/model.dart';
import 'package:flutter_java_crud/rick_n_morty/service.dart';

class RickAndMorty extends StatefulWidget {
  const RickAndMorty({super.key, required this.title});

  final String title;

  @override
  State<RickAndMorty> createState() => _RickAndMortyState();
}

class _RickAndMortyState extends State<RickAndMorty> {
  RickMortyService service = RickMortyService();
  List<RickMortyModel> characters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCharacters();
  }

  Future<void> fetchCharacters() async {
    try {
      List<RickMortyModel> fetchedCharacters = await service.getAllCharacter();
      setState(() {
        characters = fetchedCharacters;
        isLoading = false;
      });
    } catch (e) {
      log('Failed to fetch characters $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
          title: const Text('Rick n Morty'),
        ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: characters.length,
                    itemBuilder: (context, index) {
                      final character = characters[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Image.network(
                                    character.image,
                                    height: 100,
                                    width: 100,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    children: [
                                      Text(character.name),
                                      Text(character.status),
                                      Text(character.type),
                                      Text(character.species)
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
    );
  }
}
