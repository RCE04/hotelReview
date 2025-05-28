import 'package:flutter/material.dart';
import '../modelos/lugares.dart';
import '../servicios/lugarService.dart';

class EditarLugarPage extends StatefulWidget {
  final Lugare? lugar;
  const EditarLugarPage({Key? key, this.lugar}) : super(key: key);

  @override
  _EditarLugarPageState createState() => _EditarLugarPageState();
}

class _EditarLugarPageState extends State<EditarLugarPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _direccionController;
  late TextEditingController _descripcionController;
  late TextEditingController _precioController;
  late TextEditingController _imagenController;

  @override
  void initState() {
    super.initState();
    final lugar = widget.lugar;
    _nombreController = TextEditingController(text: lugar?.NombreLugar ?? '');
    _direccionController = TextEditingController(text: lugar?.Direccion ?? '');
    _descripcionController = TextEditingController(text: lugar?.Descripcion ?? '');
    _precioController = TextEditingController(text: lugar?.Precio ?? '');
    _imagenController = TextEditingController(text: lugar?.Imagen ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _imagenController.dispose();
    super.dispose();
  }

  void _guardarLugar() async {
    if (_formKey.currentState!.validate()) {
      final nuevoLugar = Lugare(
        Id: widget.lugar?.Id ?? 0,
        NombreLugar: _nombreController.text,
        Direccion: _direccionController.text,
        Descripcion: _descripcionController.text,
        Precio: _precioController.text,
        Imagen: _imagenController.text,
      );

      bool exito = widget.lugar == null
          ? await createLugare(nuevoLugar)
          : await updateLugare(nuevoLugar);

      if (exito) {
        // Aquí indicamos que se guardó correctamente para que HomePage recargue
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar el lugar')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.lugar != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Lugar' : 'Agregar Lugar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese el nombre' : null,
              ),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese la dirección' : null,
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese la descripción' : null,
              ),
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese el precio';
                  if (double.tryParse(value) == null) return 'Precio inválido';
                  return null;
                },
              ),
              TextFormField(
                controller: _imagenController,
                decoration: const InputDecoration(labelText: 'URL de la imagen'),
                onChanged: (_) => setState(() {}),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese la URL de la imagen' : null,
              ),
              const SizedBox(height: 10),
              _imagenController.text.isNotEmpty
                  ? Image.network(
                      _imagenController.text,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Text('No se pudo cargar la imagen'),
                    )
                  : const Text('Vista previa de la imagen'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarLugar,
                child: Text(esEdicion ? 'Actualizar' : 'Crear'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}