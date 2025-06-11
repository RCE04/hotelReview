import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../paginas/lugarDetalle.dart';
import '../modelos/lugares.dart';

class FavoritosPage extends StatefulWidget {
  final int usuarioId;

  const FavoritosPage({super.key, required this.usuarioId});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  List<dynamic> favoritos = [];
  bool cargando = true;

  static const String apiBaseUrl = 'https://hotelreviewapi.onrender.com/api';

  @override
  void initState() {
    super.initState();
    _obtenerFavoritos();
  }

  Future<void> _obtenerFavoritos() async {
    try {
      final url = Uri.parse('$apiBaseUrl/Usuarios/${widget.usuarioId}/favoritos');
      final respuesta = await http.get(url);

      if (respuesta.statusCode == 200) {
        setState(() {
          favoritos = json.decode(respuesta.body);
          cargando = false;
        });
      } else {
        throw Exception('Error al cargar favoritos');
      }
    } catch (e) {
      print('Error al obtener favoritos: $e');
      setState(() {
        cargando = false;
      });
    }
  }

  Future<void> _eliminarFavorito(int lugarId) async {
    final url = Uri.parse('$apiBaseUrl/Usuarios/${widget.usuarioId}/favorito/$lugarId');
    final response = await http.delete(url);

    if (response.statusCode == 200 || response.statusCode == 204) {
      setState(() {
        favoritos.removeWhere((lugar) => lugar['id'] == lugarId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Eliminado de favoritos')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar el favorito')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : favoritos.isEmpty
              ? const Center(child: Text('No tienes lugares favoritos aún.'))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth < 600
                        ? 1
                        : constraints.maxWidth < 1000
                            ? 2
                            : 3;

                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: favoritos.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 3 / 2,
                      ),
                      itemBuilder: (context, index) {
                        final lugar = favoritos[index];

                        final lugareObj = Lugare(
                          Id: lugar['id'],
                          NombreLugar: lugar['nombreLugar'] ?? '',
                          Direccion: lugar['direccion'] ?? '',
                          Descripcion: lugar['descripcion'] ?? '',
                          Imagen: lugar['imagen'] ?? '',
                          Precio: lugar['precio'] ?? '0.00',
                        );

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LugarDetallePage(lugar: lugareObj),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                        child: FadeInImage.assetNetwork(
                                          placeholder: 'assets/placeholder.jpg',
                                          image: '$apiBaseUrl/Lugares/imagen-proxy?url=${Uri.encodeComponent(lugar['imagen'] ?? '')}',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          imageErrorBuilder: (context, error, stackTrace) => Container(
                                            color: Colors.grey[200],
                                            child: const Center(child: Icon(Icons.broken_image, size: 60)),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white.withOpacity(0.8),
                                          child: IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _eliminarFavorito(lugar['id']),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lugar['nombreLugar'] ?? 'Sin nombre',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              lugar['direccion'] ?? 'Sin dirección',
                                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Desde ${double.tryParse(lugar['precio'] ?? '0.00')?.toInt()} €/noche',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}