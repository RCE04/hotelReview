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
  String _filtroNombre = '';
  String _filtroDireccion = '';
  UsuarioSesion? usuarioSesion;

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
      MaterialPageRoute(builder: (_) => const EditarLugarPage()), // Modo crear
    );
  }

  void _aplicarFiltrosYOrden() {
    List<Lugare> lista = _lugaresOriginales.where((lugar) {
      final coincideNombre = lugar.NombreLugar.toLowerCase().contains(_filtroNombre.toLowerCase());
      final coincideDireccion = lugar.Direccion.toLowerCase().contains(_filtroDireccion.toLowerCase());
      return coincideNombre && coincideDireccion;
    }).toList();

    lista.sort((a, b) {
      double precioA = double.tryParse(a.Precio) ?? 0;
      double precioB = double.tryParse(b.Precio) ?? 0;
      return precioA.compareTo(precioB);
    });

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
                        _filtroNombre = value;
                        _aplicarFiltrosYOrden();
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Buscar por dirección',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      onChanged: (value) {
                        _filtroDireccion = value;
                        _aplicarFiltrosYOrden();
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Icon(Icons.sort),
                        SizedBox(width: 10),
                        Text('Ordenado por precio (ascendente)'),
                      ],
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
                              Text('Descripción: ${lugar.Descripcion}'),
                              Text('Precio: ${lugar.Precio}'),
                            ],
                          ),
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
