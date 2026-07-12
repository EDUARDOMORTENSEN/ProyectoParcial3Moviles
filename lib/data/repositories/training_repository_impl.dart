import '../../domain/entities/training_entity.dart';
import '../../domain/repositories/training_repository.dart';
import '../datasources/remote/firestore_datasource.dart';
import '../models/training_model.dart';

class TrainingRepositoryImpl implements TrainingRepository {
  final FirestoreDatasource _firestoreDatasource;

  TrainingRepositoryImpl(this._firestoreDatasource);

  @override
  Future<void> saveTraining(TrainingEntity training) {
    final model = TrainingModel.fromEntity(training);
    return _firestoreDatasource.saveTraining(model);
  }

  @override
  Future<List<TrainingEntity>> getTrainingHistory(String userId) {
    return _firestoreDatasource.getTrainingHistory(userId);
  }

  @override
  Future<TrainingEntity?> getTrainingById(String trainingId) {
    return _firestoreDatasource.getTrainingById(trainingId);
  }

  @override
  Future<void> deleteTraining(String trainingId) {
    return _firestoreDatasource.deleteTraining(trainingId);
  }
}
