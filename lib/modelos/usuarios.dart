class Usuario {
  int? Id;
  String NombreUsuario;
  String Contrasena;
  String Rol;
  String? Favoritos;

  Usuario({
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
      Contrasena: json['contraseña'],
      Rol: json['rol'],
      Favoritos: json['favoritos'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': Id,
      'nombreUsuario': NombreUsuario,
      'contraseña': Contrasena,
      'rol': Rol,
      'favoritos': Favoritos,
    };
  }
}