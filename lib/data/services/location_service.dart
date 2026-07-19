import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../datasources/local/gps_datasource.dart';
import 'foreground_location_controller.dart';
import '../../domain/entities/route_entity.dart';

class LocationService {
  final GpsDatasource _gpsDatasource;

  StreamSubscription<Position>? _positionSubscription;
  final List<RoutePoint> _routePoints = [];
  double _totalDistance = 0.0;
  Position? _lastPosition;
  double _currentSpeed = 0.0;
  double _maxSpeed = 0.0;

  final _positionController = StreamController<Position>.broadcast();
  final _distanceController = StreamController<double>.broadcast();
  final _speedController = StreamController<double>.broadcast();

  LocationService(this._gpsDatasource);

  List<RoutePoint> get routePoints => List.unmodifiable(_routePoints);
  double get totalDistance => _totalDistance;
  double get currentSpeed => _currentSpeed;
  double get maxSpeed => _maxSpeed;

  Stream<Position> get positionStream => _positionController.stream;
  Stream<double> get distanceStream => _distanceController.stream;
  Stream<double> get speedStream => _speedController.stream;

  Future<void> startTracking() async {
    await _gpsDatasource.checkPermissions();
    _routePoints.clear();
    _totalDistance = 0.0;
    _lastPosition = null;
    _currentSpeed = 0.0;
    _maxSpeed = 0.0;
    await ForegroundLocationController.start();
    _startListening();
  }

  void _startListening() {
    _positionSubscription = _gpsDatasource.getPositionStream().listen(
      (position) {
        _processPosition(position);
      },
    );
  }

  void pause() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void resume() {
    if (_positionSubscription != null) return;
    _startListening();
  }

  void _processPosition(Position position) {
    // Skip inaccurate fixes (GPS jitter when stationary would otherwise
    // accumulate phantom distance). 10m is a permissive gate; tighten if
    // indoor tracking still drifts.
    if (position.accuracy > 10) return;

    final routePoint = RoutePoint(
      latitud: position.latitude,
      longitud: position.longitude,
      altitud: position.altitude,
      timestamp: DateTime.now(),
    );
    _routePoints.add(routePoint);

    if (_lastPosition != null) {
      final distance = _gpsDatasource.calculateDistance(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      // Ignore movement smaller than the fix's accuracy radius — it's noise,
      // not real displacement.
      if (distance >= position.accuracy) {
        _totalDistance += distance;
        _distanceController.add(_totalDistance);
      }
    }

    // Speed in km/h
    _currentSpeed = position.speed * 3.6; // m/s to km/h
    if (_currentSpeed > _maxSpeed) {
      _maxSpeed = _currentSpeed;
    }
    _speedController.add(_currentSpeed);

    _lastPosition = position;
    _positionController.add(position);
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    ForegroundLocationController.stop();
  }

  void dispose() {
    stopTracking();
    _positionController.close();
    _distanceController.close();
    _speedController.close();
  }
}
