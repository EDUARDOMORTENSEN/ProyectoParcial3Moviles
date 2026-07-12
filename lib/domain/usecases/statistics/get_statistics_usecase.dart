import '../../entities/statistics_entity.dart';
import '../../repositories/statistics_repository.dart';

class GetStatisticsUseCase {
  final StatisticsRepository _repository;

  GetStatisticsUseCase(this._repository);

  Future<StatisticsEntity> call(String userId) {
    return _repository.getStatistics(userId);
  }
}
