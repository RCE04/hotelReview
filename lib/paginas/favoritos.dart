import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../paginas/lugarDetalle.dart';
import '../modelos/lugares.dart'; // Asegúrate de que Lugare está aquí

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
        backgroundColor: Colors.redAccent,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : favoritos.isEmpty
              ? const Center(child: Text('No tienes lugares favoritos aún.'))
              : ListView.builder(
                  itemCount: favoritos.length,
                  itemBuilder: (context, index) {
                    final lugar = favoritos[index];

                    return GestureDetector(
                      onTap: () {
                        // Convertimos el mapa a un objeto Lugare
                        final lugareObj = Lugare(
                          Id: lugar['id'],
                          NombreLugar: lugar['nombreLugar'] ?? '',
                          Direccion: lugar['direccion'] ?? '',
                          Descripcion: lugar['descripcion'] ?? '',
                          Imagen: lugar['imagen'] ?? '',
                          Precio: lugar['precio'] ?? '0.00',
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LugarDetallePage(lugar: lugareObj),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: Image.network(
                                '$apiBaseUrl/Lugares/imagen-proxy?url=${Uri.encodeComponent(lugar['imagen'] ?? '')}',
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 180,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image, size: 60),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          lugar['nombreLugar'] ?? 'Sin nombre',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _eliminarFavorito(lugar['id']),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          lugar['direccion'] ?? 'Sin dirección',
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    lugar['descripcion'] ?? 'Sin descripción',
                                    style: const TextStyle(fontSize: 14),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Precio por noche: €${lugar['precio'] ?? '0.00'}',
                                    style: const TextStyle(
                                      fontSize: 16,
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
                ),
    );
  }
}