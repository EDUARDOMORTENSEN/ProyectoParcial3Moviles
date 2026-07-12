import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/statistics_entity.dart';

class PeriodStatsModel extends PeriodStats {
  const PeriodStatsModel({
    super.distanciaTotal,
    super.pasosTotal,
    super.tiempoTotal,
    super.entrenamientos,
  });

  factory PeriodStatsModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const PeriodStatsModel();
    return PeriodStatsModel(
      distanciaTotal: (map['distancia_total'] ?? 0).toDouble(),
      pasosTotal: map['pasos_total'] ?? 0,
      tiempoTotal: map['tiempo_total'] ?? 0,
      entrenamientos: map['entrenamientos'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distancia_total': distanciaTotal,
      'pasos_total': pasosTotal,
      'tiempo_total': tiempoTotal,
      'entrenamientos': entrenamientos,
    };
  }
}

class StatisticsModel extends StatisticsEntity {
  const StatisticsModel({
    required super.usuarioId,
    super.semanaActual,
    super.mesActual,
    super.mejorDistancia,
    super.mejorTiempo,
    super.rachaDias,
  });

  factory StatisticsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StatisticsModel(
      usuarioId: doc.id,
      semanaActual: PeriodStatsModel.fromMap(
          data['semana_actual'] as Map<String, dynamic>?),
      mesActual:
          PeriodStatsModel.fromMap(data['mes_actual'] as Map<String, dynamic>?),
      mejorDistancia: (data['mejor_distancia'] ?? 0).toDouble(),
      mejorTiempo: data['mejor_tiempo'] ?? 0,
      rachaDias: data['racha_dias'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'semana_actual':
          PeriodStatsModel(
            distanciaTotal: semanaActual.distanciaTotal,
            pasosTotal: semanaActual.pasosTotal,
            tiempoTotal: semanaActual.tiempoTotal,
            entrenamientos: semanaActual.entrenamientos,
          ).toJson(),
      'mes_actual':
          PeriodStatsModel(
            distanciaTotal: mesActual.distanciaTotal,
            pasosTotal: mesActual.pasosTotal,
            tiempoTotal: mesActual.tiempoTotal,
            entrenamientos: mesActual.entrenamientos,
          ).toJson(),
      'mejor_distancia': mejorDistancia,
      'mejor_tiempo': mejorTiempo,
      'racha_dias': rachaDias,
    };
  }
}
