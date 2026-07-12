class RankingEntity {
  final String usuarioId;
  final String nombre;
  final String? fotoUrl;
  final double distanciaTotalKm;
  final int pasosTotal;
  final int entrenamientosTotal;
  final int posicion;

  const RankingEntity({
    required this.usuarioId,
    required this.nombre,
    this.fotoUrl,
    this.distanciaTotalKm = 0.0,
    this.pasosTotal = 0,
    this.entrenamientosTotal = 0,
    this.posicion = 0,
  });
}
