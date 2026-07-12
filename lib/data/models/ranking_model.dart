import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ranking_entity.dart';

class RankingModel extends RankingEntity {
  const RankingModel({
    required super.usuarioId,
    required super.nombre,
    super.fotoUrl,
    super.distanciaTotalKm,
    super.pasosTotal,
    super.entrenamientosTotal,
    super.posicion,
  });

  factory RankingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RankingModel(
      usuarioId: doc.id,
      nombre: data['nombre'] ?? '',
      fotoUrl: data['foto_url'],
      distanciaTotalKm: (data['distancia_total_km'] ?? 0).toDouble(),
      pasosTotal: data['pasos_total'] ?? 0,
      entrenamientosTotal: data['entrenamientos_total'] ?? 0,
      posicion: data['posicion'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'foto_url': fotoUrl,
      'distancia_total_km': distanciaTotalKm,
      'pasos_total': pasosTotal,
      'entrenamientos_total': entrenamientosTotal,
      'posicion': posicion,
    };
  }
}
