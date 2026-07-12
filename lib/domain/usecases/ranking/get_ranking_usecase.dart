import '../../entities/ranking_entity.dart';
import '../../repositories/ranking_repository.dart';

class GetRankingUseCase {
  final RankingRepository _repository;

  GetRankingUseCase(this._repository);

  Future<List<RankingEntity>> call({String periodo = 'total'}) {
    return _repository.getRanking(periodo: periodo);
  }
}
