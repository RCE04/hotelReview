import 'package:flutter/material.dart';
import '../servicios/usuarioService.dart';
import '../servicios/sesionService.dart';
import '../modelos/usuarios.dart';
import '../modelos/usuarioSesion.dart';

class InicioSesionPage extends StatefulWidget {
  const InicioSesionPage({super.key});

  @override
  State<InicioSesionPage> createState() => _InicioSesionPageState();
}

class _InicioSesionPageState extends State<InicioSesionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  void _iniciarSesion() async {
    if (_formKey.currentState!.validate()) {
      final usuario = _usuarioController.text.trim();
      final contrasena = _contrasenaController.text;

      final Usuario? usuarioLogueado = await login(usuario, contrasena);

      if (usuarioLogueado != null) {
        final sesion = UsuarioSesion(
          id: usuarioLogueado.Id!,
          nombreUsuario: usuarioLogueado.NombreUsuario,
          rol: usuarioLogueado.Rol,
        );
        await SesionService.guardarUsuarioSesion(sesion);
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario o contraseña incorrectos')),
        );
      }
    }
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  InputDecoration _estiloInput(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white38),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF6A1B9A),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _usuarioController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _estiloInput('Nombre de usuario'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Introduce el nombre de usuario' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contrasenaController,
                    style: const TextStyle(color: Colors.white),
                    obscureText: true,
                    decoration: _estiloInput('Contraseña'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Introduce la contraseña' : null,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _iniciarSesion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Iniciar Sesión'),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/registro'),
                      child: const Text(
                        '¿No tienes una cuenta? Crear una cuenta',
                        style: TextStyle(
                          color: Colors.white70,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}