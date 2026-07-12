import '../../domain/entities/ranking_entity.dart';
import '../../domain/repositories/ranking_repository.dart';
import '../datasources/remote/firestore_datasource.dart';
import '../models/ranking_model.dart';

class RankingRepositoryImpl implements RankingRepository {
  final FirestoreDatasource _firestoreDatasource;

  RankingRepositoryImpl(this._firestoreDatasource);

  @override
  Future<List<RankingEntity>> getRanking({String periodo = 'total'}) {
    return _firestoreDatasource.getRanking();
  }

  @override
  Future<void> updateRanking(String userId) async {
    final user = await _firestoreDatasource.getUser(userId);
    if (user == null) return;

    final ranking = RankingModel(
      usuarioId: userId,
      nombre: user.nombre,
      fotoUrl: user.fotoUrl,
      distanciaTotalKm: user.totalDistancia,
      pasosTotal: user.totalPasos,
      entrenamientosTotal: user.totalEntrenamientos,
    );

    await _firestoreDatasource.updateRanking(userId, ranking);
  }
}
