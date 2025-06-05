import 'package:flutter/material.dart';
import 'paginas/formularioCrearUsuario.dart';
import 'paginas/inicioSesion.dart';
import 'paginas/formularioComentario.dart';
import 'paginas/lugarDetalle.dart';
import 'paginas/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HotelReview',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const InicioSesionPage(),
        '/registro': (context) => const FormularioCrearUsuario(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/crearComentario') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => FormularioComentario(
              lugarId: args['lugarId'],
              usuarioId: args['usuarioId'],
            ),
          );
        }

        // Ruta desconocida
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
      },
    );
  }
}