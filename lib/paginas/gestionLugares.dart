import 'package:flutter/material.dart';
import '../modelos/lugares.dart';
import '../servicios/lugarService.dart';
import '../servicios/comentarioService.dart';
import 'editarLugares.dart';

class GestionLugaresPage extends StatefulWidget {
  const GestionLugaresPage({Key? key}) : super(key: key);

  @override
  _GestionLugaresPageState createState() => _GestionLugaresPageState();
}

class _GestionLugaresPageState extends State<GestionLugaresPage> {
  late Future<List<Lugare>> _lugaresFuture;
  bool _huboCambios = false;

  @override
  void initState() {
    super.initState();
    _cargarLugares();
  }

  void _cargarLugares() {
    setState(() {
      _lugaresFuture = fetchLugares();
    });
  }

  void _eliminarLugar(int id) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Deseas eliminar este lugar y sus comentarios?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      await deleteComentariosPorLugar(id);
      final lugarEliminado = await deleteLugare(id);

      if (lugarEliminado) {
        _huboCambios = true;
        _cargarLugares();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lugar y comentarios eliminados.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar el lugar.')),
        );
      }
    }
  }

  void _abrirFormulario({Lugare? lugar}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditarLugarPage(lugar: lugar)),
    );
    if (resultado == true) {
      _huboCambios = true;
      _cargarLugares();
    }
  }

  @override
  void dispose() {
    Navigator.pop(context, _huboCambios); // <- Devuelve true si hubo cambios
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Lugares'),
        backgroundColor: Colors.purple[700],
      ),
      body: FutureBuilder<List<Lugare>>(
        future: _lugaresFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.purple));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay lugares disponibles.', style: TextStyle(color: Colors.purple)));
          }

          final lugares = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: lugares.length,
            itemBuilder: (context, index) {
              final lugar = lugares[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  title: Text(
                    lugar.NombreLugar,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Dirección: ${lugar.Direccion}\nPrecio: ${lugar.Precio}',
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                  isThreeLine: true,
                  trailing: Wrap(
                    spacing: 12,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        tooltip: 'Editar Lugar',
                        onPressed: () => _abrirFormulario(lugar: lugar),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Eliminar Lugar',
                        onPressed: () => _eliminarLugar(lugar.Id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        tooltip: 'Agregar Lugar',
        child: const Icon(Icons.add, color: Colors.purple),
        onPressed: () => _abrirFormulario(),
      ),
    );
  }
}