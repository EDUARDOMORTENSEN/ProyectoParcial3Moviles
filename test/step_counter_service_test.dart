import 'package:flutter_test/flutter_test.dart';
import 'package:mortenzen_martes/data/services/step_counter_service.dart';

void main() {
  group('StepCounterService', () {
    late StepCounterService service;

    setUp(() {
      service = StepCounterService();
    });

    tearDown(() {
      service.dispose();
    });

    group('Initial state', () {
      test('stepCount is 0 when not started', () {
        // Arrange
        // Act
        // Assert
        expect(service.stepCount, 0);
      });

      test('usingHardware is true initially', () {
        // Arrange
        // Act
        // Assert
        expect(service.usingHardware, true);
      });

      test('hasError is false initially', () {
        // Arrange
        // Act
        // Assert
        expect(service.hasError, false);
      });
    });

    group('setFallbackSteps', () {
      test('updates stepCount without starting', () {
        // Arrange
        // Act
        service.setFallbackSteps(50);

        // Assert
        expect(service.stepCount, 50);
      });

      test('updates stepCount from a different value', () {
        // Arrange
        service.setFallbackSteps(10);

        // Act
        service.setFallbackSteps(100);

        // Assert
        expect(service.stepCount, 100);
      });
    });

    group('reset', () {
      test('resets stepCount to 0', () {
        // Arrange
        service.setFallbackSteps(100);

        // Act
        service.reset();

        // Assert
        expect(service.stepCount, 0);
      });

      test('resets hasError to false', () {
        // Arrange
        service.setFallbackSteps(100);

        // Act
        service.reset();

        // Assert
        expect(service.hasError, false);
      });

      test('resets usingHardware to true', () {
        // Arrange
        service.setFallbackSteps(100);

        // Act
        service.reset();

        // Assert
        expect(service.usingHardware, true);
      });
    });

    group('stepStream', () {
      test('emits updated value when setFallbackSteps is called', () async {
        // Arrange
        int? receivedValue;
        final sub = service.stepStream.listen((value) {
          receivedValue = value;
        });

        // Act
        service.setFallbackSteps(75);
        await Future.delayed(Duration.zero);

        // Assert
        expect(receivedValue, 75);
        sub.cancel();
      });

      test('emits multiple values for multiple updates', () async {
        // Arrange
        final values = <int>[];
        final sub = service.stepStream.listen((value) {
          values.add(value);
        });

        // Act
        service.setFallbackSteps(10);
        await Future.delayed(Duration.zero);
        service.setFallbackSteps(20);
        await Future.delayed(Duration.zero);
        service.setFallbackSteps(30);
        await Future.delayed(Duration.zero);

        // Assert
        expect(values, [10, 20, 30]);
        sub.cancel();
      });
    });

    group('Lifecycle methods (without hardware)', () {
      test('pause does not throw when not started', () {
        // Arrange
        // Act
        service.pause();

        // Assert - no exception thrown
        expect(service.stepCount, 0);
      });

      test('stopCounting does not throw when not started', () {
        // Arrange
        // Act
        service.stopCounting();

        // Assert - no exception thrown
        expect(service.stepCount, 0);
      });

      test('dispose does not throw when not started', () {
        // Arrange
        // Act
        service.dispose();

        // Assert - no exception thrown
        expect(service.stepCount, 0);
      });
    });

    group('usingHardware flag behavior', () {
      test('stays true after setFallbackSteps', () {
        // Arrange
        // Act
        service.setFallbackSteps(100);

        // Assert
        expect(service.usingHardware, true);
      });

      test('stays true after reset', () {
        // Arrange
        service.setFallbackSteps(100);

        // Act
        service.reset();

        // Assert
        expect(service.usingHardware, true);
      });
    });
  });
}
