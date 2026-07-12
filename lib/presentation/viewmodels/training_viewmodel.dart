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
  final RestApiDatasource _restApiDatasource;

  TrainingState _state = TrainingState.idle;
  String _trainingType = 'correr';
  DateTime? _startTime;
  int _elapsedSeconds = 0;
  int _steps = 0;
  double _distanceKm = 0.0;
  double _currentSpeed = 0.0;
  double _maxSpeed = 0.0;
  double _calories = 0.0;
  Position? _currentPosition;
  WeatherData? _weatherData;
  List<TrainingEntity> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  Timer? _timer;
  StreamSubscription? _positionSub;
  StreamSubscription? _distanceSub;
  StreamSubscription? _speedSub;
  StreamSubscription? _stepSub;

  TrainingViewModel({
    required SaveTrainingUseCase saveTrainingUseCase,
    required GetTrainingHistoryUseCase getTrainingHistoryUseCase,
    required RouteRepository routeRepository,
    required RankingRepository rankingRepository,
    required LocationService locationService,
    required StepCounterService stepCounterService,
    required RestApiDatasource restApiDatasource,
  })  : _saveTrainingUseCase = saveTrainingUseCase,
        _getTrainingHistoryUseCase = getTrainingHistoryUseCase,
        _routeRepository = routeRepository,
        _rankingRepository = rankingRepository,
        _locationService = locationService,
        _stepCounterService = stepCounterService,
        _restApiDatasource = restApiDatasource;

  // Getters
  TrainingState get state => _state;
  String get trainingType => _trainingType;
  int get elapsedSeconds => _elapsedSeconds;
  int get steps => _steps;
  double get distanceKm => _distanceKm;
  double get currentSpeed => _currentSpeed;
  double get maxSpeed => _maxSpeed;
  double get calories => _calories;
  Position? get currentPosition => _currentPosition;
  WeatherData? get weatherData => _weatherData;
  List<TrainingEntity> get history => _history;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<RoutePoint> get routePoints => _locationService.routePoints;

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

  Future<void> startTraining() async {
    try {
      _state = TrainingState.active;
      _startTime = DateTime.now();
      _elapsedSeconds = 0;
      _steps = 0;
      _distanceKm = 0.0;
      _currentSpeed = 0.0;
      _maxSpeed = 0.0;
      _calories = 0.0;
      notifyListeners();

      // Start location tracking
      await _locationService.startTracking();

      // Start step counter
      _stepCounterService.startCounting();

      // Start timer
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_state == TrainingState.active) {
          _elapsedSeconds++;
          _updateCalories();
          notifyListeners();
        }
      });

      // Listen to position updates
      _positionSub = _locationService.positionStream.listen((position) {
        _currentPosition = position;
        notifyListeners();
      });

      // Listen to distance updates
      _distanceSub = _locationService.distanceStream.listen((distance) {
        _distanceKm = distance / 1000; // meters to km
        notifyListeners();
      });

      // Listen to speed updates
      _speedSub = _locationService.speedStream.listen((speed) {
        _currentSpeed = speed;
        if (speed > _maxSpeed) _maxSpeed = speed;
        notifyListeners();
      });

      // Listen to step updates
      _stepSub = _stepCounterService.stepStream.listen((steps) {
        _steps = steps;
        notifyListeners();
      });

      // Fetch weather
      _fetchWeather();
    } catch (e) {
      _errorMessage = e.toString();
      _state = TrainingState.idle;
      notifyListeners();
    }
  }

  void pauseTraining() {
    _state = TrainingState.paused;
    notifyListeners();
  }

  void resumeTraining() {
    _state = TrainingState.active;
    notifyListeners();
  }

  Future<TrainingEntity?> stopTraining(String userId) async {
    _state = TrainingState.finished;
    _timer?.cancel();
    _locationService.stopTracking();
    _stepCounterService.stopCounting();
    _positionSub?.cancel();
    _distanceSub?.cancel();
    _speedSub?.cancel();
    _stepSub?.cancel();
    notifyListeners();

    final trainingId = const Uuid().v4();
    final routeId = const Uuid().v4();

    final avgSpeed = _elapsedSeconds > 0
        ? (_distanceKm / (_elapsedSeconds / 3600))
        : 0.0;

    final training = TrainingEntity(
      id: trainingId,
      usuarioId: userId,
      tipo: _trainingType,
      fechaInicio: _startTime ?? DateTime.now(),
      fechaFin: DateTime.now(),
      duracionSegundos: _elapsedSeconds,
      distanciaKm: _distanceKm,
      pasos: _steps,
      calorias: _calories,
      velocidadPromedio: avgSpeed,
      velocidadMaxima: _maxSpeed,
      rutaId: routeId,
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
    _calories = met * 70 * (_elapsedSeconds / 3600); // Assume 70kg default
  }

  Future<void> _fetchWeather() async {
    try {
      if (_currentPosition != null) {
        _weatherData = await _restApiDatasource.getWeather(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
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
    _positionSub?.cancel();
    _distanceSub?.cancel();
    _speedSub?.cancel();
    _stepSub?.cancel();
    _state = TrainingState.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionSub?.cancel();
    _distanceSub?.cancel();
    _speedSub?.cancel();
    _stepSub?.cancel();
    super.dispose();
  }
}
