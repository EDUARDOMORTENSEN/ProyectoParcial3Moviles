import '../../domain/entities/route_entity.dart';
import '../../domain/repositories/route_repository.dart';
import '../datasources/remote/firestore_datasource.dart';
import '../models/route_model.dart';

class RouteRepositoryImpl implements RouteRepository {
  final FirestoreDatasource _firestoreDatasource;

  RouteRepositoryImpl(this._firestoreDatasource);

  @override
  Future<void> saveRoute(RouteEntity route) {
    final model = RouteModel(
      id: route.id,
      entrenamientoId: route.entrenamientoId,
      puntos: route.puntos,
    );
    return _firestoreDatasource.saveRoute(model);
  }

  @override
  Future<RouteEntity?> getRouteByTrainingId(String trainingId) {
    return _firestoreDatasource.getRouteByTrainingId(trainingId);
  }
}
