import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LogService {
  static const String storageKeyLogs = 'app_logs';
  static const int maxLogs = 1000;

  static Future<void> log(String message, {String level = 'INFO'}) async {
    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'level': level,
      'message': message,
    };

    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getString(storageKeyLogs) ?? '[]';
    final List<dynamic> logs = json.decode(logsJson);

    logs.add(logEntry);
    if (logs.length > maxLogs) {
      logs.removeRange(0, logs.length - maxLogs);
    }

    await prefs.setString(storageKeyLogs, json.encode(logs));
  }

  static Future<List<Map<String, dynamic>>> getLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getString(storageKeyLogs) ?? '[]';
    final List<dynamic> logs = json.decode(logsJson);
    return logs.cast<Map<String, dynamic>>().reversed.toList();
  }

  static Future<void> clearLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKeyLogs);
  }

  static Future<void> logError(String message, [Object? error]) async {
    final errorMessage = error != null ? '$message: $error' : message;
    await log(errorMessage, level: 'ERROR');
  }

  static Future<void> logInfo(String message) async {
    await log(message, level: 'INFO');
  }

  static Future<void> logDebug(String message) async {
    await log(message, level: 'DEBUG');
  }
}