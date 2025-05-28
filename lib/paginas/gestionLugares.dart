import 'package:flutter/material.dart';
import '../modelos/lugares.dart';
import '../servicios/lugarService.dart';
import '../servicios/comentarioService.dart'; // Importa el servicio de comentarios
import 'editarLugares.dart';

class GestionLugaresPage extends StatefulWidget {
  const GestionLugaresPage({Key? key}) : super(key: key);

  @override
  _GestionLugaresPageState createState() => _GestionLugaresPageState();
}

class _GestionLugaresPageState extends State<GestionLugaresPage> {
  late Future<List<Lugare>> _lugaresFuture;

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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirmacion == true) {
      final comentariosEliminados = await deleteComentariosPorLugar(id);

      if (comentariosEliminados) {
        final lugarEliminado = await deleteLugare(id);
        if (lugarEliminado) {
          _cargarLugares();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lugar y sus comentarios eliminados exitosamente.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al eliminar el lugar.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar los comentarios del lugar.')),
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
      _cargarLugares();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Lugares')),
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
              return ListTile(
                title: Text(lugar.NombreLugar),
                subtitle: Text('Dirección: ${lugar.Direccion}\nPrecio: ${lugar.Precio}'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _abrirFormulario(lugar: lugar),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _eliminarLugar(lugar.Id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
        tooltip: 'Agregar Lugar',
      ),
    );
  }
}