import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modelos/comentarios.dart';

// Cambié la URL base para que use la pública de Render
const String comentariosBaseUrl = 'https://hotelreviewapi.onrender.com/api/Comentarios';

Future<List<Comentario>> fetchComentarios() async {
  final response = await http.get(Uri.parse(comentariosBaseUrl));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Comentario.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar los comentarios');
  }
}

Future<List<Comentario>> fetchComentariosPorLugar(int lugarId) async {
  final response = await http.get(Uri.parse('$comentariosBaseUrl/lugar/$lugarId'));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Comentario.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar los comentarios del lugar con ID $lugarId');
  }
}

Future<bool> updateComentario(Comentario comentario) async {
  final response = await http.put(
    Uri.parse('$comentariosBaseUrl/${comentario.id}'),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode(comentario.toJson()),
  );

  return response.statusCode == 204;
}

Future<bool> createComentario(Comentario comentario) async {
  final response = await http.post(
    Uri.parse(comentariosBaseUrl),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode(comentario.toJson()),
  );

  return response.statusCode == 201;
}

Future<bool> deleteComentario(int id) async {
  final response = await http.delete(
    Uri.parse('$comentariosBaseUrl/$id'),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
  );

  return response.statusCode == 204;
}

Future<bool> eliminarComentariosPorUsuario(int usuarioId) async {
  final response = await http.delete(
    Uri.parse('$comentariosBaseUrl/usuario/$usuarioId'),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
  );

  return response.statusCode == 204;
}

Future<bool> deleteComentariosPorLugar(int lugarId) async {
  final response = await http.delete(
    Uri.parse('$comentariosBaseUrl/lugar/$lugarId'),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
  );

  return response.statusCode == 204;
}