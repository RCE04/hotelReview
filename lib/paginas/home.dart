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
import '../paginas/favoritos.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Lugare>> _lugaresFuture;
  List<Lugare> _lugaresOriginales = [];
  List<Lugare> _lugaresFiltrados = [];

  String _filtroNombre = '';
  String _filtroDireccion = '';
  String _ordenSeleccionado = 'precio';
  UsuarioSesion? usuarioSesion;

  // Nueva base URL de la API en Render
  static const String apiBaseUrl = 'https://hotelreviewapi.onrender.com/api/Lugares';

  @override
  void initState() {
    super.initState();
    _cargarLugares();
    _cargarSesion();
  }

  void _cargarLugares() {
    setState(() {
      _lugaresFuture = fetchLugares();
      _lugaresFuture.then((lugares) {
        _lugaresOriginales = lugares;
        _aplicarFiltrosYOrden();
      });
    });
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

  void _irAEditarLugar({Lugare? lugar}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditarLugarPage(lugar: lugar)),
    );

    if (resultado == true) {
      _cargarLugares();
    }
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
        title: const Text('HotelReview'),
        actions: [
          if (usuarioSesion != null) ...[
            IconButton(
              icon: const Icon(Icons.favorite),
              tooltip: 'Favoritos',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FavoritosPage(usuarioId: usuarioSesion!.id),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
              onPressed: _cerrarSesion,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.login),
              tooltip: 'Iniciar sesión',
              onPressed: _irAInicioSesion,
            ),
          ],
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
              ExpansionTile(
                title: const Text('Filtros de búsqueda'),
                children: [
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
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    const Text('Ordenar por: '),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _ordenSeleccionado,
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      items: const [
                        DropdownMenuItem(value: 'precio', child: Text('Precio')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _ordenSeleccionado = value;
                            _aplicarFiltrosYOrden();
                          });
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
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        elevation: 6,
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
                                // ✅ Imagen con proxy
                                '$apiBaseUrl/imagen-proxy?url=${Uri.encodeComponent(lugar.Imagen)}',
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
                                    children: [
                                      Expanded(
                                        child: Text(
                                          lugar.NombreLugar,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
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
                                          lugar.Direccion,
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    lugar.Descripcion,
                                    style: const TextStyle(fontSize: 14),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Divider(height: 20),
                                  Text(
                                    'Precio por noche: ${double.tryParse(lugar.Precio)} €',
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
                  onPressed: () => _irAEditarLugar(),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Lugar'),
                ),
              ],
            )
          : null,
    );
  }
}