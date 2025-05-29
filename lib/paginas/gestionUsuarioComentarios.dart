import 'package:flutter/material.dart';
import '../modelos/usuarios.dart';
import '../modelos/comentarios.dart';
import '../servicios/usuarioService.dart';
import '../servicios/comentarioService.dart';

class GestionUsuariosComentariosPage extends StatefulWidget {
  const GestionUsuariosComentariosPage({super.key});

  @override
  State<GestionUsuariosComentariosPage> createState() => _GestionUsuariosComentariosPageState();
}

class _GestionUsuariosComentariosPageState extends State<GestionUsuariosComentariosPage> {
  late Future<List<Usuario>> _usuariosFuture;
  late Future<List<Comentario>> _comentariosFuture;

  @override
  void initState() {
    super.initState();
    _usuariosFuture = fetchUsuarios();
    _comentariosFuture = fetchComentarios();
  }

  void _eliminarUsuario(int id) async {
    bool comentariosEliminados = await eliminarComentariosPorUsuario(id);
    if (comentariosEliminados) {
      bool usuarioEliminado = await deleteUsuario(id);
      if (usuarioEliminado) {
        setState(() {
          _usuariosFuture = fetchUsuarios();
          _comentariosFuture = fetchComentarios();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario y comentarios eliminados correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar usuario')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar comentarios del usuario')),
      );
    }
  }

  void _eliminarComentario(int id) async {
    await deleteComentario(id);
    setState(() => _comentariosFuture = fetchComentarios());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comentario eliminado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios y Comentarios'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Usuarios',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Usuario>>(
              future: _usuariosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No hay usuarios disponibles.');
                }

                return Column(
                  children: snapshot.data!.map((usuario) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.deepPurple),
                        title: Text(usuario.NombreUsuario),
                        subtitle: Text('Rol: ${usuario.Rol}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarUsuario(usuario.Id!),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              'Comentarios',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Comentario>>(
              future: _comentariosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No hay comentarios disponibles.');
                }

                return Column(
                  children: snapshot.data!.map((comentario) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.comment, color: Colors.deepPurpleAccent),
                        title: Text(comentario.comentarioLugar),
                        subtitle: Text('Lugar ID: ${comentario.lugarId} | Usuario ID: ${comentario.usuarioId}'),
                        trailing: comentario.id != null
                            ? IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _eliminarComentario(comentario.id!),
                              )
                            : const SizedBox(),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}