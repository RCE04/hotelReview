import 'package:flutter/material.dart';
import '../modelos/lugares.dart';
import '../modelos/comentarios.dart';
import '../modelos/usuarios.dart';
import '../servicios/comentarioService.dart';
import '../servicios/usuarioService.dart';
import '../servicios/sesionService.dart';

class LugarDetallePage extends StatefulWidget {
  final Lugare lugar;

  const LugarDetallePage({super.key, required this.lugar});

  @override
  State<LugarDetallePage> createState() => _LugarDetallePageState();
}

class _LugarDetallePageState extends State<LugarDetallePage> {
  late Future<List<Comentario>> _comentariosFuture;
  int? _usuarioId;

  @override
  void initState() {
    super.initState();
    _comentariosFuture = fetchComentariosPorLugar(widget.lugar.Id);
    _cargarSesion();
  }

  Future<void> _cargarSesion() async {
    final id = await SesionService.obtenerUsuarioId();
    print('🟡 ID de sesión: $id');
    setState(() {
      _usuarioId = id;
    });
  }

  Widget _buildPuntuacionStars(double puntuacion) {
    int fullStars = puntuacion.floor();
    bool hasHalfStar = puntuacion - fullStars >= 0.5;
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return Row(
      children: [
        ...List.generate(fullStars, (_) => const Icon(Icons.star, color: Colors.amber)),
        if (hasHalfStar) const Icon(Icons.star_half, color: Colors.amber),
        ...List.generate(emptyStars, (_) => const Icon(Icons.star_border, color: Colors.amber)),
      ],
    );
  }

  Future<String> _getUsuarioNombre(int usuarioId) async {
    try {
      Usuario usuario = await fetchUsuarioPorId(usuarioId);
      return usuario.NombreUsuario;
    } catch (_) {
      return 'Usuario desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    final lugar = widget.lugar;

    return Scaffold(
      appBar: AppBar(title: Text(lugar.NombreLugar)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dirección: ${lugar.Direccion}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Descripción: ${lugar.Descripcion}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Precio: ${lugar.Precio}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            FutureBuilder<List<Comentario>>(
              future: _comentariosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No hay puntuaciones aún.');
                }

                final comentarios = snapshot.data!;
                final puntuaciones = comentarios
                    .map((c) => double.tryParse(c.puntuacion) ?? 0.0)
                    .toList();

                final media = puntuaciones.reduce((a, b) => a + b) / puntuaciones.length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Puntuación media:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        _buildPuntuacionStars(media),
                        const SizedBox(width: 8),
                        Text(media.toStringAsFixed(1), style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                );
              },
            ),
            const Divider(height: 32),
            const Text('Comentarios:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Comentario>>(
                future: _comentariosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No hay comentarios disponibles.');
                  }

                  final comentarios = snapshot.data!;
                  return ListView.builder(
                    itemCount: comentarios.length,
                    itemBuilder: (context, index) {
                      final c = comentarios[index];
                      final puntuacion = double.tryParse(c.puntuacion) ?? 0.0;

                      return FutureBuilder<String>(
                        future: _getUsuarioNombre(c.usuarioId),
                        builder: (context, userSnapshot) {
                          final nombre = userSnapshot.data ?? 'Usuario';
                          return ListTile(
                            title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.comentarioLugar),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _buildPuntuacionStars(puntuacion),
                                    const SizedBox(width: 8),
                                    Text('Puntuación: $puntuacion'),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            if (_usuarioId != null)
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_comment),
                  label: const Text('Añadir Comentario'),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/crearComentario',
                      arguments: {
                        'lugarId': lugar.Id,
                        'usuarioId': _usuarioId,
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}