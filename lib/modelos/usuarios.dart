class Usuario {
  final int? Id;
  final String NombreUsuario;
  final String Contrasena;
  final String Rol;
  final String? Favoritos;

  const Usuario({
    this.Id,
    required this.NombreUsuario,
    required this.Contrasena,
    required this.Rol,
    this.Favoritos,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      Id: json['id'],
      NombreUsuario: json['nombreUsuario'],
      Contrasena: json['contraseña'], // <- Ñ en el JSON
      Rol: json['rol'],
      Favoritos: json['favoritos'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombreUsuario': NombreUsuario,
      'contraseña': Contrasena, // <- Ñ en el JSON
      'rol': Rol,
      'favoritos': Favoritos,
    };
  }
}