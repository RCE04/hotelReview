import 'package:flutter/material.dart';
import '../servicios/comentarioService.dart';
import '../servicios/usuarioService.dart';
import '../modelos/comentarios.dart';
import '../modelos/usuarios.dart';

class FormularioComentario extends StatefulWidget {
  final int lugarId;
  final int usuarioId;

  const FormularioComentario({
    super.key,
    required this.lugarId,
    required this.usuarioId,
  });

  @override
  State<FormularioComentario> createState() => _FormularioComentarioState();
}

class _FormularioComentarioState extends State<FormularioComentario> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _comentarioController = TextEditingController();
  String _puntuacionSeleccionada = '5';
  bool _enviando = false;

  late Future<Usuario> _usuarioFuture;

  @override
  void initState() {
    super.initState();
    _usuarioFuture = fetchUsuarioPorId(widget.usuarioId);
  }

  Future<void> _guardarComentario() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _enviando = true);

      final nuevoComentario = Comentario(
        comentarioLugar: _comentarioController.text.trim(),
        puntuacion: _puntuacionSeleccionada,
        lugarId: widget.lugarId,
        usuarioId: widget.usuarioId,
      );

      final exito = await createComentario(nuevoComentario);

      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comentario enviado correctamente')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar el comentario')),
        );
      }

      setState(() => _enviando = false);
    }
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Usuario>(
      future: _usuarioFuture,
      builder: (context, usuarioSnapshot) {
        if (usuarioSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (usuarioSnapshot.hasError) {
          return Scaffold(body: Center(child: Text('Error: ${usuarioSnapshot.error}')));
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Añadir Comentario')),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: 460,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A1B9A), // mismo morado
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
                      Text(
                        'Tu comentario',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _comentarioController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDeco('Escribe tu opinión aquí...'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Escribe un comentario';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Puntuación',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _puntuacionSeleccionada,
                        dropdownColor: const Color(0xFF6A1B9A),
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDeco(''),
                        items: ['1', '2', '3', '4', '5']
                            .map((valor) => DropdownMenuItem(
                                  value: valor,
                                  child: Text(valor),
                                ))
                            .toList(),
                        onChanged: (valor) {
                          setState(() {
                            _puntuacionSeleccionada = valor!;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _enviando ? null : _guardarComentario,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _enviando
                            ? const CircularProgressIndicator()
                            : const Text('Enviar Comentario'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}