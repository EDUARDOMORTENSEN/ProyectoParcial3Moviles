import 'package:flutter/services.dart';

/// Starts/stops the native Android foreground service that keeps the
/// app process in foreground state during a workout, so the OS doesn't
/// throttle or kill the location stream when the screen locks or the
/// app is backgrounded.
///
/// No-op on non-Android platforms: the MethodChannel is only registered
/// in MainActivity.kt, and missing methods throw PlatformException which
/// we swallow.
class ForegroundLocationController {
  static const _channel = MethodChannel('app.mortenzen/location_fg');

  static Future<void> start() async {
    try {
      await _channel.invokeMethod('start');
    } on PlatformException {
      // Not Android, or service unavailable — silent no-op.
    } on MissingPluginException {
      // Channel not registered on this platform — silent no-op.
    }
  }

  static Future<void> stop() async {
    try {
      await _channel.invokeMethod('stop');
    } on PlatformException {
      // No-op.
    } on MissingPluginException {
      // No-op.
    }
  }
}