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
  Usuario? _usuario;
  bool _esFavorito = false;

  static const String apiBaseUrl = 'https://hotelreviewapi.onrender.com/api';

  @override
  void initState() {
    super.initState();
    _comentariosFuture = fetchComentariosPorLugar(widget.lugar.Id);
    _cargarSesion();
  }

  Future<void> _cargarSesion() async {
    final id = await SesionService.obtenerUsuarioId();
    if (id != null) {
      final usuario = await fetchUsuarioPorId(id);
      final favoritos = usuario.Favoritos?.split(',').map((e) => int.tryParse(e)).whereType<int>().toList() ?? [];

      setState(() {
        _usuarioId = id;
        _usuario = usuario;
        _esFavorito = favoritos.contains(widget.lugar.Id);
      });
    }
  }

  Future<void> _alternarFavorito() async {
    if (_usuarioId == null) return;

    bool exito;
    if (_esFavorito) {
      exito = await eliminarFavorito(_usuarioId!, widget.lugar.Id);
    } else {
      exito = await agregarFavorito(_usuarioId!, widget.lugar.Id);
    }

    if (exito) {
      setState(() {
        _esFavorito = !_esFavorito;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_esFavorito
              ? 'Lugar añadido a favoritos'
              : 'Lugar eliminado de favoritos'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar favoritos')),
      );
    }
  }

  Widget _buildPuntuacionStars(double puntuacion) {
    int fullStars = puntuacion.floor();
    bool hasHalfStar = puntuacion - fullStars >= 0.5;
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return Row(
      children: [
        ...List.generate(fullStars, (_) => const Icon(Icons.star, color: Colors.amber, size: 20)),
        if (hasHalfStar) const Icon(Icons.star_half, color: Colors.amber, size: 20),
        ...List.generate(emptyStars, (_) => const Icon(Icons.star_border, color: Colors.amber, size: 20)),
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

  Widget _datosYBoton(Lugare lugar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lugar.NombreLugar,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text('📍 Dirección: ${lugar.Direccion}', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 6),
        Text('📝 Descripción: ${lugar.Descripcion}', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 6),
        Text('💲 Precio por noche: ${lugar.Precio}', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 12),
        if (_usuarioId != null)
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: _alternarFavorito,
              icon: Icon(_esFavorito ? Icons.favorite : Icons.favorite_border),
              label: Text(_esFavorito ? 'Eliminar de Favoritos' : 'Añadir a Favoritos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final lugar = widget.lugar;

    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Center(
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool esAnchoPequeno = constraints.maxWidth < 600;
                      return esAnchoPequeno
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    '$apiBaseUrl/Lugares/imagen-proxy?url=${Uri.encodeComponent(lugar.Imagen)}',
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 200,
                                      height: 200,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image, size: 60),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _datosYBoton(lugar),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    '$apiBaseUrl/Lugares/imagen-proxy?url=${Uri.encodeComponent(lugar.Imagen)}',
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 200,
                                      height: 200,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image, size: 60),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(child: _datosYBoton(lugar)),
                              ],
                            );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FutureBuilder<List<Comentario>>(
                future: _comentariosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Todavía no hay comentarios.');
                  }

                  final comentarios = snapshot.data!;
                  final puntuaciones = comentarios
                      .map((c) => double.tryParse(c.puntuacion) ?? 0.0)
                      .toList();
                  final media = puntuaciones.reduce((a, b) => a + b) / puntuaciones.length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('⭐ Puntuación media:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildPuntuacionStars(media),
                          const SizedBox(width: 12),
                          Text(media.toStringAsFixed(1), style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('🗨️ Comentarios:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Comentario>>(
              future: _comentariosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Todavía no hay comentarios.'),
                  );
                }

                final comentarios = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
                                Text(nombre,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(c.comentarioLugar, style: const TextStyle(fontSize: 14)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _buildPuntuacionStars(puntuacion),
                                    const SizedBox(width: 8),
                                    Text('Puntuación: $puntuacion',
                                        style: const TextStyle(fontSize: 14)),
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
            const SizedBox(height: 24),
          ],
        ),
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