import '../entities/route_entity.dart';

abstract class RouteRepository {
  Future<void> saveRoute(RouteEntity route);
  Future<RouteEntity?> getRouteByTrainingId(String trainingId);
}
