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
      // Aquí es donde tienes que añadir la línea 'id': Id,
      'id': Id,  // <- Agregado para que el backend reciba el id y no dé error 400
      'nombreUsuario': NombreUsuario,
      'contraseña': Contrasena,
      'rol': Rol,
      'favoritos': Favoritos,
    };
  }
}