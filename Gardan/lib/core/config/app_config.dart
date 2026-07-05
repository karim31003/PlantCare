
import '../services/api_config_service.dart';

class AppConfig {
  AppConfig._();

  /// Override with `--dart-define=FLASK_HOST=...` when needed.
  static const String _flaskHostOverride =
      String.fromEnvironment('FLASK_HOST');

  static const int flaskPort = 7860;

  /// Your Hugging Face Space URL — replace with your actual space name.
  /// Format: https://<username>-<space-name>.hf.space
  static const String _huggingFaceSpaceUrl =
      'https://karim31003-plant.hf.space';

  static String get flaskHost {
    if (_flaskHostOverride.isNotEmpty) {
      return ApiConfigService.normalizeHost(_flaskHostOverride);
    }

    final savedHost = ApiConfigService.apiHost;
    final normalizedSavedHost =
        savedHost == null ? '' : ApiConfigService.normalizeHost(savedHost);
    if (normalizedSavedHost.isNotEmpty) {
      return normalizedSavedHost;
    }

    // Default to the Hugging Face Space for production builds.
    return _huggingFaceSpaceUrl;
  }

  static String get flaskBaseUrl {
    return buildFlaskBaseUrl(flaskHost);
  }

  static String buildFlaskBaseUrl(String host) {
    final trimmed = host.trim();
    if (trimmed.isEmpty) {
      return 'http://localhost:$flaskPort';
    }

    final lowerHost = trimmed.toLowerCase();
    final isTunnelHost = lowerHost.contains('ngrok') ||
        lowerHost.contains('localtunnel') ||
        lowerHost.contains('trycloudflare') ||
        lowerHost.contains('hf.space');

    final hasExplicitScheme = lowerHost.startsWith('http://') ||
        lowerHost.startsWith('https://');
    if (hasExplicitScheme) {
      final parsed = Uri.parse(trimmed);
      if (parsed.host.isEmpty) {
        return trimmed;
      }

      if (parsed.hasPort) {
        return Uri(
          scheme: parsed.scheme,
          host: parsed.host,
          port: parsed.port,
        ).toString();
      }

      if (isTunnelHost) {
        return Uri(
          scheme: parsed.scheme,
          host: parsed.host,
        ).toString();
      }

      return Uri(
        scheme: parsed.scheme,
        host: parsed.host,
        port: flaskPort,
      ).toString();
    }

    final fallbackScheme = isTunnelHost ? 'https' : 'http';
    final fallbackUri = Uri.parse('$fallbackScheme://$trimmed');
    if (fallbackUri.host.isEmpty) {
      return trimmed;
    }

    if (fallbackUri.hasPort) {
      return fallbackUri.toString();
    }

    if (isTunnelHost) {
      return Uri(
        scheme: fallbackScheme,
        host: fallbackUri.host,
      ).toString();
    }

    return Uri(
      scheme: fallbackScheme,
      host: fallbackUri.host,
      port: flaskPort,
    ).toString();
  }
}
