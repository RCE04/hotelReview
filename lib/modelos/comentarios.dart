class Comentario {
  final int? id;
  final String comentarioLugar;
  final String puntuacion;
  final int lugarId;
  final int usuarioId;

  const Comentario({
    this.id,
    required this.comentarioLugar,
    required this.puntuacion,
    required this.lugarId,
    required this.usuarioId,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      id: json['id'],
      comentarioLugar: json['comentarioLugar'],
      puntuacion: json['puntuacion'],
      lugarId: json['lugarId'],
      usuarioId: json['usuarioId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comentarioLugar': comentarioLugar,
      'puntuacion': puntuacion,
      'lugarId': lugarId,
      'usuarioId': usuarioId,
    };
  }
}