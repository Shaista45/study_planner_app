# Logging System Documentation

Your app now includes a comprehensive logging system that automatically saves all actions to a log file on the device.

## Overview

The logging system consists of:
- **LogService** (`lib/Services/log_service.dart`) - Core logging service that handles file I/O
- **AppLogger** (`lib/utils/app_logger.dart`) - Helper class with convenient methods for logging common app actions

## Features

✅ Automatic file-based logging  
✅ Timestamped entries with log levels (DEBUG, INFO, WARNING, ERROR)  
✅ Daily log files (automatically creates new file each day)  
✅ Auto-flushing to ensure logs are written to disk  
✅ Easy-to-use helper methods for common actions  
✅ Read, view, and clear logs programmatically  

## Log File Location

Logs are saved to: `Documents/logs/app_YYYY_M_D.log`

On different platforms:
- **Android**: `/data/data/com.yourapp/files/app_2024_6_11.log`
- **iOS**: `Documents/logs/app_2024_6_11.log`

## Usage Examples

### Basic Logging

```dart
import 'package:smart_study_planner/services/log_service.dart';

// Using the global logger instance
await logger.info('This is an info message');
await logger.debug('Debug information');
await logger.warning('Warning message');
await logger.error('Error occurred');
```

### Using AppLogger Helper Methods

```dart
import 'package:smart_study_planner/utils/app_logger.dart';

// Authentication events
await AppLogger.logAuthEvent('Login', userId: 'user123', details: 'Login successful');
await AppLogger.logAuthEvent('Logout', userId: 'user123');

// Navigation
await AppLogger.logNavigation('DashboardScreen', fromScreen: 'AuthScreen');
await AppLogger.logNavigation('TaskDetailScreen', params: {'taskId': '123'});

// Task events
await AppLogger.logTaskEvent('Created', taskId: 'task_001', taskName: 'Math Homework');
await AppLogger.logTaskEvent('Completed', taskId: 'task_001');
await AppLogger.logTaskEvent('Deleted', taskId: 'task_001');

// Data sync
await AppLogger.logSyncEvent('FirebaseSync', status: 'Started');
await AppLogger.logSyncEvent('FirebaseSync', status: 'Completed', details: '15 items synced');

// User interactions
await AppLogger.logUserAction('Button Tapped', element: 'Add Task Button');
await AppLogger.logUserAction('Settings Changed', element: 'Notification Toggle', details: 'Enabled');

// Settings changes
await AppLogger.logSettingChange('Theme', 'Light', 'Dark');
await AppLogger.logSettingChange('Notification Time', '9:00 AM', '10:00 AM');

// Errors
try {
  // some operation
} catch (e) {
  await AppLogger.logError('Task creation failed', errorCode: 'TASK_001', stackTrace: e.toString());
}

// Notifications
await AppLogger.logNotification('TaskReminder', title: 'Task Due', body: 'Math homework due in 1 hour');

// API calls
await AppLogger.logApiCall('/api/tasks', method: 'GET', statusCode: 200, details: 'Retrieved 5 tasks');
await AppLogger.logApiCall('/api/tasks', method: 'POST', statusCode: 201, details: 'Task created');

// Database operations
await AppLogger.logDatabaseOperation('Save', collection: 'tasks', documentId: 'task_001');
await AppLogger.logDatabaseOperation('Delete', collection: 'tasks', documentId: 'task_001');

// Performance metrics
final stopwatch = Stopwatch()..start();
// ... some operation ...
stopwatch.stop();
await AppLogger.logPerformance('Database Query', stopwatch.elapsed, details: 'Fetched user tasks');
```

## Practical Implementation Examples

### In Authentication Screen
```dart
import 'package:smart_study_planner/utils/app_logger.dart';

Future<void> loginUser() async {
  try {
    await AppLogger.logUserAction('Login attempt', element: 'Login Button');
    
    // Your login logic
    final user = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    await AppLogger.logAuthEvent('Login', userId: user.uid, details: 'Login successful');
    
    // Navigate to home
    if (mounted) {
      await AppLogger.logNavigation('DashboardScreen', fromScreen: 'AuthScreen');
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  } catch (e) {
    await AppLogger.logError('Login failed', stackTrace: e.toString());
  }
}
```

### In Task Management
```dart
Future<void> createTask(Task task) async {
  try {
    await AppLogger.logUserAction('Create task', element: 'Add Task Button');
    
    // Create task in database
    final docRef = await firestoreInstance.collection('tasks').add(task.toMap());
    
    await AppLogger.logTaskEvent('Created', taskId: docRef.id, taskName: task.title);
    await AppLogger.logDatabaseOperation('Create', collection: 'tasks', documentId: docRef.id);
    
  } catch (e) {
    await AppLogger.logError('Task creation failed', errorCode: 'TASK_CREATE_ERROR', stackTrace: e.toString());
  }
}
```

### In Settings Screen
```dart
Future<void> updateNotificationTime(String newTime) async {
  final oldTime = currentNotificationTime;
  
  await AppLogger.logUserAction('Settings change', element: 'Notification Time Picker');
  await AppLogger.logSettingChange('NotificationTime', oldTime, newTime);
  
  // Update preference
  await sharedPreferences.setString('notificationTime', newTime);
}
```

## Viewing Logs

### In Debug
```dart
// Get log file path
final logPath = await AppLogger.getLogPath();
print('Log file path: $logPath');

// Get log contents
final logs = await AppLogger.getLogs();
print(logs);
```

### Create a Logs Viewer Screen
```dart
class LogViewerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('App Logs')),
      body: FutureBuilder<String>(
        future: AppLogger.getLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: SelectableText(snapshot.data ?? 'No logs'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await AppLogger.clearLogs();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logs cleared')),
          );
        },
        child: Icon(Icons.delete),
      ),
    );
  }
}
```

## Log Format

Each log entry follows this format:
```
[2024-06-11T14:30:45.123456] [INFO] AUTH EVENT: Login (User: user123) - Login successful
[2024-06-11T14:30:46.456789] [ERROR] Task: Creation failed - Firestore error
```

## Best Practices

1. **Log significant actions**: Login, logout, data creation/modification/deletion
2. **Log errors**: Always log errors with context
3. **Include IDs**: Log relevant IDs (userId, taskId, documentId) for debugging
4. **Use appropriate levels**: 
   - DEBUG: Development debugging info
   - INFO: Important app events
   - WARNING: Potential issues
   - ERROR: Failures and exceptions
5. **Clean up old logs**: Periodically clear logs to save storage space

## API Reference

### LogService (Core)

```dart
// Initialize (automatically called in main.dart)
await logger.init();

// Log methods
await logger.log(LogLevel.info, 'message');
await logger.debug('message');
await logger.info('message');
await logger.warning('message');
await logger.error('message');

// Utility methods
await logger.getLogFilePath();
await logger.getLogContents();
await logger.clearLogs();
await logger.close();
```

### AppLogger (Helpers)

```dart
await AppLogger.logAuthEvent(action, userId, details);
await AppLogger.logNavigation(screenName, fromScreen, params);
await AppLogger.logTaskEvent(action, taskId, taskName, details);
await AppLogger.logSyncEvent(syncType, status, details);
await AppLogger.logUserAction(action, element, details);
await AppLogger.logSettingChange(setting, oldValue, newValue);
await AppLogger.logError(errorMessage, errorCode, stackTrace);
await AppLogger.logNotification(type, title, body, details);
await AppLogger.logApiCall(endpoint, method, statusCode, details);
await AppLogger.logDatabaseOperation(operation, collection, documentId, details);
await AppLogger.logPerformance(metric, duration, details);
```

## Troubleshooting

**Q: Logs not appearing?**  
A: Make sure `await logger.init()` is called in `main()`. Check file permissions on the device.

**Q: Storage getting full?**  
A: Regularly clear logs using `AppLogger.clearLogs()` or delete the logs folder periodically.

**Q: Logs not flushing to disk?**  
A: The service auto-flushes every 5 seconds. Call `await logger.close()` when app closes if needed.

---

Now all your app actions are automatically logged and saved for debugging and monitoring! 🎯
