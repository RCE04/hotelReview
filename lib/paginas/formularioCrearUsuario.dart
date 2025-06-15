import 'package:flutter/material.dart';
import '../modelos/usuarios.dart';
import '../servicios/usuarioService.dart';
// import 'inicioSesion.dart';

class FormularioCrearUsuario extends StatefulWidget {
  const FormularioCrearUsuario({super.key});

  @override
  State<FormularioCrearUsuario> createState() => _FormularioCrearUsuarioState();
}

class _FormularioCrearUsuarioState extends State<FormularioCrearUsuario> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  bool _enviando = false;
  String? _mensaje;

  Future<void> _guardarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _enviando = true;
      _mensaje = null;
    });

    Usuario nuevoUsuario = Usuario(
      Id: 0,
      NombreUsuario: _nombreController.text.trim(),
      Contrasena: _contrasenaController.text,
      Rol: 'Usuario', // Rol fijo
    );

    bool exito = await createUsuario(nuevoUsuario);

    setState(() {
      _enviando = false;
      _mensaje = exito ? 'Usuario creado exitosamente.' : 'Error al crear usuario.';
    });

    // Eliminado: redirección a InicioSesionPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Usuario')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF6A1B9A),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 12),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nombreController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco('Nombre de usuario'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Ingrese un nombre de usuario' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contrasenaController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco('Contraseña'),
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.length < 4) ? 'Contraseña muy corta' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _enviando ? null : _guardarUsuario,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _enviando
                        ? const CircularProgressIndicator()
                        : const Text('Guardar Usuario'),
                  ),
                  if (_mensaje != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _mensaje!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _mensaje!.contains('exitosamente')
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
      );
}