import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiUrlService {
  static const String _prefsKey = 'cached_api_base_url';
  static const String _firestoreCollection = 'settings';
  static const String _firestoreDoc = 'settings';
  static const String _firestoreField = 'API_BASE_URL';
  static const Duration _healthCheckTimeout = Duration(seconds: 10);

  static String? _cachedUrl;
  static Future<void> initialize() async {
    try {
      // Get the initial URL to test
      String urlToTest = await _getInitialUrl();

      // Test health endpoint
      bool isHealthy = await _checkHealth(urlToTest);

      if (isHealthy) {
        // URL is working, cache it if it's not already cached
        await _cacheUrl(urlToTest);
        _cachedUrl = urlToTest;
        print('✅ API URL initialized successfully: $urlToTest');
      } else {
        // URL is not working, try to get from Firestore
        print('❌ Health check failed for: $urlToTest');
        await _handleUnhealthyUrl();
      }
    } catch (e) {
      print('🚨 Error initializing API URL service: $e');
      // Fallback to .env or cached URL
      _cachedUrl = await _getInitialUrl();
    }
  }

  static String getBaseUrl() {
    if (_cachedUrl != null) {
      return _cachedUrl!;
    }
    return _getFallbackUrl();
  }

  static Future<String> _getInitialUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedUrl =
          prefs.getString(_prefsKey); // "http://169.254.162.122:8000";

      if (cachedUrl != null && cachedUrl.isNotEmpty) {
        print('📱 Using cached URL from SharedPreferences: $cachedUrl');
        return cachedUrl;
      }

      final envUrl = dotenv.env['API_BASE_URL'] ?? 'http://192.168.0.130:8000';
      print('📄 Using URL from .env: $envUrl');
      return envUrl;
    } catch (e) {
      print('⚠️ Error getting initial URL: $e');
      return dotenv.env['API_BASE_URL'] ?? 'http://192.168.0.130:8000';
    }
  }

  static String _getFallbackUrl() {
    return dotenv.env['API_BASE_URL'] ?? 'http://192.168.0.130:8000';
  }

  static Future<bool> _checkHealth(String baseUrl) async {
    try {
      final healthUrl = '$baseUrl/health';
      print('🏥 Checking health: $healthUrl');

      final response = await http.get(
        Uri.parse(healthUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_healthCheckTimeout);

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print('Health check passed: ${data.toString()}');
          return true;
        } catch (e) {
          final body = response.body.toLowerCase();
          bool isHealthy = body.contains('ok') ||
              body.contains('healthy') ||
              body.contains('success') ||
              body.contains('running');

          return isHealthy;
        }
      } else {
        print('Health check failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Health check error: $e');
      return false;
    }
  }

  static Future<void> _handleUnhealthyUrl() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(_firestoreCollection)
          .doc(_firestoreDoc)
          .get()
          .timeout(const Duration(seconds: 15));

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final newUrl = data[_firestoreField] as String?;

        if (newUrl != null && newUrl.isNotEmpty) {
          bool isNewUrlHealthy = await _checkHealth(newUrl);

          if (isNewUrlHealthy) {
            await _cacheUrl(newUrl);
            _cachedUrl = newUrl;
          } else {
            _cachedUrl = await _getInitialUrl(); // Fallback to original
          }
        } else {
          _cachedUrl = await _getInitialUrl();
        }
      } else {
        _cachedUrl = await _getInitialUrl();
      }
    } catch (e) {
      _cachedUrl = await _getInitialUrl();
    }
  }

  static Future<void> _cacheUrl(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, url);
    } catch (e) {
      print('Error caching URL: $e');
    }
  }

  /// Force refresh the API URL (useful for manual refresh)
  static Future<String> refreshUrl() async {
    try {
      String currentUrl = await _getInitialUrl();
      bool isHealthy = await _checkHealth(currentUrl);

      if (!isHealthy) {
        await _handleUnhealthyUrl();
      } else {
        _cachedUrl = currentUrl;
      }

      return _cachedUrl ?? currentUrl;
    } catch (e) {
      return _getFallbackUrl();
    }
  }

  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
      _cachedUrl = null;
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  static Future<String?> getCachedUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_prefsKey);
    } catch (e) {
      return null;
    }
  }

  static bool get isInitialized => _cachedUrl != null;

  static Future<Map<String, dynamic>> getStatus() async {
    final cachedUrl = await getCachedUrl();
    final currentUrl = getBaseUrl();
    final isHealthy = await _checkHealth(currentUrl);

    return {
      'isInitialized': isInitialized,
      'currentUrl': currentUrl,
      'cachedUrl': cachedUrl,
      'envUrl': dotenv.env['API_BASE_URL'],
      'isHealthy': isHealthy,
      'lastChecked': DateTime.now().toIso8601String(),
    };
  }
}
