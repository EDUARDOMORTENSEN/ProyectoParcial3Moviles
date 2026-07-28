import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mortenzen_martes/data/datasources/local/sensor_datasource.dart';
import 'package:mortenzen_martes/data/services/motion_sensor_service.dart';

// Mock class for AccelerometerDatasource
class MockAccelerometerDatasource extends Mock
    implements AccelerometerDatasource {}

// Mock class for GyroscopeDatasource
class MockGyroscopeDatasource extends Mock implements GyroscopeDatasource {}

void main() {
  group('MotionSensorService', () {
    late MockAccelerometerDatasource mockAccel;
    late MockGyroscopeDatasource mockGyro;
    late MotionSensorService service;

    setUp(() {
      mockAccel = MockAccelerometerDatasource();
      mockGyro = MockGyroscopeDatasource();
      service = MotionSensorService(mockAccel, mockGyro);
    });

    tearDown(() {
      service.dispose();
    });

    group('Initial state', () {
      test('accelerationMagnitude is 0 when not started', () {
        // Arrange
        // Act
        // Assert
        expect(service.accelerationMagnitude, 0.0);
      });

      test('gyroscopeMagnitude is 0 when not started', () {
        // Arrange
        // Act
        // Assert
        expect(service.gyroscopeMagnitude, 0.0);
      });

      test('isMovingByAccel is false when not started', () {
        // Arrange
        // Act
        // Assert
        expect(service.isMovingByAccel, false);
      });

      test('turnCount is 0 when not started', () {
        // Arrange
        // Act
        // Assert
        expect(service.turnCount, 0);
      });

      test('estimatedSteps is 0 when not started', () {
        // Arrange
        // Act
        // Assert
        expect(service.estimatedSteps, 0);
      });
    });

    group('activityIntensity', () {
      test('returns "Baja" when magnitude is near gravity (stationary)', () async {
        // Arrange - set up accelerometer stream with gravity-level data
        final controller = StreamController<SensorData>.broadcast();
        when(() => mockAccel.getAccelerometerStream())
            .thenAnswer((_) => controller.stream);
        when(() => mockGyro.getGyroscopeStream())
            .thenAnswer((_) => Stream.empty());

        service.start();

        // Act - emit data near gravity (9.8 m/s²)
        controller.add(SensorData(x: 0, y: 0, z: 9.8, magnitude: 9.8));
        await Future.delayed(Duration.zero);

        // Assert
        expect(service.activityIntensity, 'Baja');
      });

      test('returns "Media" when magnitude shows moderate movement', () async {
        // Arrange
        final controller = StreamController<SensorData>.broadcast();
        when(() => mockAccel.getAccelerometerStream())
            .thenAnswer((_) => controller.stream);
        when(() => mockGyro.getGyroscopeStream())
            .thenAnswer((_) => Stream.empty());

        service.start();

        // Act - emit data with moderate deviation (2.0 above gravity)
        controller.add(SensorData(x: 0, y: 0, z: 11.8, magnitude: 11.8));
        await Future.delayed(Duration.zero);

        // Assert
        expect(service.activityIntensity, 'Media');
      });

      test('returns "Alta" when magnitude shows high movement', () async {
        // Arrange
        final controller = StreamController<SensorData>.broadcast();
        when(() => mockAccel.getAccelerometerStream())
            .thenAnswer((_) => controller.stream);
        when(() => mockGyro.getGyroscopeStream())
            .thenAnswer((_) => Stream.empty());

        service.start();

        // Act - emit data with high deviation (3.0 above gravity)
        controller.add(SensorData(x: 0, y: 0, z: 12.8, magnitude: 12.8));
        await Future.delayed(Duration.zero);

        // Assert
        expect(service.activityIntensity, 'Alta');
      });
    });

    group('isMovingByAccel', () {
      test('is true when deviation exceeds stationary threshold', () async {
        // Arrange
        final controller = StreamController<SensorData>.broadcast();
        when(() => mockAccel.getAccelerometerStream())
            .thenAnswer((_) => controller.stream);
        when(() => mockGyro.getGyroscopeStream())
            .thenAnswer((_) => Stream.empty());

        service.start();

        // Act - emit data with deviation > 1.5 (threshold)
        controller.add(SensorData(x: 0, y: 0, z: 12.0, magnitude: 12.0));
        await Future.delayed(Duration.zero);

        // Assert
        expect(service.isMovingByAccel, true);
      });

      test('is false when magnitude is near gravity', () async {
        // Arrange
        final controller = StreamController<SensorData>.broadcast();
        when(() => mockAccel.getAccelerometerStream())
            .thenAnswer((_) => controller.stream);
        when(() => mockGyro.getGyroscopeStream())
            .thenAnswer((_) => Stream.empty());

        service.start();

        // Act - emit data near gravity
        controller.add(SensorData(x: 0, y: 0, z: 9.8, magnitude: 9.8));
        await Future.delayed(Duration.zero);

        // Assert
        expect(service.isMovingByAccel, false);
      });
    });

    group('turnCount', () {
      test('increments when gyroscope magnitude exceeds threshold', () async {
        // Arrange
        final accelController = StreamController<SensorData>.broadcast();
        final gyroController = StreamController<SensorData>.broadcast();
        when(() => mockAccel.getAccelerometerStream())
            .thenAnswer((_) => accelController.stream);
        when(() => mockGyro.getGyroscopeStream())
            .thenAnswer((_) => gyroController.stream);

        service.start();

        // Act - emit gyroscope data above turn threshold (0.5 rad/s)
        gyroController.add(SensorData(x: 0.3, y: 0.3, z: 0.3, magnitude: 0.52));
        await Future.delayed(Duration.zero);

        // Assert
        expect(service.turnCount, 1);
      });

      test('does not increment when gyroscope magnitude is below threshold', () async {
        // Arrange
        final accelController = StreamController<SensorData>.broadcast();
        final gyroController = StreamController<SensorData>.broadcast();
        when(() => mockAccel.getAccelerometerStream())
            .thenAnswer((_) => accelController.stream);
        when(() => mockGyro.getGyroscopeStream())
            .thenAnswer((_) => gyroController.stream);

        service.start();

        // Act - emit gyroscope data below threshold
        gyroController.add(SensorData(x: 0.1, y: 0.1, z: 0.1, magnitude: 0.17));
        await Future.delayed(Duration.zero);

        // Assert
        expect(service.turnCount, 0);
      });

      test('accumulates multiple turns', () async {
        // Arrange
        final accelController = StreamController<SensorData>.broadcast();
        final gyroController = StreamController<SensorData>.broadcast();
        when(() => mockAccel.getAccelerometerStream())
            .thenAnswer((_) => accelController.stream);
        when(() => mockGyro.getGyroscopeStream())
            .thenAnswer((_) => gyroController.stream);

        service.start();

        // Act - emit multiple above-threshold readings
        gyroController.add(SensorData(x: 0.3, y: 0.3, z: 0.3, magnitude: 0.52));
        await Future.delayed(Duration.zero);
        gyroController.add(SensorData(x: 0.4, y: 0.4, z: 0.4, magnitude: 0.69));
        await Future.delayed(Duration.zero);
        gyroController.add(SensorData(x: 0.5, y: 0.5, z: 0.5, magnitude: 0.87));
        await Future.delayed(Duration.zero);

        // Assert
        expect(service.turnCount, 3);
      });
    });

    group('estimatedSteps (fallback)', () {
      test('counts step when acceleration crosses peak threshold', () async {
        // Arrange
        final accelController = StreamController<SensorData>.broadcast();
        final gyroController = StreamController<SensorData>.broadcast();
        when(() => mockAccel.getAccelerometerStream())
            .thenAnswer((_) => accelController.stream);
        when(() => mockGyro.getGyroscopeStream())
            .thenAnswer((_) => gyroController.stream);

        service.start();

        // Act - emit data above step peak threshold (11.0 m/s²)
        accelController.add(SensorData(x: 0, y: 0, z: 12.0, magnitude: 12.0));
        await Future.delayed(Duration.zero);

        // Assert
        expect(service.estimatedSteps, 1);
      });

      test('does not double-count steps without release', () async {
        // Arrange
        final accelController = StreamController<SensorData>.broadcast();
        final gyroController = StreamController<SensorData>.broadcast();
        when(() => mockAccel.getAccelerometerStream())
            .thenAnswer((_) => accelController.stream);
        when(() => mockGyro.getGyroscopeStream())
            .thenAnswer((_) => gyroController.stream);

        service.start();

        // Act - emit data above threshold twice without going below release
        accelController.add(SensorData(x: 0, y: 0, z: 12.0, magnitude: 12.0));
        await Future.delayed(Duration.zero);
        accelController.add(SensorData(x: 0, y: 0, z: 13.0, magnitude: 13.0));
        await Future.delayed(Duration.zero);

        // Assert
        expect(service.estimatedSteps, 1);
      });

      test('counts new step after release below threshold', () async {
        // Arrange
        final accelController = StreamController<SensorData>.broadcast();
        final gyroController = StreamController<SensorData>.broadcast();
        when(() => mockAccel.getAccelerometerStream())
            .thenAnswer((_) => accelController.stream);
        when(() => mockGyro.getGyroscopeStream())
            .thenAnswer((_) => gyroController.stream);

        service.start();

        // Act - peak, release, peak
        accelController.add(SensorData(x: 0, y: 0, z: 12.0, magnitude: 12.0));
        await Future.delayed(Duration.zero);
        accelController.add(SensorData(x: 0, y: 0, z: 9.8, magnitude: 9.8));
        await Future.delayed(Duration.zero);
        accelController.add(SensorData(x: 0, y: 0, z: 12.5, magnitude: 12.5));
        await Future.delayed(Duration.zero);

        // Assert
        expect(service.estimatedSteps, 2);
      });
    });

    group('averageAcceleration', () {
      test('returns 0 when no samples collected', () {
        // Arrange
        // Act
        // Assert
        expect(service.averageAcceleration, 0.0);
      });

      test('returns correct average after multiple samples', () async {
        // Arrange
        final controller = StreamController<SensorData>.broadcast();
        when(() => mockAccel.getAccelerometerStream())
            .thenAnswer((_) => controller.stream);
        when(() => mockGyro.getGyroscopeStream())
            .thenAnswer((_) => Stream.empty());

        service.start();

        // Act - emit two samples
        controller.add(SensorData(x: 0, y: 0, z: 9.8, magnitude: 9.8));
        await Future.delayed(Duration.zero);
        controller.add(SensorData(x: 0, y: 0, z: 11.8, magnitude: 11.8));
        await Future.delayed(Duration.zero);

        // Assert
        expect(service.averageAcceleration, closeTo(10.8, 0.01));
      });
    });

    group('Lifecycle methods', () {
      test('pause stops receiving events', () async {
        // Arrange
        final controller = StreamController<SensorData>.broadcast();
        when(() => mockAccel.getAccelerometerStream())
            .thenAnswer((_) => controller.stream);
        when(() => mockGyro.getGyroscopeStream())
            .thenAnswer((_) => Stream.empty());

        service.start();
        controller.add(SensorData(x: 0, y: 0, z: 12.0, magnitude: 12.0));
        await Future.delayed(Duration.zero);
        expect(service.accelerationMagnitude, 12.0);

        // Act
        service.pause();
        controller.add(SensorData(x: 0, y: 0, z: 15.0, magnitude: 15.0));
        await Future.delayed(Duration.zero);

        // Assert - magnitude unchanged after pause
        expect(service.accelerationMagnitude, 12.0);
      });

      test('resume restarts receiving events', () async {
        // Arrange
        final controller = StreamController<SensorData>.broadcast();
        when(() => mockAccel.getAccelerometerStream())
            .thenAnswer((_) => controller.stream);
        when(() => mockGyro.getGyroscopeStream())
            .thenAnswer((_) => Stream.empty());

        service.start();
        service.pause();

        // Act
        service.resume();
        controller.add(SensorData(x: 0, y: 0, z: 12.0, magnitude: 12.0));
        await Future.delayed(Duration.zero);

        // Assert
        expect(service.accelerationMagnitude, 12.0);
      });

      test('stop resets magnitude to 0', () async {
        // Arrange
        final controller = StreamController<SensorData>.broadcast();
        when(() => mockAccel.getAccelerometerStream())
            .thenAnswer((_) => controller.stream);
        when(() => mockGyro.getGyroscopeStream())
            .thenAnswer((_) => Stream.empty());

        service.start();
        controller.add(SensorData(x: 0, y: 0, z: 12.0, magnitude: 12.0));
        await Future.delayed(Duration.zero);

        // Act
        service.stop();

        // Assert
        expect(service.accelerationMagnitude, 0.0);
        expect(service.isMovingByAccel, false);
      });

      test('reset clears all counters', () async {
        // Arrange
        final accelController = StreamController<SensorData>.broadcast();
        final gyroController = StreamController<SensorData>.broadcast();
        when(() => mockAccel.getAccelerometerStream())
            .thenAnswer((_) => accelController.stream);
        when(() => mockGyro.getGyroscopeStream())
            .thenAnswer((_) => gyroController.stream);

        service.start();
        accelController.add(SensorData(x: 0, y: 0, z: 12.0, magnitude: 12.0));
        await Future.delayed(Duration.zero);
        gyroController.add(SensorData(x: 0.3, y: 0.3, z: 0.3, magnitude: 0.52));
        await Future.delayed(Duration.zero);

        // Act
        service.reset();

        // Assert
        expect(service.turnCount, 0);
        expect(service.estimatedSteps, 0);
        expect(service.accelerationMagnitude, 0.0);
      });
    });
  });
}
