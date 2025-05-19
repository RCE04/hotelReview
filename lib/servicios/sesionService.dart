import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../modelos/usuarioSesion.dart';

class SesionService {
  static const String _keyUsuario = 'usuarioSesion';

  // Guardar toda la sesión del usuario como JSON
  static Future<void> guardarUsuarioSesion(UsuarioSesion usuario) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsuario, jsonEncode(usuario.toJson()));
  }

  // Obtener la sesión del usuario desde SharedPreferences
  static Future<UsuarioSesion?> obtenerUsuarioSesion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonUsuario = prefs.getString(_keyUsuario);
    if (jsonUsuario != null) {
      return UsuarioSesion.fromJson(jsonDecode(jsonUsuario));
    }
    return null;
  }

  // Obtener solo el ID del usuario desde la sesión
  static Future<int?> obtenerUsuarioId() async {
    UsuarioSesion? sesion = await obtenerUsuarioSesion();
    return sesion?.id;
  }

  // Cerrar sesión eliminando los datos guardados
  static Future<void> cerrarSesion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsuario);
  }
}