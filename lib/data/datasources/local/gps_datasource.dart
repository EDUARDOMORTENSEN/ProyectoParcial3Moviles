import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/errors/exceptions.dart';

class GpsDatasource {
  StreamSubscription<Position>? _positionSubscription;

  /// Check and request location + notification permissions
  Future<bool> checkPermissions() async {
    // Notifications: required by the foreground service notification on
    // Android 13+. Non-Android platforms ignore this.
    await Permission.notification.request();

    // Activity recognition: required by the hardware step counter
    // (pedometer) on Android 10+. Without it the pedometer stream throws.
    await Permission.activityRecognition.request();

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException('Los servicios de ubicación están desactivados');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException('Permiso de ubicación denegado');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
        'Los permisos de ubicación están permanentemente denegados',
      );
    }

    return true;
  }

  /// Get current position
  Future<Position> getCurrentPosition() async {
    await checkPermissions();
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Start tracking position with a stream
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // minimum 5 meters before update
      ),
    );
  }

  /// Calculate distance between two points in meters
  double calculateDistance(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) {
    return Geolocator.distanceBetween(startLat, startLon, endLat, endLon);
  }

  /// Stop tracking
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }
}
