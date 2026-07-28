import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mortenzen_martes/data/services/location_service.dart';
import 'package:mortenzen_martes/data/services/motion_sensor_service.dart';
import 'package:mortenzen_martes/data/services/step_counter_service.dart';
import 'package:mortenzen_martes/data/datasources/remote/rest_api_datasource.dart';
import 'package:mortenzen_martes/domain/repositories/ranking_repository.dart';
import 'package:mortenzen_martes/domain/repositories/route_repository.dart';
import 'package:mortenzen_martes/domain/usecases/training/training_usecases.dart';
import 'package:mortenzen_martes/presentation/viewmodels/training_viewmodel.dart';

// Mock classes
class MockSaveTrainingUseCase extends Mock implements SaveTrainingUseCase {}
class MockGetTrainingHistoryUseCase extends Mock
    implements GetTrainingHistoryUseCase {}
class MockRouteRepository extends Mock implements RouteRepository {}
class MockRankingRepository extends Mock implements RankingRepository {}
class MockLocationService extends Mock implements LocationService {}
class MockStepCounterService extends Mock implements StepCounterService {}
class MockMotionSensorService extends Mock implements MotionSensorService {}
class MockRestApiDatasource extends Mock implements RestApiDatasource {}

void main() {
  group('TrainingViewModel', () {
    late TrainingViewModel viewModel;
    late MockSaveTrainingUseCase mockSaveTraining;
    late MockGetTrainingHistoryUseCase mockGetHistory;
    late MockRouteRepository mockRouteRepo;
    late MockRankingRepository mockRankingRepo;
    late MockLocationService mockLocation;
    late MockStepCounterService mockStepCounter;
    late MockMotionSensorService mockMotionSensor;
    late MockRestApiDatasource mockRestApi;

    setUp(() {
      mockSaveTraining = MockSaveTrainingUseCase();
      mockGetHistory = MockGetTrainingHistoryUseCase();
      mockRouteRepo = MockRouteRepository();
      mockRankingRepo = MockRankingRepository();
      mockLocation = MockLocationService();
      mockStepCounter = MockStepCounterService();
      mockMotionSensor = MockMotionSensorService();
      mockRestApi = MockRestApiDatasource();

      // Default mock behavior
      when(() => mockLocation.totalDistance).thenReturn(0.0);
      when(() => mockLocation.currentSpeed).thenReturn(0.0);
      when(() => mockLocation.maxSpeed).thenReturn(0.0);
      when(() => mockLocation.routePoints).thenReturn([]);
      when(() => mockLocation.positionStream).thenAnswer((_) => const Stream.empty());
      when(() => mockLocation.currentPosition).thenReturn(null);
      when(() => mockLocation.lastFixTime).thenReturn(null);

      when(() => mockStepCounter.stepCount).thenReturn(0);
      when(() => mockStepCounter.usingHardware).thenReturn(true);
      when(() => mockStepCounter.stepStream).thenAnswer((_) => const Stream.empty());

      when(() => mockMotionSensor.accelerationMagnitude).thenReturn(9.8);
      when(() => mockMotionSensor.gyroscopeMagnitude).thenReturn(0.0);
      when(() => mockMotionSensor.activityIntensity).thenReturn('Baja');
      when(() => mockMotionSensor.turnCount).thenReturn(0);
      when(() => mockMotionSensor.isMovingByAccel).thenReturn(false);
      when(() => mockMotionSensor.orientationChangeRate).thenReturn(0.0);
      when(() => mockMotionSensor.estimatedSteps).thenReturn(0);
      when(() => mockMotionSensor.averageAcceleration).thenReturn(9.8);
      when(() => mockMotionSensor.stream).thenAnswer((_) => const Stream.empty());

      viewModel = TrainingViewModel(
        saveTrainingUseCase: mockSaveTraining,
        getTrainingHistoryUseCase: mockGetHistory,
        routeRepository: mockRouteRepo,
        rankingRepository: mockRankingRepo,
        locationService: mockLocation,
        stepCounterService: mockStepCounter,
        motionSensorService: mockMotionSensor,
        restApiDatasource: mockRestApi,
      );
    });

    tearDown(() {
      viewModel.dispose();
    });

    group('Initial state', () {
      test('state is idle', () {
        // Arrange
        // Act
        // Assert
        expect(viewModel.state, TrainingState.idle);
      });

      test('trainingType is "correr" by default', () {
        // Arrange
        // Act
        // Assert
        expect(viewModel.trainingType, 'correr');
      });

      test('elapsedSeconds is 0', () {
        // Arrange
        // Act
        // Assert
        expect(viewModel.elapsedSeconds, 0);
      });

      test('steps is 0', () {
        // Arrange
        // Act
        // Assert
        expect(viewModel.steps, 0);
      });

      test('distanceKm is 0', () {
        // Arrange
        // Act
        // Assert
        expect(viewModel.distanceKm, 0.0);
      });

      test('accelMagnitude returns motion sensor value', () {
        // Arrange
        when(() => mockMotionSensor.accelerationMagnitude).thenReturn(10.5);

        // Act
        // Assert
        expect(viewModel.accelMagnitude, 10.5);
      });

      test('gyroMagnitude returns motion sensor value', () {
        // Arrange
        when(() => mockMotionSensor.gyroscopeMagnitude).thenReturn(0.7);

        // Act
        // Assert
        expect(viewModel.gyroMagnitude, 0.7);
      });

      test('activityIntensity returns motion sensor value', () {
        // Arrange
        when(() => mockMotionSensor.activityIntensity).thenReturn('Alta');

        // Act
        // Assert
        expect(viewModel.activityIntensity, 'Alta');
      });

      test('turnCount returns motion sensor value', () {
        // Arrange
        when(() => mockMotionSensor.turnCount).thenReturn(5);

        // Act
        // Assert
        expect(viewModel.turnCount, 5);
      });

      test('usingHardwareSteps returns step counter value', () {
        // Arrange
        when(() => mockStepCounter.usingHardware).thenReturn(false);

        // Act
        // Assert
        expect(viewModel.usingHardwareSteps, false);
      });
    });

    group('setTrainingType', () {
      test('updates training type', () {
        // Arrange
        // Act
        viewModel.setTrainingType('caminar');

        // Assert
        expect(viewModel.trainingType, 'caminar');
      });
    });

    group('steps getter with fallback', () {
      test('returns stepCounter stepCount when using hardware', () {
        // Arrange
        when(() => mockStepCounter.usingHardware).thenReturn(true);
        when(() => mockStepCounter.stepCount).thenReturn(100);

        // Act
        // Assert
        expect(viewModel.steps, 100);
      });

      test('returns estimatedSteps when hardware fails', () {
        // Arrange
        when(() => mockStepCounter.usingHardware).thenReturn(false);
        when(() => mockMotionSensor.estimatedSteps).thenReturn(85);

        // Act
        // Assert
        expect(viewModel.steps, 85);
      });
    });

    group('startTraining', () {
      test('starts location, step counter, and motion sensor', () async {
        // Arrange
        when(() => mockLocation.startTracking()).thenAnswer((_) async {});
        when(() => mockLocation.positionStream).thenAnswer(
          (_) => const Stream.empty(),
        );
        when(() => mockStepCounter.stepStream).thenAnswer((_) => const Stream.empty());
        when(() => mockMotionSensor.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await viewModel.startTraining(weightKg: 70.0);

        // Assert
        verify(() => mockLocation.startTracking()).called(1);
        verify(() => mockStepCounter.startCounting()).called(1);
        verify(() => mockMotionSensor.start()).called(1);
      });

      test('sets state to active', () async {
        // Arrange
        when(() => mockLocation.startTracking()).thenAnswer((_) async {});
        when(() => mockLocation.positionStream).thenAnswer(
          (_) => const Stream.empty(),
        );
        when(() => mockStepCounter.stepStream).thenAnswer((_) => const Stream.empty());
        when(() => mockMotionSensor.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await viewModel.startTraining(weightKg: 70.0);

        // Assert
        expect(viewModel.state, TrainingState.active);
      });
    });

    group('pauseTraining', () {
      test('pauses location, step counter, and motion sensor', () async {
        // Arrange
        when(() => mockLocation.startTracking()).thenAnswer((_) async {});
        when(() => mockLocation.positionStream).thenAnswer(
          (_) => const Stream.empty(),
        );
        when(() => mockStepCounter.stepStream).thenAnswer((_) => const Stream.empty());
        when(() => mockMotionSensor.stream).thenAnswer((_) => const Stream.empty());

        await viewModel.startTraining(weightKg: 70.0);

        // Act
        viewModel.pauseTraining();

        // Assert
        verify(() => mockLocation.pause()).called(1);
        verify(() => mockStepCounter.pause()).called(1);
        verify(() => mockMotionSensor.pause()).called(1);
        expect(viewModel.state, TrainingState.paused);
      });
    });

    group('resumeTraining', () {
      test('resumes location, step counter, and motion sensor', () async {
        // Arrange
        when(() => mockLocation.startTracking()).thenAnswer((_) async {});
        when(() => mockLocation.positionStream).thenAnswer(
          (_) => const Stream.empty(),
        );
        when(() => mockStepCounter.stepStream).thenAnswer((_) => const Stream.empty());
        when(() => mockMotionSensor.stream).thenAnswer((_) => const Stream.empty());

        await viewModel.startTraining(weightKg: 70.0);
        viewModel.pauseTraining();

        // Act
        viewModel.resumeTraining();

        // Assert
        verify(() => mockLocation.resume()).called(1);
        verify(() => mockStepCounter.resume()).called(1);
        verify(() => mockMotionSensor.resume()).called(1);
        expect(viewModel.state, TrainingState.active);
      });
    });

    group('stopTraining', () {
      test('stops all services and creates TrainingEntity with sensor data', () async {
        // Arrange
        when(() => mockLocation.startTracking()).thenAnswer((_) async {});
        when(() => mockLocation.positionStream).thenAnswer(
          (_) => const Stream.empty(),
        );
        when(() => mockStepCounter.stepStream).thenAnswer((_) => const Stream.empty());
        when(() => mockMotionSensor.stream).thenAnswer((_) => const Stream.empty());
        when(() => mockMotionSensor.turnCount).thenReturn(7);
        when(() => mockMotionSensor.averageAcceleration).thenReturn(10.5);

        await viewModel.startTraining(weightKg: 70.0);

        // Act
        final result = await viewModel.stopTraining('user-123');

        // Assert
        verify(() => mockLocation.stopTracking()).called(1);
        verify(() => mockStepCounter.stopCounting()).called(1);
        verify(() => mockMotionSensor.stop()).called(1);
        expect(result, isNotNull);
        expect(result!.usuarioId, 'user-123');
        expect(result.girosDetectados, 7);
        expect(result.intensidadPromedio, isNotNull);
      });
    });

    group('discardTraining', () {
      test('resets motion sensor and sets state to idle', () async {
        // Arrange
        when(() => mockLocation.startTracking()).thenAnswer((_) async {});
        when(() => mockLocation.positionStream).thenAnswer(
          (_) => const Stream.empty(),
        );
        when(() => mockStepCounter.stepStream).thenAnswer((_) => const Stream.empty());
        when(() => mockMotionSensor.stream).thenAnswer((_) => const Stream.empty());

        await viewModel.startTraining(weightKg: 70.0);

        // Act
        viewModel.discardTraining();

        // Assert
        verify(() => mockMotionSensor.reset()).called(1);
        verify(() => mockLocation.stopTracking()).called(1);
        verify(() => mockStepCounter.stopCounting()).called(1);
        expect(viewModel.state, TrainingState.idle);
      });
    });

    group('formattedTime', () {
      test('returns "00:00" when elapsedSeconds is 0', () {
        // Arrange
        // Act
        // Assert
        expect(viewModel.formattedTime, '00:00');
      });
    });
  });
}
