import '../../entities/training_entity.dart';
import '../../repositories/training_repository.dart';

class SaveTrainingUseCase {
  final TrainingRepository _repository;

  SaveTrainingUseCase(this._repository);

  Future<void> call(TrainingEntity training) {
    return _repository.saveTraining(training);
  }
}

class GetTrainingHistoryUseCase {
  final TrainingRepository _repository;

  GetTrainingHistoryUseCase(this._repository);

  Future<List<TrainingEntity>> call(String userId) {
    return _repository.getTrainingHistory(userId);
  }
}
