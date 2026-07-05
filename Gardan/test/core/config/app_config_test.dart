import 'package:flutter_test/flutter_test.dart';
import 'package:gardain/core/config/app_config.dart';

void main() {
  group('AppConfig.buildFlaskBaseUrl', () {
    test('keeps an explicit host and port without duplicating the port', () {
      expect(
        AppConfig.buildFlaskBaseUrl('127.0.0.1:5000'),
        'http://127.0.0.1:5000',
      );
    });

    test('adds the default port when the host has no port', () {
      expect(
        AppConfig.buildFlaskBaseUrl('127.0.0.1'),
        'http://127.0.0.1:5000',
      );
    });

    test('preserves a full URL with its explicit port', () {
      expect(
        AppConfig.buildFlaskBaseUrl('http://192.168.1.10:5000'),
        'http://192.168.1.10:5000',
      );
    });

    test('uses https for tunneling hosts without adding a port', () {
      expect(
        AppConfig.buildFlaskBaseUrl('myapp.ngrok-free.app'),
        'https://myapp.ngrok-free.app',
      );
    });
  });
}
