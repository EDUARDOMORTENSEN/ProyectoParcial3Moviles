import 'dart:async';
import '../datasources/local/sensor_datasource.dart';

/// Step counter using accelerometer peak detection algorithm
class StepCounterService {
  final AccelerometerDatasource _accelerometerDatasource;

  StreamSubscription? _subscription;
  int _stepCount = 0;
  final _stepController = StreamController<int>.broadcast();

  // Step detection parameters
  static const double _stepThreshold = 12.0; // magnitude threshold
  static const int _minStepInterval = 250; // minimum ms between steps
  DateTime? _lastStepTime;
  bool _isPeak = false;

  StepCounterService(this._accelerometerDatasource);

  int get stepCount => _stepCount;
  Stream<int> get stepStream => _stepController.stream;

  void startCounting() {
    _stepCount = 0;
    _lastStepTime = null;
    _isPeak = false;

    _subscription =
        _accelerometerDatasource.getAccelerometerStream().listen((data) {
      _detectStep(data.magnitude);
    });
  }

  void _detectStep(double magnitude) {
    final now = DateTime.now();

    if (magnitude > _stepThreshold && !_isPeak) {
      _isPeak = true;

      if (_lastStepTime == null ||
          now.difference(_lastStepTime!).inMilliseconds > _minStepInterval) {
        _stepCount++;
        _lastStepTime = now;
        _stepController.add(_stepCount);
      }
    } else if (magnitude < _stepThreshold - 2) {
      _isPeak = false;
    }
  }

  void stopCounting() {
    _subscription?.cancel();
    _subscription = null;
  }

  void reset() {
    _stepCount = 0;
    _lastStepTime = null;
    _isPeak = false;
  }

  void dispose() {
    stopCounting();
    _stepController.close();
  }
}
