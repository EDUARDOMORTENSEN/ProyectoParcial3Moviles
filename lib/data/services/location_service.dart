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
  DateTime? _lastFixTime;
  double _currentSpeed = 0.0;
  double _maxSpeed = 0.0;

  final _positionController = StreamController<Position>.broadcast();

  LocationService(this._gpsDatasource);

  List<RoutePoint> get routePoints => List.unmodifiable(_routePoints);
  double get totalDistance => _totalDistance;
  Position? get currentPosition => _lastPosition;
  DateTime? get lastFixTime => _lastFixTime;
  double get currentSpeed => _currentSpeed;
  double get maxSpeed => _maxSpeed;

  Stream<Position> get positionStream => _positionController.stream;

  Future<void> startTracking() async {
    await _gpsDatasource.checkPermissions();
    _routePoints.clear();
    _totalDistance = 0.0;
    _lastPosition = null;
    _lastFixTime = null;
    _currentSpeed = 0.0;
    _maxSpeed = 0.0;
    await ForegroundLocationController.start();

    // Fetch initial position so the map shows the user immediately
    // instead of waiting for the first stream event (which may be
    // delayed by distanceFilter).
    try {
      final initial = await _gpsDatasource.getCurrentPosition();
      if (initial.accuracy <= 10) {
        _processPosition(initial);
      }
    } catch (_) {
      // GPS not ready yet — the stream subscription below will pick
      // up the first fix when it arrives.
    }

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

    final now = DateTime.now();
    _routePoints.add(RoutePoint(
      latitud: position.latitude,
      longitud: position.longitude,
      altitud: position.altitude,
      timestamp: now,
    ));

    if (_lastPosition != null && _lastFixTime != null) {
      final distance = _gpsDatasource.calculateDistance(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      // Ignore movement smaller than the fix's accuracy radius — it's
      // noise, not real displacement. The same gate protects speed: a
      // noise fix can't poison _currentSpeed or _maxSpeed.
      if (distance >= position.accuracy) {
        _totalDistance += distance;
        final dtSec = now.difference(_lastFixTime!).inMicroseconds / 1e6;
        if (dtSec > 0) {
          // Derive speed from distance/time between consecutive fixes
          // instead of trusting position.speed, which is 0 or garbage on
          // some Android devices. m/s → km/h.
          _currentSpeed = (distance / dtSec) * 3.6;
          if (_currentSpeed > _maxSpeed) _maxSpeed = _currentSpeed;
        }
      }
    }

    _lastPosition = position;
    _lastFixTime = now;
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
  }
}
