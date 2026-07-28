import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/training_entity.dart';

class TrainingModel extends TrainingEntity {
  const TrainingModel({
    required super.id,
    required super.usuarioId,
    required super.tipo,
    required super.fechaInicio,
    super.fechaFin,
    super.duracionSegundos,
    super.distanciaKm,
    super.pasos,
    super.calorias,
    super.velocidadPromedio,
    super.velocidadMaxima,
    super.rutaId,
    super.intensidadPromedio,
    super.girosDetectados,
  });

  factory TrainingModel.fromEntity(TrainingEntity entity) {
    return TrainingModel(
      id: entity.id,
      usuarioId: entity.usuarioId,
      tipo: entity.tipo,
      fechaInicio: entity.fechaInicio,
      fechaFin: entity.fechaFin,
      duracionSegundos: entity.duracionSegundos,
      distanciaKm: entity.distanciaKm,
      pasos: entity.pasos,
      calorias: entity.calorias,
      velocidadPromedio: entity.velocidadPromedio,
      velocidadMaxima: entity.velocidadMaxima,
      rutaId: entity.rutaId,
      intensidadPromedio: entity.intensidadPromedio,
      girosDetectados: entity.girosDetectados,
    );
  }

  factory TrainingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TrainingModel(
      id: doc.id,
      usuarioId: data['usuario_id'] ?? '',
      tipo: data['tipo'] ?? 'correr',
      fechaInicio: (data['fecha_inicio'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaFin: (data['fecha_fin'] as Timestamp?)?.toDate(),
      duracionSegundos: data['duracion_segundos'] ?? 0,
      distanciaKm: (data['distancia_km'] ?? 0).toDouble(),
      pasos: data['pasos'] ?? 0,
      calorias: (data['calorias'] ?? 0).toDouble(),
      velocidadPromedio: (data['velocidad_promedio'] ?? 0).toDouble(),
      velocidadMaxima: (data['velocidad_maxima'] ?? 0).toDouble(),
      rutaId: data['ruta_id'],
      intensidadPromedio: data['intensidad_promedio'],
      girosDetectados: data['giros_detectados'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'tipo': tipo,
      'fecha_inicio': Timestamp.fromDate(fechaInicio),
      'fecha_fin': fechaFin != null ? Timestamp.fromDate(fechaFin!) : null,
      'duracion_segundos': duracionSegundos,
      'distancia_km': distanciaKm,
      'pasos': pasos,
      'calorias': calorias,
      'velocidad_promedio': velocidadPromedio,
      'velocidad_maxima': velocidadMaxima,
      'ruta_id': rutaId,
      'intensidad_promedio': intensidadPromedio,
      'giros_detectados': girosDetectados,
    };
  }
}
