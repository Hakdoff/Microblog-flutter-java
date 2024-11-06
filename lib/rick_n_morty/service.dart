import 'dart:convert';

import 'package:flutter_java_crud/rick_n_morty/model.dart';
import 'package:http/http.dart' as http;

class RickMortyService {
  Future<List<RickMortyModel>> getAllCharacter() async {
    var uri = Uri.parse("https://rickandmortyapi.com/api/character");
    var response = await http.get(uri);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      List<dynamic> characters = jsonResponse['results'];
      return characters
          .map((character) => RickMortyModel.fromMap(character))
          .toList();
    } else {
      throw Exception('Failed to load characters');
    }
  }
}
