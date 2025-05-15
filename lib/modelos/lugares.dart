class Lugare {
  final int Id;
  final String NombreLugar;
  final String Direccion;
  final String Descripcion;
  final String Precio;

  const Lugare({
    required this.Id,
    required this.NombreLugar,
    required this.Direccion,
    required this.Descripcion,
    required this.Precio,
  });

  factory Lugare.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'nombreLugar': String nombreLugar,
        'direccion': String direccion,
        'descripcion': String descripcion,
        'precio': String precio,
      } =>
        Lugare(
          Id: id,
          NombreLugar: nombreLugar,
          Direccion: direccion,
          Descripcion: descripcion,
          Precio: precio,
        ),
      _ => throw const FormatException('Failed to load lugar.'),
    };
  }

  Map<String, dynamic> toJson() => {
        'id': Id,
        'nombreLugar': NombreLugar,
        'direccion': Direccion,
        'descripcion': Descripcion,
        'precio': Precio,
      };
}