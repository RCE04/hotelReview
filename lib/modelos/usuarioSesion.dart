class UsuarioSesion {
  final int id;
  final String nombreUsuario;
  final String rol;

  UsuarioSesion({
    required this.id,
    required this.nombreUsuario,
    required this.rol,
  });

  factory UsuarioSesion.fromJson(Map<String, dynamic> json) {
    return UsuarioSesion(
      id: json['id'],
      nombreUsuario: json['nombreUsuario'],
      rol: json['rol'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreUsuario': nombreUsuario,
      'rol': rol,
    };
  }
}