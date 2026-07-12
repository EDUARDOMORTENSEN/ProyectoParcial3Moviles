import '../entities/training_entity.dart';

abstract class TrainingRepository {
  Future<void> saveTraining(TrainingEntity training);
  Future<List<TrainingEntity>> getTrainingHistory(String userId);
  Future<TrainingEntity?> getTrainingById(String trainingId);
  Future<void> deleteTraining(String trainingId);
}
