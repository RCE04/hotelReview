import 'package:flutter/material.dart';
import '../modelos/usuarios.dart';
import '../servicios/usuarioService.dart';

class FormularioCrearUsuario extends StatefulWidget {
  const FormularioCrearUsuario({super.key});

  @override
  State<FormularioCrearUsuario> createState() => _FormularioCrearUsuarioState();
}

class _FormularioCrearUsuarioState extends State<FormularioCrearUsuario>  {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  String _rolSeleccionado = 'Usuario';

  final List<String> _roles = ['Usuario', 'Administrador'];
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
      Rol: _rolSeleccionado,
    );

    bool exito = await createUsuario(nuevoUsuario);

    setState(() {
      _enviando = false;
      _mensaje = exito ? 'Usuario creado exitosamente.' : 'Error al crear usuario.';
    });

    if (exito) {
      _formKey.currentState?.reset();
      _nombreController.clear();
      _contrasenaController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre de usuario'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese un nombre de usuario' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contrasenaController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) =>
                    value == null || value.length < 4 ? 'Contraseña muy corta' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _rolSeleccionado,
                items: _roles.map((rol) {
                  return DropdownMenuItem<String>(
                    value: rol,
                    child: Text(rol),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _rolSeleccionado = value);
                },
                decoration: const InputDecoration(labelText: 'Rol'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _enviando ? null : _guardarUsuario,
                child: _enviando
                    ? const CircularProgressIndicator()
                    : const Text('Guardar Usuario'),
              ),
              if (_mensaje != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _mensaje!,
                    style: TextStyle(
                      color: _mensaje!.contains('exitosamente') ? Colors.green : Colors.red,
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