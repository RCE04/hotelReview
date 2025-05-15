import 'package:flutter/material.dart';
import '../modelos/lugares.dart';
import '../servicios/lugarService.dart';
import 'lugarDetalle.dart';
import 'inicioSesion.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Lugare>> _lugaresFuture;
  bool usuarioAutenticado = false; // Simulación de sesión iniciada

  @override
  void initState() {
    super.initState();
    _lugaresFuture = fetchLugares();
  }

  void _cerrarSesion() {
    setState(() {
      usuarioAutenticado = false;
    });
  }

  void _irAInicioSesion() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InicioSesionPage()),
    );

    // Si se inició sesión exitosamente, el resultado debe ser true
    if (resultado == true) {
      setState(() {
        usuarioAutenticado = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lugares'),
        actions: [
          usuarioAutenticado
              ? IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Cerrar sesión',
                  onPressed: _cerrarSesion,
                )
              : IconButton(
                  icon: const Icon(Icons.login),
                  tooltip: 'Iniciar sesión',
                  onPressed: _irAInicioSesion,
                ),
        ],
      ),
      body: FutureBuilder<List<Lugare>>(
        future: _lugaresFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay lugares disponibles.'));
          }

          final lugares = snapshot.data!;

          return ListView.builder(
            itemCount: lugares.length,
            itemBuilder: (context, index) {
              final lugar = lugares[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LugarDetallePage(lugar: lugar),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lugar.NombreLugar,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Dirección: ${lugar.Direccion}'),
                        const SizedBox(height: 4),
                        Text('Descripción: ${lugar.Descripcion}'),
                        const SizedBox(height: 4),
                        Text('Precio: ${lugar.Precio}'),
                      ],
                    ),
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