import 'package:package_info_plus/package_info_plus.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:version/version.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class AppUpdateService {
  static const String _currentVersion = '2.0.0';
  // static const String _appStoreUrl = 'https://play.google.com/store/apps/details?id=com.chinnakuyil.studio';
  // static const String _updateCheckUrl = 'https://api.chinnakuyil.studio/v1/version';

  static Future<void> checkForUpdates({bool forceUpdate = false}) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      if (kDebugMode) {
        debugPrint('Current app version: $currentVersion');
        return;
      }

      // Check for updates from server
      final latestVersion = await _getLatestVersion();
      if (latestVersion == null) return;

      final current = Version.parse(currentVersion);
      final latest = Version.parse(latestVersion);

      if (latest > current) {
        debugPrint('Update available: $latestVersion');
        await _showUpdateDialog(current, latest, forceUpdate);
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  static Future<String?> _getLatestVersion() async {
    try {
      // In production, this would call your version API
      // For now, return current version (no update needed)
      return _currentVersion;
    } catch (e) {
      debugPrint('Error fetching latest version: $e');
      return null;
    }
  }

  static Future<void> _showUpdateDialog(Version current, Version latest, bool forceUpdate) async {
    if (Platform.isAndroid) {
      await _showAndroidUpdate(current, latest, forceUpdate);
    } else if (Platform.isIOS) {
      await _showIOSUpdate(current, latest, forceUpdate);
    }
  }

  static Future<void> _showAndroidUpdate(Version current, Version latest, bool forceUpdate) async {
    try {
      final appUpdateInfo = await InAppUpdate.checkForUpdate();
      
      if (appUpdateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (appUpdateInfo.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate();
        } else if (appUpdateInfo.immediateUpdateAllowed || forceUpdate) {
          await InAppUpdate.performImmediateUpdate();
        }
      }
    } catch (e) {
      debugPrint('Error showing Android update: $e');
    }
  }

  static Future<void> _showIOSUpdate(Version current, Version latest, bool forceUpdate) async {
    // For iOS, we need to redirect to App Store
    // This would typically show a custom dialog
    debugPrint('iOS update available: $latest');
    // TODO: Show custom iOS update dialog
  }

  static Future<Map<String, dynamic>> getAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = await _getDeviceInfo();
    
    return {
      'version': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
      'appName': packageInfo.appName,
      'packageName': packageInfo.packageName,
      'device': deviceInfo,
      'platform': Platform.operatingSystem,
    };
  }

  static Future<Map<String, String>> _getDeviceInfo() async {
    // This would use device_info_plus in a real implementation
    return {
      'model': 'Mobile Device',
      'os': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
    };
  }

  static Future<void> scheduleUpdateCheck() async {
    // Check for updates on app start
    await checkForUpdates();
    
    // Optionally schedule periodic checks (background)
    // This would require background execution capabilities
  }

  static bool isUpdateAvailable(Version current, Version latest) {
    return latest > current;
  }

  static String getUpdateType(Version current, Version latest) {
    if (latest.major > current.major) return 'major';
    if (latest.minor > current.minor) return 'minor';
    if (latest.patch > current.patch) return 'patch';
    return 'none';
  }
}
