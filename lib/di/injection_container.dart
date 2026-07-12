import '../data/datasources/local/gps_datasource.dart';
import '../data/datasources/local/sensor_datasource.dart';
import '../data/datasources/remote/firebase_auth_datasource.dart';
import '../data/datasources/remote/firestore_datasource.dart';
import '../data/datasources/remote/rest_api_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/training_repository_impl.dart';
import '../data/repositories/route_repository_impl.dart';
import '../data/repositories/statistics_repository_impl.dart';
import '../data/repositories/ranking_repository_impl.dart';
import '../data/services/location_service.dart';
import '../data/services/step_counter_service.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/training_repository.dart';
import '../domain/repositories/route_repository.dart';
import '../domain/repositories/statistics_repository.dart';
import '../domain/repositories/ranking_repository.dart';
import '../domain/usecases/auth/login_usecase.dart';
import '../domain/usecases/auth/register_usecase.dart';
import '../domain/usecases/auth/logout_usecase.dart';
import '../domain/usecases/training/training_usecases.dart';
import '../domain/usecases/statistics/get_statistics_usecase.dart';
import '../domain/usecases/ranking/get_ranking_usecase.dart';

class InjectionContainer {
  // Datasources
  late final FirebaseAuthDatasource firebaseAuthDatasource;
  late final FirestoreDatasource firestoreDatasource;
  late final RestApiDatasource restApiDatasource;
  late final GpsDatasource gpsDatasource;
  late final AccelerometerDatasource accelerometerDatasource;
  late final GyroscopeDatasource gyroscopeDatasource;

  // Repositories
  late final AuthRepository authRepository;
  late final TrainingRepository trainingRepository;
  late final RouteRepository routeRepository;
  late final StatisticsRepository statisticsRepository;
  late final RankingRepository rankingRepository;

  // Use Cases
  late final LoginUseCase loginUseCase;
  late final RegisterUseCase registerUseCase;
  late final LogoutUseCase logoutUseCase;
  late final SaveTrainingUseCase saveTrainingUseCase;
  late final GetTrainingHistoryUseCase getTrainingHistoryUseCase;
  late final GetStatisticsUseCase getStatisticsUseCase;
  late final GetRankingUseCase getRankingUseCase;

  // Services
  late final LocationService locationService;
  late final StepCounterService stepCounterService;

  InjectionContainer() {
    _initDatasources();
    _initRepositories();
    _initUseCases();
    _initServices();
  }

  void _initDatasources() {
    firebaseAuthDatasource = FirebaseAuthDatasource();
    firestoreDatasource = FirestoreDatasource();
    restApiDatasource = RestApiDatasource();
    gpsDatasource = GpsDatasource();
    accelerometerDatasource = AccelerometerDatasource();
    gyroscopeDatasource = GyroscopeDatasource();
  }

  void _initRepositories() {
    authRepository = AuthRepositoryImpl(firebaseAuthDatasource);
    trainingRepository = TrainingRepositoryImpl(firestoreDatasource);
    routeRepository = RouteRepositoryImpl(firestoreDatasource);
    statisticsRepository = StatisticsRepositoryImpl(firestoreDatasource);
    rankingRepository = RankingRepositoryImpl(firestoreDatasource);
  }

  void _initUseCases() {
    loginUseCase = LoginUseCase(authRepository);
    registerUseCase = RegisterUseCase(authRepository);
    logoutUseCase = LogoutUseCase(authRepository);
    saveTrainingUseCase = SaveTrainingUseCase(trainingRepository);
    getTrainingHistoryUseCase = GetTrainingHistoryUseCase(trainingRepository);
    getStatisticsUseCase = GetStatisticsUseCase(statisticsRepository);
    getRankingUseCase = GetRankingUseCase(rankingRepository);
  }

  void _initServices() {
    locationService = LocationService(gpsDatasource);
    stepCounterService = StepCounterService(accelerometerDatasource);
  }
}

// Global instance
final di = InjectionContainer();
