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

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
      );

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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9, // ancho dinámico 90%
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF6A1B9A),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 12),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nombreController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco('Nombre'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingrese el nombre' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _direccionController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco('Dirección'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingrese la dirección' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descripcionController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco('Descripción'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingrese la descripción' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _precioController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco('Precio'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingrese el precio';
                      if (double.tryParse(value) == null) return 'Precio inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _imagenController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco('URL de la imagen'),
                    onChanged: (_) => setState(() {}),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingrese la URL de la imagen' : null,
                  ),
                  const SizedBox(height: 10),
                  _imagenController.text.isNotEmpty
                      ? Image.network(
                          _imagenController.text,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Text('No se pudo cargar la imagen', style: TextStyle(color: Colors.white70)),
                        )
                      : const Text('Vista previa de la imagen', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _guardarLugar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(esEdicion ? 'Actualizar' : 'Crear'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}