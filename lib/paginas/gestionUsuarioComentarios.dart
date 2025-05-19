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
    // Primero eliminar los comentarios asociados al usuario
    bool comentariosEliminados = await eliminarComentariosPorUsuario(id);
    if (comentariosEliminados) {
      // Luego eliminar el usuario
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Usuarios y Comentarios')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Usuarios', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            FutureBuilder<List<Usuario>>(
              future: _usuariosFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                return Column(
                  children: snapshot.data!.map((usuario) {
                    return ListTile(
                      title: Text(usuario.NombreUsuario),
                      subtitle: Text('Rol: ${usuario.Rol}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminarUsuario(usuario.Id!),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Comentarios', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            FutureBuilder<List<Comentario>>(
              future: _comentariosFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                return Column(
                  children: snapshot.data!.map((comentario) {
                    return ListTile(
                      title: Text(comentario.comentarioLugar),
                      subtitle: Text('ID Lugar: ${comentario.lugarId}, Usuario ID: ${comentario.usuarioId}'),
                      trailing: comentario.id != null
                          ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _eliminarComentario(comentario.id!),
                            )
                          : const SizedBox(), // Si no tiene ID, no muestra el botón
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