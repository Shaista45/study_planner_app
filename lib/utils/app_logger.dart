import 'package:smart_study_planner/services/log_service.dart';

/// Helper class for logging common app actions
class AppLogger {
  /// Log user authentication events
  static Future<void> logAuthEvent(
    String action, {
    String? userId,
    String? details,
  }) async {
    final userPart = userId != null ? ' (User: $userId)' : '';
    final detailsPart = details != null ? ' - $details' : '';
    final message = 'AUTH EVENT: $action$userPart$detailsPart';
    await logger.info(message);
  }

  /// Log navigation/screen events
  static Future<void> logNavigation(
    String screenName, {
    String? fromScreen,
    Map<String, dynamic>? params,
  }) async {
    final fromPart = fromScreen != null ? ' from $fromScreen' : '';
    final paramsPart = params != null ? ' with params: $params' : '';
    final message = 'NAVIGATION: Navigated to $screenName$fromPart$paramsPart';
    await logger.info(message);
  }

  /// Log task-related events
  static Future<void> logTaskEvent(
    String action, {
    String? taskId,
    String? taskName,
    String? details,
  }) async {
    final idPart = taskId != null ? ' (ID: $taskId)' : '';
    final namePart = taskName != null ? ' - $taskName' : '';
    final detailsPart = details != null ? ' - $details' : '';
    final message = 'TASK: $action$idPart$namePart$detailsPart';
    await logger.info(message);
  }

  /// Log data sync events
  static Future<void> logSyncEvent(
    String syncType, {
    String? status,
    String? details,
  }) async {
    final detailsPart = details != null ? ' - $details' : '';
    final message = 'SYNC: $syncType - $status$detailsPart';
    await logger.info(message);
  }

  /// Log user interactions
  static Future<void> logUserAction(
    String action, {
    String? element,
    String? details,
  }) async {
    final elementPart = element != null ? ' on $element' : '';
    final detailsPart = details != null ? ' - $details' : '';
    final message = 'USER ACTION: $action$elementPart$detailsPart';
    await logger.info(message);
  }

  /// Log settings/preference changes
  static Future<void> logSettingChange(
    String setting,
    dynamic oldValue,
    dynamic newValue,
  ) async {
    final message =
        'SETTING CHANGED: $setting - from "$oldValue" to "$newValue"';
    await logger.info(message);
  }

  /// Log errors
  static Future<void> logError(
    String errorMessage, {
    String? errorCode,
    String? stackTrace,
  }) async {
    final codePart = errorCode != null ? ' (Code: $errorCode)' : '';
    final stackPart = stackTrace != null ? '\nStackTrace: $stackTrace' : '';
    final message = 'ERROR: $errorMessage$codePart$stackPart';
    await logger.error(message);
  }

  /// Log notifications
  static Future<void> logNotification(
    String type, {
    String? title,
    String? body,
    String? details,
  }) async {
    final titlePart = title != null ? ' - Title: $title' : '';
    final bodyPart = body != null ? ' - Body: $body' : '';
    final detailsPart = details != null ? ' - $details' : '';
    final message = 'NOTIFICATION: $type$titlePart$bodyPart$detailsPart';
    await logger.info(message);
  }

  /// Log API calls
  static Future<void> logApiCall(
    String endpoint, {
    String? method,
    int? statusCode,
    String? details,
  }) async {
    final httpMethod = method ?? 'GET';
    final statusPart = statusCode != null ? ' - Status: $statusCode' : '';
    final detailsPart = details != null ? ' - $details' : '';
    final message = 'API CALL: $httpMethod $endpoint$statusPart$detailsPart';
    await logger.info(message);
  }

  /// Log database operations
  static Future<void> logDatabaseOperation(
    String operation, {
    String? collection,
    String? documentId,
    String? details,
  }) async {
    final collectionPart = collection != null ? ' in $collection' : '';
    final docPart = documentId != null ? ' (Doc: $documentId)' : '';
    final detailsPart = details != null ? ' - $details' : '';
    final message = 'DATABASE: $operation$collectionPart$docPart$detailsPart';
    await logger.info(message);
  }

  /// Log performance metrics
  static Future<void> logPerformance(
    String metric,
    Duration duration, {
    String? details,
  }) async {
    final detailsPart = details != null ? ' - $details' : '';
    final message =
        'PERFORMANCE: $metric took ${duration.inMilliseconds}ms$detailsPart';
    await logger.info(message);
  }

  /// Get current log file path
  static Future<String> getLogPath() async {
    return await logger.getLogFilePath();
  }

  /// Get log contents
  static Future<String> getLogs() async {
    return await logger.getLogContents();
  }

  /// Clear all logs
  static Future<void> clearLogs() async {
    await logger.clearLogs();
  }
}
