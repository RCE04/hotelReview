import 'package:flutter/material.dart';
import '../modelos/lugares.dart';
import '../servicios/lugarService.dart';
import '../paginas/lugarDetalle.dart';
import '../paginas/inicioSesion.dart';
import '../paginas/gestionUsuarioComentarios.dart';
import '../paginas/gestionLugares.dart';
import '../servicios/sesionService.dart';
import '../modelos/usuarioSesion.dart';
import '../paginas/editarLugares.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Lugare>> _lugaresFuture;
  List<Lugare> _lugaresOriginales = [];
  List<Lugare> _lugaresFiltrados = [];

  // Cambié de una a dos variables para los filtros
  String _filtroNombre = '';
  String _filtroDireccion = '';

  String _ordenSeleccionado = 'precio';
  UsuarioSesion? usuarioSesion;

  static const String apiBaseUrl = 'https://localhost:7115/api/Lugares';

  @override
  void initState() {
    super.initState();
    _lugaresFuture = fetchLugares();
    _lugaresFuture.then((lugares) {
      _lugaresOriginales = lugares;
      _aplicarFiltrosYOrden();
    });
    _cargarSesion();
  }

  void _cargarSesion() async {
    UsuarioSesion? sesion = await SesionService.obtenerUsuarioSesion();
    setState(() {
      usuarioSesion = sesion;
    });
  }

  void _cerrarSesion() async {
    await SesionService.cerrarSesion();
    setState(() {
      usuarioSesion = null;
    });
  }

  void _irAInicioSesion() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InicioSesionPage()),
    );

    if (resultado == true) {
      _cargarSesion();
    }
  }

  void _irAGestionUsuariosComentarios() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GestionUsuariosComentariosPage()),
    );
  }

  void _irAGestionLugares() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GestionLugaresPage()),
    );
  }

  void _irAEditarLugar() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditarLugarPage()),
    );
  }

  void _aplicarFiltrosYOrden() {
    List<Lugare> lista = _lugaresOriginales.where((lugar) {
      final nombreMatch = lugar.NombreLugar.toLowerCase().contains(_filtroNombre.toLowerCase());
      final direccionMatch = lugar.Direccion.toLowerCase().contains(_filtroDireccion.toLowerCase());
      return nombreMatch && direccionMatch;
    }).toList();

    if (_ordenSeleccionado == 'precio') {
      lista.sort((a, b) =>
          double.tryParse(a.Precio)!.compareTo(double.tryParse(b.Precio)!));
    }

    setState(() {
      _lugaresFiltrados = lista;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lugares'),
        actions: [
          usuarioSesion != null
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

          return Column(
            children: [
              // Aquí el cambio: dos TextFields separados para filtro nombre y dirección
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Buscar por nombre',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filtroNombre = value;
                          _aplicarFiltrosYOrden();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Buscar por dirección',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filtroDireccion = value;
                          _aplicarFiltrosYOrden();
                        });
                      },
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    const Text('Ordenar por: '),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _ordenSeleccionado,
                      items: const [
                        DropdownMenuItem(value: 'precio', child: Text('Precio')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          _ordenSeleccionado = value;
                          _aplicarFiltrosYOrden();
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _lugaresFiltrados.length,
                  itemBuilder: (context, index) {
                    final lugar = _lugaresFiltrados[index];

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
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (lugar.Imagen.isNotEmpty)
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                child: Image.network(
                                  // Aquí cambiamos la URL para que use el proxy de imágenes
                                  '$apiBaseUrl/imagen-proxy?url=${Uri.encodeComponent(lugar.Imagen)}',
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(Icons.broken_image,
                                              size: 120),
                                ),
                              ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lugar.NombreLugar,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Dirección: ${lugar.Direccion}'),
                                    Text('Descripción: ${lugar.Descripcion}'),
                                    Text('Precio: ${lugar.Precio}'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: usuarioSesion != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (usuarioSesion!.rol == 'administrador') ...[
                  FloatingActionButton.extended(
                    heroTag: 'usuarios',
                    onPressed: _irAGestionUsuariosComentarios,
                    icon: const Icon(Icons.people),
                    label: const Text('Usuarios/Comentarios'),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton.extended(
                    heroTag: 'lugares',
                    onPressed: _irAGestionLugares,
                    icon: const Icon(Icons.place),
                    label: const Text('Lugares'),
                  ),
                  const SizedBox(height: 10),
                ],
                FloatingActionButton.extended(
                  heroTag: 'agregarLugar',
                  onPressed: _irAEditarLugar,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Lugar'),
                ),
              ],
            )
          : null,
    );
  }
}