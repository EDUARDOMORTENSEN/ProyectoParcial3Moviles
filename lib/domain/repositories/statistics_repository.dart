import '../entities/statistics_entity.dart';

abstract class StatisticsRepository {
  Future<StatisticsEntity> getStatistics(String userId);
  Future<void> updateStatistics(String userId, StatisticsEntity stats);
}
