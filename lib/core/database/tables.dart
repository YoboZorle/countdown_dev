class Tables {
  static const String createProjectsTable = '''
    CREATE TABLE projects (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      color INTEGER NOT NULL,
      start_date TEXT NOT NULL,
      end_date TEXT NOT NULL,
      status TEXT NOT NULL,
      progress REAL DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';

  static const String createTaskNodesTable = '''
    CREATE TABLE task_nodes (
      id TEXT PRIMARY KEY,
      project_id TEXT NOT NULL,
      parent_id TEXT,
      title TEXT NOT NULL,
      description TEXT,
      status TEXT NOT NULL,
      priority TEXT NOT NULL,
      assignee_id TEXT,
      start_date TEXT,
      due_date TEXT NOT NULL,
      completed_date TEXT,
      progress REAL DEFAULT 0,
      position INTEGER NOT NULL,
      depth INTEGER NOT NULL,
      estimated_hours REAL,
      actual_hours REAL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE,
      FOREIGN KEY (parent_id) REFERENCES task_nodes (id) ON DELETE CASCADE,
      FOREIGN KEY (assignee_id) REFERENCES team_members (id)
    )
  ''';

  static const String createMilestonesTable = '''
    CREATE TABLE milestones (
      id TEXT PRIMARY KEY,
      project_id TEXT NOT NULL,
      title TEXT NOT NULL,
      description TEXT,
      due_date TEXT NOT NULL,
      completed BOOLEAN DEFAULT 0,
      created_at TEXT NOT NULL,
      FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE
    )
  ''';

  static const String createTeamMembersTable = '''
    CREATE TABLE team_members (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      role TEXT NOT NULL,
      avatar_color INTEGER NOT NULL,
      created_at TEXT NOT NULL
    )
  ''';

  static const String createProjectMembersTable = '''
    CREATE TABLE project_members (
      project_id TEXT NOT NULL,
      member_id TEXT NOT NULL,
      PRIMARY KEY (project_id, member_id),
      FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE,
      FOREIGN KEY (member_id) REFERENCES team_members (id) ON DELETE CASCADE
    )
  ''';

  static const String createCommentsTable = '''
    CREATE TABLE comments (
      id TEXT PRIMARY KEY,
      task_id TEXT NOT NULL,
      author_id TEXT NOT NULL,
      content TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (task_id) REFERENCES task_nodes (id) ON DELETE CASCADE,
      FOREIGN KEY (author_id) REFERENCES team_members (id)
    )
  ''';

  static const String createIndexes = '''
    CREATE INDEX idx_task_nodes_project_id ON task_nodes(project_id);
    CREATE INDEX idx_task_nodes_parent_id ON task_nodes(parent_id);
    CREATE INDEX idx_milestones_project_id ON milestones(project_id);
    CREATE INDEX idx_comments_task_id ON comments(task_id);
  ''';
}