import 'package:shared_preferences/shared_preferences.dart';

class SesionService {
  static const String _keyUsuarioId = 'usuarioId';

  static Future<void> guardarUsuarioId(int usuarioId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUsuarioId, usuarioId);
  }

  static Future<int?> obtenerUsuarioId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUsuarioId);
  }

  static Future<void> cerrarSesion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsuarioId);
  }
}