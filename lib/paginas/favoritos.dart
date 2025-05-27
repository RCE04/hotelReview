import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoritosPage extends StatefulWidget {
  final int usuarioId;

  const FavoritosPage({super.key, required this.usuarioId});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  List<dynamic> favoritos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _obtenerFavoritos();
  }

  Future<void> _obtenerFavoritos() async {
    try {
      final url = Uri.parse('https://localhost:7115/api/Usuarios/${widget.usuarioId}/favoritos');
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
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.place, color: Colors.redAccent),
                        title: Text(lugar['nombreLugar'] ?? 'Sin nombre'),
                        subtitle: Text(lugar['descripcion'] ?? 'Sin descripción'),
                        onTap: () {
                          // Aquí puedes navegar al detalle del lugar si quieres
                        },
                      ),
                    );
                  },
                ),
    );
  }
}