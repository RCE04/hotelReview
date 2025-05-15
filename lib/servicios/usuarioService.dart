import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modelos/usuarios.dart';

const String usuariosBaseUrl = 'https://localhost:7115/api/Usuarios';

Future<List<Usuario>> fetchUsuarios() async {
  final response = await http.get(Uri.parse(usuariosBaseUrl));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Usuario.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar los usuarios');
  }
}

Future<bool> updateUsuario(Usuario usuario) async {
  final response = await http.put(
    Uri.parse('$usuariosBaseUrl/${usuario.Id}'),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode(usuario.toJson()),
  );

  return response.statusCode == 204;
}

Future<bool> createUsuario(Usuario usuario) async {
  final response = await http.post(
    Uri.parse(usuariosBaseUrl),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode(usuario.toJson()),
  );

  return response.statusCode == 201;
}

Future<bool> deleteUsuario(int id) async {
  final response = await http.delete(
    Uri.parse('$usuariosBaseUrl/$id'),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
  );

  return response.statusCode == 204;
}

/// 🔐 Función de login
Future<Usuario?> login(String nombreUsuario, String contrasena) async {
  final response = await http.get(Uri.parse(usuariosBaseUrl));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    final usuarios = data.map((json) => Usuario.fromJson(json)).toList();

    // Buscar coincidencia exacta (según API, el campo es "contraseña")
    try {
      return usuarios.firstWhere(
        (u) =>
            u.NombreUsuario == nombreUsuario &&
            u.Contrasena == contrasena,
      );
    } catch (_) {
      return null; // No encontrado
    }
  } else {
    throw Exception('Error al validar usuario');
  }
}

Future<Usuario> fetchUsuarioPorId(int usuarioId) async {
  final response = await http.get(Uri.parse('$usuariosBaseUrl/$usuarioId'));

  if (response.statusCode == 200) {
    return Usuario.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Error al cargar usuario con ID $usuarioId');
  }
}