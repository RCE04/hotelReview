import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../servicios/usuarioService.dart';
import '../servicios/sesionService.dart'; // Importación necesaria
import '../modelos/usuarios.dart';

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
        // Guardar el ID del usuario en SharedPreferences
        await SesionService.guardarUsuarioId(usuarioLogueado.Id!); // ← corrección aquí

        // Volver a la pantalla anterior (o cambiar de ruta si lo prefieres)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _usuarioController,
                decoration: const InputDecoration(labelText: 'Nombre de usuario'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Introduce el nombre de usuario' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contrasenaController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Introduce la contraseña' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _iniciarSesion,
                child: const Text('Iniciar Sesión'),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/registro');
                  },
                  child: const Text(
                    '¿No tienes una cuenta? Crear una cuenta',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}