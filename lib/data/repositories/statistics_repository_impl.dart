import '../../domain/entities/statistics_entity.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/remote/firestore_datasource.dart';
import '../models/statistics_model.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final FirestoreDatasource _firestoreDatasource;

  StatisticsRepositoryImpl(this._firestoreDatasource);

  @override
  Future<StatisticsEntity> getStatistics(String userId) {
    return _firestoreDatasource.getStatistics(userId);
  }

  @override
  Future<void> updateStatistics(String userId, StatisticsEntity stats) {
    final model = StatisticsModel(
      usuarioId: stats.usuarioId,
      semanaActual: stats.semanaActual,
      mesActual: stats.mesActual,
      mejorDistancia: stats.mejorDistancia,
      mejorTiempo: stats.mejorTiempo,
      rachaDias: stats.rachaDias,
    );
    return _firestoreDatasource.updateStatistics(userId, model);
  }
}
