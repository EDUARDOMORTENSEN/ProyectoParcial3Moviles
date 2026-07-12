import 'package:flutter/foundation.dart';
import '../../domain/entities/ranking_entity.dart';
import '../../domain/usecases/ranking/get_ranking_usecase.dart';

class RankingViewModel extends ChangeNotifier {
  final GetRankingUseCase _getRankingUseCase;

  List<RankingEntity> _rankings = [];
  bool _isLoading = false;
  String? _errorMessage;

  RankingViewModel({required GetRankingUseCase getRankingUseCase})
      : _getRankingUseCase = getRankingUseCase;

  List<RankingEntity> get rankings => _rankings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadRanking({String periodo = 'total'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _rankings = await _getRankingUseCase(periodo: periodo);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
