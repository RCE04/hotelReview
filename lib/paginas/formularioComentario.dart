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
  late Future<List<Comentario>> _comentariosFuture;

  @override
  void initState() {
    super.initState();
    _usuarioFuture = fetchUsuarioPorId(widget.usuarioId);
    _comentariosFuture = fetchComentariosPorLugar(widget.lugarId);
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
        Navigator.pop(context);
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

        final usuario = usuarioSnapshot.data!;
        final esAdmin = usuario.Rol.toLowerCase() == 'administrador';

        return Scaffold(
          appBar: AppBar(title: const Text('Añadir Comentario')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
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
                      )
                    ],
                  ),
                ),
                if (esAdmin) ...[
                  const SizedBox(height: 32),
                  const Divider(),
                  const Text(
                    'Todos los comentarios de este lugar:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  FutureBuilder<List<Comentario>>(
                    future: _comentariosFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No hay comentarios aún.');
                      }

                      final comentarios = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comentarios.length,
                        itemBuilder: (context, index) {
                          final c = comentarios[index];
                          return ListTile(
                            title: Text(c.comentarioLugar),
                            subtitle: Text('Puntuación: ${c.puntuacion} (Usuario ${c.usuarioId})'),
                          );
                        },
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}