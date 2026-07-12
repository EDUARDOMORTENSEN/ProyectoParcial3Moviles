import 'package:flutter/foundation.dart';
import '../../domain/entities/statistics_entity.dart';
import '../../domain/usecases/statistics/get_statistics_usecase.dart';

class StatisticsViewModel extends ChangeNotifier {
  final GetStatisticsUseCase _getStatisticsUseCase;

  StatisticsEntity? _statistics;
  bool _isLoading = false;
  String? _errorMessage;

  StatisticsViewModel({required GetStatisticsUseCase getStatisticsUseCase})
      : _getStatisticsUseCase = getStatisticsUseCase;

  StatisticsEntity? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadStatistics(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _statistics = await _getStatisticsUseCase(userId);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
