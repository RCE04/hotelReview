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
import '../servicios/usuarioService.dart';  // <- Importa el servicio de usuarios

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
  Set<int> _idsFavoritos = {};

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
        _aplicarFiltros();
      });
    });
  }

  void _cargarSesion() async {
    UsuarioSesion? sesion = await SesionService.obtenerUsuarioSesion();
    if (sesion != null) {
      try {
        final favoritosIds = await obtenerIdsFavoritos(sesion.id);
        setState(() {
          usuarioSesion = sesion;
          _idsFavoritos = favoritosIds.toSet();
        });
      } catch (e) {
        setState(() {
          usuarioSesion = sesion;
          _idsFavoritos = {};
        });
      }
    } else {
      setState(() {
        usuarioSesion = null;
        _idsFavoritos.clear();
      });
    }
  }

  void _cerrarSesion() async {
    await SesionService.cerrarSesion();
    setState(() {
      usuarioSesion = null;
      _idsFavoritos.clear();
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

  void _aplicarFiltros() {
    List<Lugare> lista = _lugaresOriginales.where((l) {
      final n = l.NombreLugar.toLowerCase().contains(_filtroNombre.toLowerCase());
      final d = l.Direccion.toLowerCase().contains(_filtroDireccion.toLowerCase());
      return n && d;
    }).toList();
    setState(() => _lugaresFiltrados = lista);
  }

  Future<void> _toggleFavorito(int lugarId) async {
    if (usuarioSesion == null) return;

    final esFav = _idsFavoritos.contains(lugarId);
    bool exito = false;

    if (esFav) {
      exito = await eliminarFavorito(usuarioSesion!.id, lugarId);
    } else {
      exito = await agregarFavorito(usuarioSesion!.id, lugarId);
    }

    if (exito) {
      setState(() {
        if (esFav) {
          _idsFavoritos.remove(lugarId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Eliminado de favoritos')),
          );
        } else {
          _idsFavoritos.add(lugarId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Agregado a favoritos')),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al ${esFav ? 'eliminar' : 'agregar'} favorito')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/iconos/icono1.png', height: 32),
            const SizedBox(width: 10),
            const Text('HotelReview'),
          ],
        ),
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
                ).then((_) => _cargarSesion());
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
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          } else if (!snap.hasData || snap.data!.isEmpty) {
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
                          onChanged: (v) {
                            _filtroNombre = v;
                            _aplicarFiltros();
                          },
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Buscar por dirección',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (v) {
                            _filtroDireccion = v;
                            _aplicarFiltros();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (ctx, cons) {
                    final columns = cons.maxWidth < 600
                        ? 1
                        : cons.maxWidth < 1000
                            ? 2
                            : 3;
                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 3 / 2,
                      ),
                      itemCount: _lugaresFiltrados.length,
                      itemBuilder: (_, i) {
                        final lug = _lugaresFiltrados[i];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      LugarDetallePage(lugar: lug))),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                    child: FadeInImage.assetNetwork(
                                      placeholder: 'assets/placeholder.jpg',
                                      image:
                                          '$apiBaseUrl/imagen-proxy?url=${Uri.encodeComponent(lug.Imagen)}',
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      imageErrorBuilder: (_, __, ___) =>
                                          Container(
                                              color: Colors.grey[200],
                                              child: const Center(
                                                  child: Icon(
                                                      Icons.broken_image,
                                                      size: 60))),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(lug.NombreLugar,
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          if (usuarioSesion != null)
                                            IconButton(
                                              icon: Icon(
                                                _idsFavoritos.contains(lug.Id)
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: Colors.red,
                                              ),
                                              tooltip: _idsFavoritos
                                                      .contains(lug.Id)
                                                  ? 'Eliminar de favoritos'
                                                  : 'Agregar a favoritos',
                                              onPressed: () =>
                                                  _toggleFavorito(lug.Id),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                              child: Text(lug.Direccion,
                                                  style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                          '${double.tryParse(lug.Precio)?.toInt()} €/noche',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green)),
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
              ),
            ],
          );
        },
      ),
      floatingActionButton: usuarioSesion != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (usuarioSesion!.rol.toLowerCase() == 'administrador') ...[
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