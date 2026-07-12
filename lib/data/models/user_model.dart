import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.nombre,
    required super.email,
    super.fotoUrl,
    required super.peso,
    required super.altura,
    required super.fechaRegistro,
    super.totalEntrenamientos,
    super.totalDistancia,
    super.totalPasos,
  });

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      nombre: entity.nombre,
      email: entity.email,
      fotoUrl: entity.fotoUrl,
      peso: entity.peso,
      altura: entity.altura,
      fechaRegistro: entity.fechaRegistro,
      totalEntrenamientos: entity.totalEntrenamientos,
      totalDistancia: entity.totalDistancia,
      totalPasos: entity.totalPasos,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
      fotoUrl: data['foto_url'],
      peso: (data['peso'] ?? 0).toDouble(),
      altura: (data['altura'] ?? 0).toDouble(),
      fechaRegistro: (data['fecha_registro'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalEntrenamientos: data['total_entrenamientos'] ?? 0,
      totalDistancia: (data['total_distancia'] ?? 0).toDouble(),
      totalPasos: data['total_pasos'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'email': email,
      'foto_url': fotoUrl,
      'peso': peso,
      'altura': altura,
      'fecha_registro': Timestamp.fromDate(fechaRegistro),
      'total_entrenamientos': totalEntrenamientos,
      'total_distancia': totalDistancia,
      'total_pasos': totalPasos,
    };
  }
}
