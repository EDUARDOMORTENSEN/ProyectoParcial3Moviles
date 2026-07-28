import 'dart:async';
import 'package:pedometer/pedometer.dart';

/// Step counter backed by the platform hardware step counter
/// (Android TYPE_STEP_COUNTER / iOS CMPedometer). The platform reports
/// cumulative steps since device boot; we capture a baseline at start and
/// subtract it so the workout reports steps taken during the workout only.
///
/// Hardware-based counting runs on the coprocessor and is unaffected by
/// screen state, Dart isolate throttling, or app lifecycle, unlike the
/// previous software peak-detection on the accelerometer stream.
class StepCounterService {
  Stream<StepCount>? _stepCountStream;
  StreamSubscription<StepCount>? _subscription;
  int _stepCount = 0;
  int _baseline = 0;
  bool _hasError = false;
  final _stepController = StreamController<int>.broadcast();

  int get stepCount => _stepCount;
  Stream<int> get stepStream => _stepController.stream;
  bool get usingHardware => !_hasError;
  bool get hasError => _hasError;

  void startCounting() {
    _stepCount = 0;
    _baseline = 0;
    _hasError = false;
    _startListening();
  }

  void _startListening() {
    _stepCountStream = Pedometer.stepCountStream;
    _subscription = _stepCountStream?.listen(
      (event) {
        if (_baseline == 0) {
          _baseline = event.steps;
        }
        _stepCount = event.steps - _baseline;
        _stepController.add(_stepCount);
      },
      onError: (e) {
        _hasError = true;
      },
    );
  }

  /// Feed estimated steps from accelerometer fallback.
  void setFallbackSteps(int steps) {
    _stepCount = steps;
    _stepController.add(_stepCount);
  }

  void pause() {
    _subscription?.cancel();
    _subscription = null;
  }

  void resume() {
    if (_subscription != null) return;
    _startListening();
  }

  void stopCounting() {
    _subscription?.cancel();
    _subscription = null;
  }

  void reset() {
    _stepCount = 0;
    _baseline = 0;
    _hasError = false;
  }

  void dispose() {
    stopCounting();
    _stepController.close();
  }
}