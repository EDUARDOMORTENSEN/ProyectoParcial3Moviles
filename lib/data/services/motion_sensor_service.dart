import 'dart:async';
import '../datasources/local/sensor_datasource.dart';

class MotionSensorData {
  final double accelerationMagnitude;
  final double gyroscopeMagnitude;
  final bool isMovingByAccel;
  final double orientationChangeRate;
  final int turnCount;
  final int estimatedSteps;
  final String activityIntensity;

  const MotionSensorData({
    required this.accelerationMagnitude,
    required this.gyroscopeMagnitude,
    required this.isMovingByAccel,
    required this.orientationChangeRate,
    required this.turnCount,
    required this.estimatedSteps,
    required this.activityIntensity,
  });
}

/// Unified motion sensor service that combines accelerometer and gyroscope
/// data to provide real-time activity metrics during a training session.
///
/// This service complements [StepCounterService] (hardware pedometer) by
/// adding movement intensity and orientation-change detection from the
/// accelerometer and gyroscope hardware sensors.
class MotionSensorService {
  final AccelerometerDatasource _accelerometerDatasource;
  final GyroscopeDatasource _gyroscopeDatasource;

  StreamSubscription<SensorData>? _accelSub;
  StreamSubscription<SensorData>? _gyroSub;

  double _accelMagnitude = 0.0;
  double _gyroMagnitude = 0.0;
  bool _isMovingByAccel = false;
  double _orientationChangeRate = 0.0;
  int _turnCount = 0;

  // Running averages for persistence
  double _accelSum = 0.0;
  int _accelSamples = 0;
  double _gyroSum = 0.0;
  int _gyroSamples = 0;

  // Fallback step counting (accelerometer peak detection)
  int _estimatedSteps = 0;
  bool _aboveStepThreshold = false;

  // Thresholds (tuned for typical smartphone sensors)
  // Gravity is ~9.8 m/s²; deviation from that indicates motion.
  static const double _stationaryDeviation = 1.5; // m/s² above/below gravity
  static const double _movingDeviation = 2.5; // m/s² above gravity = moving
  static const double _turnThreshold = 0.5; // rad/s for sudden direction change
  static const double _stepPeakThreshold = 11.0; // m/s² — above this counts as step peak
  static const double _stepReleaseThreshold = 10.0; // m/s² — below this resets peak detector

  final _controller = StreamController<MotionSensorData>.broadcast();

  MotionSensorService(
    this._accelerometerDatasource,
    this._gyroscopeDatasource,
  );

  // Getters
  double get accelerationMagnitude => _accelMagnitude;
  double get gyroscopeMagnitude => _gyroMagnitude;
  bool get isMovingByAccel => _isMovingByAccel;
  double get orientationChangeRate => _orientationChangeRate;
  int get turnCount => _turnCount;
  int get estimatedSteps => _estimatedSteps;
  Stream<MotionSensorData> get stream => _controller.stream;

  /// Average acceleration magnitude over the session (for persistence).
  double get averageAcceleration =>
      _accelSamples > 0 ? _accelSum / _accelSamples : 0.0;

  /// Average gyroscope magnitude over the session (for persistence).
  double get averageGyroscope =>
      _gyroSamples > 0 ? _gyroSum / _gyroSamples : 0.0;

  /// Intensity classification based on accelerometer deviation from gravity.
  String get activityIntensity {
    final deviation = (_accelMagnitude - 9.8).abs();
    if (deviation < _stationaryDeviation) return 'Baja';
    if (deviation < _movingDeviation) return 'Media';
    return 'Alta';
  }

  void start() {
    _accelSub = _accelerometerDatasource.getAccelerometerStream().listen(
      (data) {
        _accelMagnitude = data.magnitude;
        _accelSum += data.magnitude;
        _accelSamples++;

        final deviation = (_accelMagnitude - 9.8).abs();
        _isMovingByAccel = deviation > _stationaryDeviation;

        // Accelerometer-based step detection (peak crossing)
        if (_accelMagnitude > _stepPeakThreshold && !_aboveStepThreshold) {
          _aboveStepThreshold = true;
          _estimatedSteps++;
        } else if (_accelMagnitude < _stepReleaseThreshold) {
          _aboveStepThreshold = false;
        }

        _controller.add(_buildData());
      },
    );

    _gyroSub = _gyroscopeDatasource.getGyroscopeStream().listen(
      (data) {
        _gyroMagnitude = data.magnitude;
        _gyroSum += data.magnitude;
        _gyroSamples++;

        // Count sudden direction changes (rotation rate spikes)
        if (data.magnitude > _turnThreshold) {
          _turnCount++;
        }

        _orientationChangeRate = data.magnitude;

        _controller.add(_buildData());
      },
    );
  }

  void pause() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _accelSub = null;
    _gyroSub = null;
  }

  void resume() {
    if (_accelSub != null && _gyroSub != null) return;
    start();
  }

  void stop() {
    pause();
    _accelMagnitude = 0.0;
    _gyroMagnitude = 0.0;
    _isMovingByAccel = false;
    _orientationChangeRate = 0.0;
  }

  void reset() {
    _accelMagnitude = 0.0;
    _gyroMagnitude = 0.0;
    _isMovingByAccel = false;
    _orientationChangeRate = 0.0;
    _turnCount = 0;
    _estimatedSteps = 0;
    _aboveStepThreshold = false;
    _accelSum = 0.0;
    _accelSamples = 0;
    _gyroSum = 0.0;
    _gyroSamples = 0;
  }

  void dispose() {
    stop();
    _controller.close();
  }

  MotionSensorData _buildData() {
    return MotionSensorData(
      accelerationMagnitude: _accelMagnitude,
      gyroscopeMagnitude: _gyroMagnitude,
      isMovingByAccel: _isMovingByAccel,
      orientationChangeRate: _orientationChangeRate,
      turnCount: _turnCount,
      estimatedSteps: _estimatedSteps,
      activityIntensity: activityIntensity,
    );
  }
}
