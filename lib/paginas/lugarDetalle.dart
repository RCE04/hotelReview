import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  static const String apiBaseUrl = 'https://localhost:7115/api';

  @override
  void initState() {
    super.initState();
    _comentariosFuture = fetchComentariosPorLugar(widget.lugar.Id);
    _cargarSesion();
  }

  Future<void> _cargarSesion() async {
    final id = await SesionService.obtenerUsuarioId();
    setState(() {
      _usuarioId = id;
    });
  }

  Future<void> _anadirAFavoritos() async {
    if (_usuarioId == null) return;

    final url = Uri.parse('$apiBaseUrl/Usuarios/$_usuarioId/favorito/${widget.lugar.Id}');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lugar añadido a favoritos')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al añadir a favoritos')),
      );
    }
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                '$apiBaseUrl/Lugares/imagen-proxy?url=${Uri.encodeComponent(lugar.Imagen)}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 60),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lugar.NombreLugar,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text('Dirección: ${lugar.Direccion}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Descripción: ${lugar.Descripcion}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Precio por noche: ${lugar.Precio}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  if (_usuarioId != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.favorite_border),
                        label: const Text('Añadir a Favoritos'),
                        onPressed: _anadirAFavoritos,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
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
                          const Text(
                            'Puntuación media:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
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
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: true,
            child: FutureBuilder<List<Comentario>>(
              future: _comentariosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('No hay comentarios disponibles.'),
                  );
                }

                final comentarios = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: comentarios.length,
                  itemBuilder: (context, index) {
                    final c = comentarios[index];
                    final puntuacion = double.tryParse(c.puntuacion) ?? 0.0;

                    return FutureBuilder<String>(
                      future: _getUsuarioNombre(c.usuarioId),
                      builder: (context, userSnapshot) {
                        final nombre = userSnapshot.data ?? 'Usuario';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
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
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _usuarioId != null
          ? FloatingActionButton.extended(
              onPressed: () async {
                final resultado = await Navigator.pushNamed(
                  context,
                  '/crearComentario',
                  arguments: {
                    'lugarId': widget.lugar.Id,
                    'usuarioId': _usuarioId,
                  },
                );
                if (resultado == true) {
                  setState(() {
                    _comentariosFuture = fetchComentariosPorLugar(widget.lugar.Id);
                  });
                }
              },
              icon: const Icon(Icons.add_comment),
              label: const Text('Añadir Comentario'),
            )
          : null,
    );
  }
}