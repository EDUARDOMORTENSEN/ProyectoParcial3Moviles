import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class SensorData {
  final double x;
  final double y;
  final double z;
  final double magnitude;

  const SensorData({
    required this.x,
    required this.y,
    required this.z,
    required this.magnitude,
  });
}

class AccelerometerDatasource {
  StreamSubscription<AccelerometerEvent>? _subscription;

  /// Get accelerometer event stream
  Stream<SensorData> getAccelerometerStream() {
    return accelerometerEventStream().map((event) {
      final magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );
      return SensorData(
        x: event.x,
        y: event.y,
        z: event.z,
        magnitude: magnitude,
      );
    });
  }

  /// Get user accelerometer (without gravity) stream
  Stream<SensorData> getUserAccelerometerStream() {
    return userAccelerometerEventStream().map((event) {
      final magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );
      return SensorData(
        x: event.x,
        y: event.y,
        z: event.z,
        magnitude: magnitude,
      );
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}

class GyroscopeDatasource {
  /// Get gyroscope event stream
  Stream<SensorData> getGyroscopeStream() {
    return gyroscopeEventStream().map((event) {
      final magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );
      return SensorData(
        x: event.x,
        y: event.y,
        z: event.z,
        magnitude: magnitude,
      );
    });
  }
}
