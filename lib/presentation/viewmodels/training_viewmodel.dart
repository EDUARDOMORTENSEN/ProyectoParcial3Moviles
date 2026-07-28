import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/training_entity.dart';
import '../../domain/entities/route_entity.dart';
import '../../domain/usecases/training/training_usecases.dart';
import '../../domain/repositories/route_repository.dart';
import '../../domain/repositories/ranking_repository.dart';
import '../../data/services/location_service.dart';
import '../../data/services/motion_sensor_service.dart';
import '../../data/services/step_counter_service.dart';
import '../../data/datasources/remote/rest_api_datasource.dart';

enum TrainingState { idle, active, paused, finished }

class TrainingViewModel extends ChangeNotifier {
  final SaveTrainingUseCase _saveTrainingUseCase;
  final GetTrainingHistoryUseCase _getTrainingHistoryUseCase;
  final RouteRepository _routeRepository;
  final RankingRepository _rankingRepository;
  final LocationService _locationService;
  final StepCounterService _stepCounterService;
  final MotionSensorService _motionSensorService;
  final RestApiDatasource _restApiDatasource;

  TrainingState _state = TrainingState.idle;
  String _trainingType = 'correr';
  DateTime? _startTime;
  int _elapsedSeconds = 0;
  double _calories = 0.0;
  double _weightKg = 70.0;
  WeatherData? _weatherData;
  bool _weatherFetched = false;
  bool _gpsReady = false;
  List<TrainingEntity> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  Timer? _timer;
  StreamSubscription? _positionSub;
  StreamSubscription? _stepSub;
  StreamSubscription? _motionSub;

  TrainingViewModel({
    required SaveTrainingUseCase saveTrainingUseCase,
    required GetTrainingHistoryUseCase getTrainingHistoryUseCase,
    required RouteRepository routeRepository,
    required RankingRepository rankingRepository,
    required LocationService locationService,
    required StepCounterService stepCounterService,
    required MotionSensorService motionSensorService,
    required RestApiDatasource restApiDatasource,
  })  : _saveTrainingUseCase = saveTrainingUseCase,
        _getTrainingHistoryUseCase = getTrainingHistoryUseCase,
        _routeRepository = routeRepository,
        _rankingRepository = rankingRepository,
        _locationService = locationService,
        _stepCounterService = stepCounterService,
        _motionSensorService = motionSensorService,
        _restApiDatasource = restApiDatasource;

  // Getters
  TrainingState get state => _state;
  String get trainingType => _trainingType;
  int get elapsedSeconds => _elapsedSeconds;
  int get steps => _stepCounterService.usingHardware
      ? _stepCounterService.stepCount
      : _motionSensorService.estimatedSteps;
  double get distanceKm => _locationService.totalDistance / 1000;
  double get currentSpeed => _locationService.currentSpeed;
  double get maxSpeed => _locationService.maxSpeed;
  /// True once the first GPS fix has arrived and the timer has started.
  /// UI uses this to show a "Esperando GPS…" indicator during cold start.
  bool get gpsReady => _gpsReady;
  /// True when a GPS fix has arrived in the last 10s. Used by the UI to
  /// show "0.0" instead of a stale speed value when the user is stationary
  /// (distanceFilter suppresses fixes, so the last speed would otherwise
  /// be displayed indefinitely). _currentSpeed is left untouched so
  /// derivation on resume still works correctly.
  bool get isMoving => _locationService.lastFixTime != null &&
      DateTime.now().difference(_locationService.lastFixTime!).inSeconds < 10;
  double get calories => _calories;
  Position? get currentPosition => _locationService.currentPosition;
  WeatherData? get weatherData => _weatherData;
  List<TrainingEntity> get history => _history;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<RoutePoint> get routePoints => _locationService.routePoints;
  Stream<Position> get positionStream => _locationService.positionStream;

  // Motion sensor getters
  double get accelMagnitude => _motionSensorService.accelerationMagnitude;
  double get gyroMagnitude => _motionSensorService.gyroscopeMagnitude;
  String get activityIntensity => _motionSensorService.activityIntensity;
  int get turnCount => _motionSensorService.turnCount;
  bool get isMovingByAccel => _motionSensorService.isMovingByAccel;
  double get orientationChangeRate => _motionSensorService.orientationChangeRate;
  bool get usingHardwareSteps => _stepCounterService.usingHardware;
  int get estimatedSteps => _motionSensorService.estimatedSteps;

  String get formattedTime {
    final hours = _elapsedSeconds ~/ 3600;
    final minutes = (_elapsedSeconds % 3600) ~/ 60;
    final seconds = _elapsedSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void setTrainingType(String type) {
    _trainingType = type;
    notifyListeners();
  }

  Future<void> startTraining({double? weightKg}) async {
    try {
      _weightKg = weightKg ?? 70.0;
      _state = TrainingState.active;
      _startTime = null;
      _elapsedSeconds = 0;
      _calories = 0.0;
      _weatherFetched = false;
      _gpsReady = false;
      notifyListeners();

      // Start location tracking
      await _locationService.startTracking();

      // Start step counter
      _stepCounterService.startCounting();

      // Start motion sensors (accelerometer + gyroscope)
      _motionSensorService.start();

      // Position stream fires on every fix — that's also when distance
      // and speed change in LocationService, so this single subscription
      // covers all three for the UI refresh.
      _positionSub = _locationService.positionStream.listen((position) {
        // Defer timer + _startTime until the first GPS fix: cold start can
        // take 10-30s, and starting the clock at t=0 would inflate
        // duracionSegundos and corrupt velocidadPromedio with warmup time
        // the user wasn't actually moving for.
        if (!_gpsReady) {
          _gpsReady = true;
          _startTime = DateTime.now();
          _timer = Timer.periodic(const Duration(seconds: 1), (_) {
            if (_state == TrainingState.active) {
              _elapsedSeconds++;
              _updateCalories();
              notifyListeners();
            }
          });
        }
        notifyListeners();
        if (!_weatherFetched) {
          _weatherFetched = true;
          _fetchWeather();
        }
      });

      // Listen to step updates
      _stepSub = _stepCounterService.stepStream.listen((_) {
        notifyListeners();
      });

      // Listen to motion sensor updates
      _motionSub = _motionSensorService.stream.listen((_) {
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = e.toString();
      _state = TrainingState.idle;
      notifyListeners();
    }
  }

  void pauseTraining() {
    _state = TrainingState.paused;
    _locationService.pause();
    _stepCounterService.pause();
    _motionSensorService.pause();
    notifyListeners();
  }

  void resumeTraining() {
    _state = TrainingState.active;
    _locationService.resume();
    _stepCounterService.resume();
    _motionSensorService.resume();
    notifyListeners();
  }

  Future<TrainingEntity?> stopTraining(String userId) async {
    _state = TrainingState.finished;
    _timer?.cancel();
    _locationService.stopTracking();
    _stepCounterService.stopCounting();
    _motionSensorService.stop();
    _positionSub?.cancel();
    _stepSub?.cancel();
    _motionSub?.cancel();
    _gpsReady = false;
    notifyListeners();

    final trainingId = const Uuid().v4();
    final routeId = const Uuid().v4();

    final avgSpeed = _elapsedSeconds > 0
        ? (distanceKm / (_elapsedSeconds / 3600))
        : 0.0;

    final training = TrainingEntity(
      id: trainingId,
      usuarioId: userId,
      tipo: _trainingType,
      fechaInicio: _startTime ?? DateTime.now(),
      fechaFin: DateTime.now(),
      duracionSegundos: _elapsedSeconds,
      distanciaKm: distanceKm,
      pasos: steps,
      calorias: _calories,
      velocidadPromedio: avgSpeed,
      velocidadMaxima: maxSpeed,
      rutaId: routeId,
      intensidadPromedio: _determineAverageIntensity(),
      girosDetectados: _motionSensorService.turnCount,
    );

    return training;
  }

  Future<void> saveTrainingData(TrainingEntity training, String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Save training
      await _saveTrainingUseCase(training);

      // Save route
      final route = RouteEntity(
        id: training.rutaId ?? const Uuid().v4(),
        entrenamientoId: training.id,
        puntos: _locationService.routePoints,
      );
      await _routeRepository.saveRoute(route);

      // Update ranking
      await _rankingRepository.updateRanking(userId);

      _state = TrainingState.idle;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _history = await _getTrainingHistoryUseCase(userId);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void _updateCalories() {
    // MET-based calorie estimation
    double met;
    switch (_trainingType) {
      case 'correr':
        met = 9.8;
        break;
      case 'caminar':
        met = 3.8;
        break;
      case 'ciclismo':
        met = 7.5;
        break;
      default:
        met = 5.0;
    }
    // Calories = MET × weight(kg) × time(hours)
    _calories = met * _weightKg * (_elapsedSeconds / 3600);
  }

  String _determineAverageIntensity() {
    final avg = _motionSensorService.averageAcceleration;
    final deviation = (avg - 9.8).abs();
    if (deviation < 1.5) return 'Baja';
    if (deviation < 2.5) return 'Media';
    return 'Alta';
  }

  Future<void> _fetchWeather() async {
    try {
      final pos = currentPosition;
      if (pos != null) {
        _weatherData = await _restApiDatasource.getWeather(
          pos.latitude,
          pos.longitude,
        );
        notifyListeners();
      }
    } catch (_) {
      // Weather is optional, don't fail the training
    }
  }

  void discardTraining() {
    _timer?.cancel();
    _locationService.stopTracking();
    _stepCounterService.stopCounting();
    _motionSensorService.reset();
    _positionSub?.cancel();
    _stepSub?.cancel();
    _motionSub?.cancel();
    _weatherFetched = false;
    _gpsReady = false;
    _state = TrainingState.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionSub?.cancel();
    _stepSub?.cancel();
    _motionSub?.cancel();
    super.dispose();
  }
}
