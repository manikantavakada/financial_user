import 'dart:convert';
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class InstallationTracker {
  static const String baseUrl = 'https://ds.singledeck.in/api/v1/';

  static Future<void> trackInstallation(int clientId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceInfo = DeviceInfoPlugin();
      
      // Get or generate device ID
      String deviceId = prefs.getString('device_id') ?? '';
      String platform = 'web'; // Default to web
      
      if (deviceId.isEmpty) {
        // ✅ Use kIsWeb to check platform instead of Platform.isAndroid
        if (kIsWeb) {
          // Web platform
          final webInfo = await deviceInfo.webBrowserInfo;
          deviceId = 'web-${webInfo.userAgent?.hashCode ?? DateTime.now().millisecondsSinceEpoch}';
          platform = 'web';
        } else {
          // Mobile platforms
          try {
            if (Platform.isAndroid) {
              final androidInfo = await deviceInfo.androidInfo;
              deviceId = androidInfo.id;
              platform = 'android';
            } else if (Platform.isIOS) {
              final iosInfo = await deviceInfo.iosInfo;
              deviceId = iosInfo.identifierForVendor ?? '';
              platform = 'ios';
            }
          } catch (e) {
            debugPrint('Platform detection failed: $e');
            deviceId = 'unknown-${DateTime.now().millisecondsSinceEpoch}';
            platform = 'unknown';
          }
        }
        await prefs.setString('device_id', deviceId);
      } else {
        // Determine platform from saved device_id or detect again
        if (kIsWeb) {
          platform = 'web';
        } else {
          try {
            if (Platform.isAndroid) {
              platform = 'android';
            } else if (Platform.isIOS) {
              platform = 'ios';
            }
          } catch (e) {
            platform = 'unknown';
          }
        }
      }
      
      // Get app version
      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = packageInfo.version;
      
      // Current timestamp
      final now = DateTime.now().toIso8601String();
      
      final payload = {
        'cain_cust': clientId,
        'cain_device_id': deviceId,
        'cain_platform': platform,
        'cain_app_version': appVersion,
        'cain_installed_at': now,
        'cain_updated_at': now,
        'cain_is_active': true,
      };
      
      debugPrint('📲 Tracking installation: ${json.encode(payload)}');
      
      final response = await http.post(
        Uri.parse('${baseUrl}clients/add-customer-installation/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Installation tracked successfully');
      } else {
        debugPrint('⚠️ Installation tracking failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error tracking installation: $e');
    }
  }
}
