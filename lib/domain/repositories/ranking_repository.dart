import '../entities/ranking_entity.dart';

abstract class RankingRepository {
  Future<List<RankingEntity>> getRanking({String periodo = 'total'});
  Future<void> updateRanking(String userId);
}
