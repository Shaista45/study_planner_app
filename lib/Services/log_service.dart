import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

enum LogLevel { debug, info, warning, error }

class LogService {
  static final LogService _instance = LogService._internal();
  late File _logFile;
  late IOSink _logSink;
  bool _isInitialized = false;
  Timer? _flushTimer;

  LogService._internal();

  factory LogService() {
    return _instance;
  }

  /// Initialize the logging service and open the log file
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String logPath =
          '${directory.path}/logs/app_${DateTime.now().year}_${DateTime.now().month}_${DateTime.now().day}.log';

      // Create logs directory if it doesn't exist
      final Directory logsDir = Directory(logPath).parent;
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      _logFile = File(logPath);
      _logSink = _logFile.openWrite(mode: FileMode.append);

      _isInitialized = true;

      // Log app initialization
      _log(LogLevel.info, 'App initialized - ${DateTime.now()}');

      // Set up periodic flush (every 5 seconds)
      _flushTimer = Timer.periodic(Duration(seconds: 5), (_) {
        _flush();
      });
    } catch (e) {
      print('Error initializing LogService: $e');
    }
  }

  /// Log a message with the specified level
  Future<void> log(LogLevel level, String message) async {
    if (!_isInitialized) {
      await init();
    }
    _log(level, message);
  }

  /// Internal logging method
  void _log(LogLevel level, String message) {
    final String timestamp = DateTime.now().toIso8601String();
    final String levelStr = level.toString().split('.').last.toUpperCase();
    final String logEntry = '[$timestamp] [$levelStr] $message';

    try {
      _logSink.writeln(logEntry);
    } catch (e) {
      print('Error writing to log: $e');
    }
  }

  /// Convenience method for debug logs
  Future<void> debug(String message) => log(LogLevel.debug, message);

  /// Convenience method for info logs
  Future<void> info(String message) => log(LogLevel.info, message);

  /// Convenience method for warning logs
  Future<void> warning(String message) => log(LogLevel.warning, message);

  /// Convenience method for error logs
  Future<void> error(String message) => log(LogLevel.error, message);

  /// Flush pending logs to file
  Future<void> _flush() async {
    try {
      await _logSink.flush();
    } catch (e) {
      print('Error flushing logs: $e');
    }
  }

  /// Force flush and close the log file
  Future<void> close() async {
    _flushTimer?.cancel();
    await _flush();
    await _logSink.close();
  }

  /// Get the path to the log file
  Future<String> getLogFilePath() async {
    if (!_isInitialized) {
      await init();
    }
    return _logFile.path;
  }

  /// Read log file contents
  Future<String> getLogContents() async {
    if (!_isInitialized) {
      await init();
    }
    try {
      return await _logFile.readAsString();
    } catch (e) {
      return 'Error reading log file: $e';
    }
  }

  /// Clear the log file
  Future<void> clearLogs() async {
    if (!_isInitialized) {
      await init();
    }
    try {
      await _logSink.close();
      await _logFile.delete();
      _logSink = _logFile.openWrite(mode: FileMode.write);
      _log(LogLevel.info, 'Logs cleared - ${DateTime.now()}');
    } catch (e) {
      print('Error clearing logs: $e');
    }
  }
}

// Global logger instance for easy access
final logger = LogService();
