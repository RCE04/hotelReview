class Usuario {
  final int? Id;
  final String NombreUsuario;
  final String Contrasena;
  final String Rol;

  const Usuario({
    this.Id,
    required this.NombreUsuario,
    required this.Contrasena,
    required this.Rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      Id: json['id'],
      NombreUsuario: json['nombreUsuario'],
      Contrasena: json['contraseña'], // <- Ñ en el JSON
      Rol: json['rol'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombreUsuario': NombreUsuario,
      'contraseña': Contrasena, // <- Ñ en el JSON
      'rol': Rol,
    };
  }
}