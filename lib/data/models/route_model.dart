import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/route_entity.dart';

class RoutePointModel extends RoutePoint {
  const RoutePointModel({
    required super.latitud,
    required super.longitud,
    super.altitud,
    required super.timestamp,
  });

  factory RoutePointModel.fromMap(Map<String, dynamic> map) {
    return RoutePointModel(
      latitud: (map['latitud'] ?? 0).toDouble(),
      longitud: (map['longitud'] ?? 0).toDouble(),
      altitud: (map['altitud'] ?? 0).toDouble(),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitud': latitud,
      'longitud': longitud,
      'altitud': altitud,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class RouteModel extends RouteEntity {
  const RouteModel({
    required super.id,
    required super.entrenamientoId,
    super.puntos,
  });

  factory RouteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final List<dynamic> puntosData = data['puntos'] ?? [];
    return RouteModel(
      id: doc.id,
      entrenamientoId: data['entrenamiento_id'] ?? '',
      puntos: puntosData
          .map((p) => RoutePointModel.fromMap(p as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entrenamiento_id': entrenamientoId,
      'puntos': puntos
          .map((p) => RoutePointModel(
                latitud: p.latitud,
                longitud: p.longitud,
                altitud: p.altitud,
                timestamp: p.timestamp,
              ).toJson())
          .toList(),
    };
  }
}
