import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../modelos/lugares.dart';

const String baseUrl = 'https://localhost:7115/api/Lugares';

Future<List<Lugare>> fetchLugares() async {
  final response = await http.get(Uri.parse(baseUrl));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Lugare.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar los lugares');
  }
}

Future<bool> updateLugare(Lugare lugare) async {
  final response = await http.put(
    Uri.parse('$baseUrl/${lugare.Id}'),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode(lugare.toJson()),
  );

  return response.statusCode == 204;
}

Future<bool> createLugare(Lugare lugare) async {
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode(lugare.toJson()),
  );

  return response.statusCode == 201;
}

Future<bool> deleteLugare(int id) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/$id'),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
  );

  return response.statusCode == 204;
}