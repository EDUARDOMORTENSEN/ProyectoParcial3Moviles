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

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('usuarios').doc(userId).update(data);
  }
}
