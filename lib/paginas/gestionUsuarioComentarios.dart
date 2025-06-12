import 'package:flutter/material.dart';
import '../modelos/usuarios.dart';
import '../modelos/comentarios.dart';
import '../modelos/lugares.dart';
import '../servicios/usuarioService.dart';
import '../servicios/comentarioService.dart';
import '../servicios/lugarService.dart';

class GestionUsuariosComentariosPage extends StatefulWidget {
  const GestionUsuariosComentariosPage({super.key});

  @override
  State<GestionUsuariosComentariosPage> createState() => _GestionUsuariosComentariosPageState();
}

class _GestionUsuariosComentariosPageState extends State<GestionUsuariosComentariosPage> {
  late Future<List<Usuario>> _usuariosFuture;
  late Future<List<Comentario>> _comentariosFuture;
  late Future<List<Lugare>> _lugaresFuture;
  final Map<int, String> _rolesEditados = {};

  @override
  void initState() {
    super.initState();
    _usuariosFuture = fetchUsuarios();
    _comentariosFuture = fetchComentarios();
    _lugaresFuture = fetchLugares();
  }

  void _eliminarUsuario(int id) async {
    bool comentariosEliminados = await eliminarComentariosPorUsuario(id);
    if (comentariosEliminados) {
      bool usuarioEliminado = await deleteUsuario(id);
      if (usuarioEliminado) {
        final nuevosUsuarios = await fetchUsuarios();
        final nuevosComentarios = await fetchComentarios();
        setState(() {
          _usuariosFuture = Future.value(nuevosUsuarios);
          _comentariosFuture = Future.value(nuevosComentarios);
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

  void _guardarRol(Usuario usuario) async {
    final nuevoRol = _rolesEditados[usuario.Id];
    if (nuevoRol != null && nuevoRol != usuario.Rol) {
      final actualizado = Usuario(
        Id: usuario.Id,
        NombreUsuario: usuario.NombreUsuario,
        Contrasena: usuario.Contrasena,
        Rol: nuevoRol,
        Favoritos: usuario.Favoritos,
      );

      bool ok = await updateUsuario(actualizado);
      if (ok) {
        final nuevosUsuarios = await fetchUsuarios();
        setState(() {
          _usuariosFuture = Future.value(nuevosUsuarios);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rol actualizado')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar el rol')),
        );
      }
    }
  }

  void _eliminarComentario(int id) async {
    await deleteComentario(id);
    final nuevosComentarios = await fetchComentarios();
    setState(() {
      _comentariosFuture = Future.value(nuevosComentarios);
    });
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
                    final rolActual = _rolesEditados[usuario.Id] ?? usuario.Rol;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.person, color: Colors.deepPurple),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(usuario.NombreUsuario, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  const Text('Rol:'),
                                  DropdownButton<String>(
                                    value: ['Administrador', 'Usuario'].contains(rolActual) ? rolActual : null,
                                    onChanged: (nuevoRol) {
                                      setState(() {
                                        _rolesEditados[usuario.Id!] = nuevoRol!;
                                      });
                                    },
                                    items: ['Administrador', 'Usuario']
                                        .map((rol) => DropdownMenuItem<String>(
                                              value: rol,
                                              child: Text(rol),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.save, color: Colors.green),
                                  tooltip: 'Guardar rol',
                                  onPressed: () => _guardarRol(usuario),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Eliminar usuario',
                                  onPressed: () => _eliminarUsuario(usuario.Id!),
                                ),
                              ],
                            ),
                          ],
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

                final comentarios = snapshot.data!;

                return FutureBuilder<List<Usuario>>(
                  future: _usuariosFuture,
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (!userSnapshot.hasData || userSnapshot.data!.isEmpty) {
                      return const Text('No hay usuarios disponibles para mostrar comentarios.');
                    }

                    final usuarios = {for (var u in userSnapshot.data!) u.Id: u.NombreUsuario};

                    return FutureBuilder<List<Lugare>>(
                      future: _lugaresFuture,
                      builder: (context, lugarSnapshot) {
                        if (lugarSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (!lugarSnapshot.hasData || lugarSnapshot.data!.isEmpty) {
                          return const Text('No hay lugares disponibles.');
                        }

                        final lugares = {for (var l in lugarSnapshot.data!) l.Id: l.NombreLugar};

                        final Map<int, List<Comentario>> comentariosPorLugar = {};
                        for (var comentario in comentarios) {
                          comentariosPorLugar.putIfAbsent(comentario.lugarId, () => []).add(comentario);
                        }

                        return Column(
                          children: comentariosPorLugar.entries.map((entry) {
                            final lugarId = entry.key;
                            final comentariosDelLugar = entry.value;
                            final nombreLugar = lugares[lugarId] ?? 'Lugar desconocido';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lugar: $nombreLugar',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...comentariosDelLugar.map((comentario) {
                                  final nombreUsuario = usuarios[comentario.usuarioId] ?? 'Usuario desconocido';

                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    child: ListTile(
                                      leading: const Icon(Icons.comment, color: Colors.deepPurpleAccent),
                                      title: Text(comentario.comentarioLugar),
                                      subtitle: Text('Usuario: $nombreUsuario'),
                                      trailing: comentario.id != null
                                          ? IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _eliminarComentario(comentario.id!),
                                            )
                                          : const SizedBox(),
                                    ),
                                  );
                                }).toList(),
                                const SizedBox(height: 16),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}