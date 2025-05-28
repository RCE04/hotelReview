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
        Navigator.pop(context, true);  // <-- Aquí retornamos true para indicar éxito
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar el comentario')),
        );
      }

      setState(() => _enviando = false);
    }
  }

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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tu comentario'),
                  TextFormField(
                    controller: _comentarioController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu opinión aquí...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Escribe un comentario';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Puntuación'),
                  DropdownButtonFormField<String>(
                    value: _puntuacionSeleccionada,
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
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _enviando ? null : _guardarComentario,
                      child: _enviando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Enviar Comentario'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}