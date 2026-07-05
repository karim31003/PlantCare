import 'package:shared_preferences/shared_preferences.dart';

class ApiConfigService {
  static const String _apiHostKey = 'api_host';

  static String? _apiHost;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _apiHost = prefs.getString(_apiHostKey);
  }

  static String? get apiHost => _apiHost;

  static Future<void> setApiHost(String host) async {
    final normalized = normalizeHost(host);
    final prefs = await SharedPreferences.getInstance();

    if (normalized.isEmpty) {
      _apiHost = null;
      await prefs.remove(_apiHostKey);
      return;
    }

    _apiHost = normalized;
    await prefs.setString(_apiHostKey, normalized);
  }

  static Future<void> clearApiHost() async {
    _apiHost = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiHostKey);
  }

  static String normalizeHost(String host) {
    final trimmed = host.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final hasScheme = trimmed.toLowerCase().startsWith('http://') ||
        trimmed.toLowerCase().startsWith('https://');
    
    String scheme = '';
    String hostPart = trimmed;
    
    if (hasScheme) {
      final schemeMatch = RegExp(r'^https?://', caseSensitive: false).firstMatch(trimmed);
      if (schemeMatch != null) {
        scheme = schemeMatch.group(0)!.toLowerCase();
        hostPart = trimmed.substring(scheme.length);
      }
    } else {
      // Handle corrupted schemes like http:/ or http:// with spaces
      final corruptMatch = RegExp(r'^https?:\s*/\s*/', caseSensitive: false).firstMatch(trimmed);
      if (corruptMatch != null) {
        scheme = corruptMatch.group(0)!.contains('https') ? 'https://' : 'http://';
        hostPart = trimmed.substring(corruptMatch.group(0)!.length);
      }
    }

    final cleanedHost = hostPart.replaceAll(RegExp(r'\s+'), '');
    return '$scheme$cleanedHost';
  }
}
