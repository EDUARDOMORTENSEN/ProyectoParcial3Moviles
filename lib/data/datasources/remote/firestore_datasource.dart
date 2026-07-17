import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/training_model.dart';
import '../../models/route_model.dart';
import '../../models/statistics_model.dart';
import '../../models/ranking_model.dart';
import '../../models/user_model.dart';

class FirestoreDatasource {
  final FirebaseFirestore _firestore;

  FirestoreDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ─── Training ───
  Future<void> saveTraining(TrainingModel training) async {
    await _firestore
        .collection('entrenamientos')
        .doc(training.id)
        .set(training.toJson());
  }

  Future<List<TrainingModel>> getTrainingHistory(String userId) async {
    final snapshot = await _firestore
        .collection('entrenamientos')
        .where('usuario_id', isEqualTo: userId)
        .orderBy('fecha_inicio', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => TrainingModel.fromFirestore(doc))
        .toList();
  }

  Future<TrainingModel?> getTrainingById(String trainingId) async {
    final doc =
        await _firestore.collection('entrenamientos').doc(trainingId).get();
    if (!doc.exists) return null;
    return TrainingModel.fromFirestore(doc);
  }

  Future<void> deleteTraining(String trainingId) async {
    await _firestore.collection('entrenamientos').doc(trainingId).delete();
  }

  // ─── Route ───
  Future<void> saveRoute(RouteModel route) async {
    await _firestore.collection('rutas').doc(route.id).set(route.toJson());
  }

  Future<RouteModel?> getRouteByTrainingId(String trainingId) async {
    final snapshot = await _firestore
        .collection('rutas')
        .where('entrenamiento_id', isEqualTo: trainingId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return RouteModel.fromFirestore(snapshot.docs.first);
  }

  // ─── Statistics ───
  Future<StatisticsModel> getStatistics(String userId) async {
    final doc = await _firestore.collection('estadisticas').doc(userId).get();
    if (!doc.exists) {
      return StatisticsModel(usuarioId: userId);
    }
    return StatisticsModel.fromFirestore(doc);
  }

  Future<void> updateStatistics(
      String userId, StatisticsModel stats) async {
    await _firestore
        .collection('estadisticas')
        .doc(userId)
        .set(stats.toJson(), SetOptions(merge: true));
  }

  // ─── Ranking ───
  Future<List<RankingModel>> getRanking() async {
    final snapshot = await _firestore
        .collection('ranking')
        .orderBy('distancia_total_km', descending: true)
        .limit(50)
        .get();
    return snapshot.docs
        .map((doc) => RankingModel.fromFirestore(doc))
        .toList();
  }

  Future<void> updateRanking(String userId, RankingModel ranking) async {
    await _firestore
        .collection('ranking')
        .doc(userId)
        .set(ranking.toJson(), SetOptions(merge: true));
  }

  // ─── User ───
  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('usuarios').doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> updateUserStatsFromTraining(String userId, TrainingModel training) async {
    final batch = _firestore.batch();

    // 1. Increment in users collection
    final userRef = _firestore.collection('usuarios').doc(userId);
    batch.update(userRef, {
      'total_entrenamientos': FieldValue.increment(1),
      'total_distancia': FieldValue.increment(training.distanciaKm),
      'total_pasos': FieldValue.increment(training.pasos),
    });

    // 2. Increment in statistics collection
    final statsRef = _firestore.collection('estadisticas').doc(userId);
    batch.set(statsRef, {
      'semana_actual': {
        'entrenamientos': FieldValue.increment(1),
        'distancia_total': FieldValue.increment(training.distanciaKm),
        'pasos_total': FieldValue.increment(training.pasos),
        'tiempo_total': FieldValue.increment(training.duracionSegundos),
      },
      'mes_actual': {
        'entrenamientos': FieldValue.increment(1),
        'distancia_total': FieldValue.increment(training.distanciaKm),
        'pasos_total': FieldValue.increment(training.pasos),
        'tiempo_total': FieldValue.increment(training.duracionSegundos),
      }
    }, SetOptions(merge: true));

    await batch.commit();

    // 3. Update bests (requires reading the current stats, but for now we skip or do it separately)
    // For simplicity, we just use the atomic increments for the totals which were broken.
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('usuarios').doc(userId).update(data);
  }
}
