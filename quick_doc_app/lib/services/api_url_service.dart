import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service to manage API base URL dynamically
/// Handles health checks, fallback to Firestore, and local caching
class ApiUrlService {
  static const String _prefsKey = 'cached_api_base_url';
  static const String _firestoreCollection = 'settings';
  static const String _firestoreDoc = 'settings';
  static const String _firestoreField = 'API_BASE_URL';
  static const Duration _healthCheckTimeout = Duration(seconds: 10);

  static String? _cachedUrl;

  /// Initialize the API URL service
  /// This should be called during app startup
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

  /// Get the current API base URL
  /// This method should be used by constants.dart
  static String getBaseUrl() {
    if (_cachedUrl != null) {
      return _cachedUrl!;
    }

    // Fallback to synchronous methods if service not initialized
    return _getFallbackUrl();
  }

  /// Get initial URL from SharedPreferences or .env
  static Future<String> _getInitialUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedUrl = "http://169.254.162.122:8000";
      // prefs.getString(_prefsKey);

      if (cachedUrl != null && cachedUrl.isNotEmpty) {
        print('📱 Using cached URL from SharedPreferences: $cachedUrl');
        return cachedUrl;
      }

      // Fallback to .env
      final envUrl = dotenv.env['API_BASE_URL'] ?? 'http://192.168.0.130:8000';
      print('📄 Using URL from .env: $envUrl');
      return envUrl;
    } catch (e) {
      print('⚠️ Error getting initial URL: $e');
      return dotenv.env['API_BASE_URL'] ?? 'http://192.168.0.130:8000';
    }
  }

  /// Get fallback URL synchronously
  static String _getFallbackUrl() {
    return dotenv.env['API_BASE_URL'] ?? 'http://192.168.0.130:8000';
  }

  /// Check if the API endpoint is healthy
  static Future<bool> _checkHealth(String baseUrl) async {
    try {
      final healthUrl = '$baseUrl/health';
      print('🏥 Checking health: $healthUrl');

      final response = await http.get(
        Uri.parse(healthUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_healthCheckTimeout);

      if (response.statusCode == 200) {
        // Try to parse response to ensure it's valid JSON
        try {
          final data = json.decode(response.body);
          print('✅ Health check passed: ${data.toString()}');
          return true;
        } catch (e) {
          // If not JSON, check if response contains success indicators
          final body = response.body.toLowerCase();
          bool isHealthy = body.contains('ok') ||
              body.contains('healthy') ||
              body.contains('success') ||
              body.contains('running');
          print(isHealthy
              ? '✅ Health check passed (non-JSON)'
              : '❌ Health check failed (invalid response)');
          return isHealthy;
        }
      } else {
        print('❌ Health check failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Health check error: $e');
      return false;
    }
  }

  /// Handle unhealthy URL by fetching from Firestore
  static Future<void> _handleUnhealthyUrl() async {
    try {
      print('🔥 Fetching new URL from Firestore...');

      final doc = await FirebaseFirestore.instance
          .collection(_firestoreCollection)
          .doc(_firestoreDoc)
          .get()
          .timeout(const Duration(seconds: 15));

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final newUrl = data[_firestoreField] as String?;

        if (newUrl != null && newUrl.isNotEmpty) {
          print('🔥 Found new URL in Firestore: $newUrl');

          // Test the new URL
          bool isNewUrlHealthy = await _checkHealth(newUrl);

          if (isNewUrlHealthy) {
            await _cacheUrl(newUrl);
            _cachedUrl = newUrl;
            print('✅ New URL from Firestore is healthy and cached');
          } else {
            print('❌ New URL from Firestore is also unhealthy');
            _cachedUrl = await _getInitialUrl(); // Fallback to original
          }
        } else {
          print('⚠️ No valid URL found in Firestore');
          _cachedUrl = await _getInitialUrl();
        }
      } else {
        print('⚠️ Firestore settings document not found');
        _cachedUrl = await _getInitialUrl();
      }
    } catch (e) {
      print('🚨 Error fetching from Firestore: $e');
      _cachedUrl = await _getInitialUrl();
    }
  }

  /// Cache URL in SharedPreferences
  static Future<void> _cacheUrl(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, url);
      print('💾 URL cached successfully: $url');
    } catch (e) {
      print('⚠️ Error caching URL: $e');
    }
  }

  /// Force refresh the API URL (useful for manual refresh)
  static Future<String> refreshUrl() async {
    try {
      print('🔄 Force refreshing API URL...');

      // First try the currently cached URL
      String currentUrl = await _getInitialUrl();
      bool isHealthy = await _checkHealth(currentUrl);

      if (!isHealthy) {
        // If unhealthy, fetch from Firestore
        await _handleUnhealthyUrl();
      } else {
        _cachedUrl = currentUrl;
      }

      return _cachedUrl ?? currentUrl;
    } catch (e) {
      print('🚨 Error refreshing URL: $e');
      return _getFallbackUrl();
    }
  }

  /// Clear cached URL (useful for testing)
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
      _cachedUrl = null;
      print('🗑️ URL cache cleared');
    } catch (e) {
      print('⚠️ Error clearing cache: $e');
    }
  }

  /// Get current cached URL for debugging
  static Future<String?> getCachedUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_prefsKey);
    } catch (e) {
      return null;
    }
  }

  /// Check if service is initialized
  static bool get isInitialized => _cachedUrl != null;

  /// Get service status for debugging
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
