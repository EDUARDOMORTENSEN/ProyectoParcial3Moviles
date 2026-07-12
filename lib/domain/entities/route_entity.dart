class RoutePoint {
  final double latitud;
  final double longitud;
  final double altitud;
  final DateTime timestamp;

  const RoutePoint({
    required this.latitud,
    required this.longitud,
    this.altitud = 0.0,
    required this.timestamp,
  });
}

class RouteEntity {
  final String id;
  final String entrenamientoId;
  final List<RoutePoint> puntos;

  const RouteEntity({
    required this.id,
    required this.entrenamientoId,
    this.puntos = const [],
  });

  RouteEntity copyWith({
    String? id,
    String? entrenamientoId,
    List<RoutePoint>? puntos,
  }) {
    return RouteEntity(
      id: id ?? this.id,
      entrenamientoId: entrenamientoId ?? this.entrenamientoId,
      puntos: puntos ?? this.puntos,
    );
  }
}
