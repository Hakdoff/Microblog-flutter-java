import 'dart:convert';

class RickMortyModel {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String image;

  RickMortyModel(
      {required this.id,
      required this.name,
      required this.status,
      required this.species,
      required this.type,
      required this.image});

  factory RickMortyModel.fromMap(Map<String, dynamic> map) {
    return RickMortyModel(
        id: map['id'],
        name: map['name'],
        status: map['status'],
        species: map['species'],
        type: map['type'],
        image: map['image']);
  }

  factory RickMortyModel.fromJson(String source) =>
      RickMortyModel.fromMap(json.decode(source));
}
