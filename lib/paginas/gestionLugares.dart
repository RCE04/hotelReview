import 'package:flutter/material.dart';

class GestionLugaresPage extends StatelessWidget {
  const GestionLugaresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Lugares')),
      body: const Center(child: Text('Aquí se gestionan los lugares')),
    );
  }
}