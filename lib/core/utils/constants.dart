class Constants {
  // Database
  static const String dbName = 'project_tree.db';
  static const int dbVersion = 1;

  // Pagination
  static const int pageSize = 20;

  // Animation Durations
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;

  // Tree View
  static const double treeIndentSize = 24.0;
  static const double treeNodeHeight = 80.0;

  // Board View
  static const double boardColumnWidth = 300.0;
  static const double boardCardMargin = 8.0;

  // Task Limits
  static const int maxTaskDepth = 10;
  static const int maxTaskTitleLength = 100;
  static const int maxTaskDescriptionLength = 500;

  // Project Limits
  static const int maxProjectNameLength = 50;
  static const int maxProjectDescriptionLength = 200;

  // Time
  static const int autoSaveIntervalSeconds = 30;
  static const int countdownUpdateIntervalSeconds = 1;

  // Storage Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyLastSync = 'last_sync';
  static const String keyCurrentView = 'current_view';
  static const String keySelectedProject = 'selected_project';

  // Error Messages
  static const String errorLoadingProjects = 'Failed to load projects';
  static const String errorSavingProject = 'Failed to save project';
  static const String errorDeletingProject = 'Failed to delete project';
  static const String errorLoadingTasks = 'Failed to load tasks';
  static const String errorSavingTask = 'Failed to save task';
  static const String errorDeletingTask = 'Failed to delete task';

  // Success Messages
  static const String successProjectCreated = 'Project created successfully';
  static const String successProjectUpdated = 'Project updated successfully';
  static const String successProjectDeleted = 'Project deleted successfully';
  static const String successTaskCreated = 'Task created successfully';
  static const String successTaskUpdated = 'Task updated successfully';
  static const String successTaskDeleted = 'Task deleted successfully';
}