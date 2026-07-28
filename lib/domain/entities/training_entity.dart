class TrainingEntity {
  final String id;
  final String usuarioId;
  final String tipo; // correr, caminar, ciclismo
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final int duracionSegundos;
  final double distanciaKm;
  final int pasos;
  final double calorias;
  final double velocidadPromedio;
  final double velocidadMaxima;
  final String? rutaId;
  final String? intensidadPromedio; // "Baja", "Media", "Alta"
  final int? girosDetectados;

  const TrainingEntity({
    required this.id,
    required this.usuarioId,
    required this.tipo,
    required this.fechaInicio,
    this.fechaFin,
    this.duracionSegundos = 0,
    this.distanciaKm = 0.0,
    this.pasos = 0,
    this.calorias = 0.0,
    this.velocidadPromedio = 0.0,
    this.velocidadMaxima = 0.0,
    this.rutaId,
    this.intensidadPromedio,
    this.girosDetectados,
  });

  TrainingEntity copyWith({
    String? id,
    String? usuarioId,
    String? tipo,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? duracionSegundos,
    double? distanciaKm,
    int? pasos,
    double? calorias,
    double? velocidadPromedio,
    double? velocidadMaxima,
    String? rutaId,
    String? intensidadPromedio,
    int? girosDetectados,
  }) {
    return TrainingEntity(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      tipo: tipo ?? this.tipo,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      duracionSegundos: duracionSegundos ?? this.duracionSegundos,
      distanciaKm: distanciaKm ?? this.distanciaKm,
      pasos: pasos ?? this.pasos,
      calorias: calorias ?? this.calorias,
      velocidadPromedio: velocidadPromedio ?? this.velocidadPromedio,
      velocidadMaxima: velocidadMaxima ?? this.velocidadMaxima,
      rutaId: rutaId ?? this.rutaId,
      intensidadPromedio: intensidadPromedio ?? this.intensidadPromedio,
      girosDetectados: girosDetectados ?? this.girosDetectados,
    );
  }
}
