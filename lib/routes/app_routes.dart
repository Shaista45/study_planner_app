import 'package:flutter/material.dart';
import 'package:smart_study_planner/screens/app_shell.dart';
import 'package:smart_study_planner/screens/auth_screen.dart';
import 'package:smart_study_planner/screens/edit_task_screen.dart';
import 'package:smart_study_planner/screens/forgot_password_screen.dart';
import 'package:smart_study_planner/screens/notifications_screen.dart';
import 'package:smart_study_planner/screens/signup_screen.dart';
import 'package:smart_study_planner/screens/splash_screen.dart';
import 'package:smart_study_planner/screens/study_timetable_screen.dart';
import 'package:smart_study_planner/screens/subjects_screen.dart';

// FIX: Added 'hide SearchTasksScreen' so Flutter ignores the old placeholder!
import 'package:smart_study_planner/screens/task_extras_screens.dart'
    hide SearchTasksScreen;

import 'package:smart_study_planner/screens/weekly_overview_screen.dart';
import 'package:smart_study_planner/screens/search_tasks_screen.dart';

class AppRoutes {
  static const String shell = '/app';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String editProfile = '/edit-profile';

  static const String dashboard = '/dashboard';
  static const String addTask = '/tasks/add';
  static const String editTask = '/tasks/edit';
  static const String completedTasks = '/tasks/completed';
  static const String addReminder = '/tasks/reminder';
  static const String searchTasks = '/tasks/search';

  static const String subjects = '/subjects';
  static const String addSubject = '/subjects/add';
  static const String subjectDetail = '/subjects/detail';

  static const String studyTimetable = '/study/timetable';
  static const String studyProgress = '/study/progress';
  static const String weeklyOverview = '/study/weekly-overview';

  static const String notifications = '/notifications';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> getRoutes() {
    return <String, WidgetBuilder>{
      splash: (_) => const SplashScreen(),
      shell: (_) => AppShell(),
      login: (_) => const AuthScreen(),
      signup: (_) => const SignupScreen(),
      forgotPassword: (_) => const ForgotPasswordScreen(),
      editProfile: (_) => const EditProfileScreen(),
      dashboard: (_) => AppShell(initialIndex: 0),
      addTask: (_) => AppShell(initialIndex: 1),
      editTask: (_) => const EditTaskScreen(),
      completedTasks: (_) => const CompletedTasksScreen(),
      addReminder: (_) => const AddReminderScreen(),
      searchTasks: (_) => const SearchTasksScreen(),
      subjects: (_) => SubjectsScreen(),
      studyTimetable: (_) => const StudyTimetableScreen(),
      studyProgress: (_) => AppShell(initialIndex: 2),
      weeklyOverview: (_) => const WeeklyOverviewScreen(),
      notifications: (_) => const NotificationsScreen(),
      settings: (_) => AppShell(initialIndex: 3),
    };
  }
}
