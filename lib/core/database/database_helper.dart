import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'tables.dart';

class DatabaseHelper {
  static const _databaseName = "project_tree.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Projects table
    await db.execute(Tables.createProjectsTable);
    
    // Task nodes table
    await db.execute(Tables.createTaskNodesTable);
    
    // Milestones table
    await db.execute(Tables.createMilestonesTable);
    
    // Team members table
    await db.execute(Tables.createTeamMembersTable);
    
    // Project members junction table
    await db.execute(Tables.createProjectMembersTable);
    
    // Comments table
    await db.execute(Tables.createCommentsTable);
    
    // Create indexes
    await db.execute(Tables.createIndexes);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations
  }

  // CRUD operations for Projects
  Future<int> insertProject(Map<String, dynamic> project) async {
    Database db = await database;
    return await db.insert('projects', project);
  }

  Future<List<Map<String, dynamic>>> getProjects() async {
    Database db = await database;
    return await db.query('projects', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getProject(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateProject(Map<String, dynamic> project) async {
    Database db = await database;
    return await db.update(
      'projects',
      project,
      where: 'id = ?',
      whereArgs: [project['id']],
    );
  }

  Future<int> deleteProject(String id) async {
    Database db = await database;
    return await db.delete(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD operations for Task Nodes
  Future<int> insertTaskNode(Map<String, dynamic> task) async {
    Database db = await database;
    return await db.insert('task_nodes', task);
  }

  Future<List<Map<String, dynamic>>> getTaskNodes(String projectId) async {
    Database db = await database;
    return await db.query(
      'task_nodes',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'position ASC',
    );
  }

  Future<int> updateTaskNode(Map<String, dynamic> task) async {
    Database db = await database;
    return await db.update(
      'task_nodes',
      task,
      where: 'id = ?',
      whereArgs: [task['id']],
    );
  }

  Future<int> deleteTaskNode(String id) async {
    Database db = await database;
    return await db.delete(
      'task_nodes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get tasks by parent
  Future<List<Map<String, dynamic>>> getChildTasks(String parentId) async {
    Database db = await database;
    return await db.query(
      'task_nodes',
      where: 'parent_id = ?',
      whereArgs: [parentId],
      orderBy: 'position ASC',
    );
  }

  // Update task positions for drag & drop
  Future<void> updateTaskPositions(List<Map<String, dynamic>> tasks) async {
    Database db = await database;
    Batch batch = db.batch();
    
    for (var task in tasks) {
      batch.update(
        'task_nodes',
        {'position': task['position'], 'parent_id': task['parent_id']},
        where: 'id = ?',
        whereArgs: [task['id']],
      );
    }
    
    await batch.commit();
  }

  // Milestones
  Future<int> insertMilestone(Map<String, dynamic> milestone) async {
    Database db = await database;
    return await db.insert('milestones', milestone);
  }

  Future<List<Map<String, dynamic>>> getMilestones(String projectId) async {
    Database db = await database;
    return await db.query(
      'milestones',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'due_date ASC',
    );
  }

  // Team members
  Future<int> insertTeamMember(Map<String, dynamic> member) async {
    Database db = await database;
    return await db.insert('team_members', member);
  }

  Future<List<Map<String, dynamic>>> getTeamMembers() async {
    Database db = await database;
    return await db.query('team_members');
  }

  // Assign member to project
  Future<void> assignMemberToProject(String projectId, String memberId) async {
    Database db = await database;
    await db.insert('project_members', {
      'project_id': projectId,
      'member_id': memberId,
    });
  }

  // Get project members
  Future<List<Map<String, dynamic>>> getProjectMembers(String projectId) async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT tm.* FROM team_members tm
      JOIN project_members pm ON tm.id = pm.member_id
      WHERE pm.project_id = ?
    ''', [projectId]);
  }

  // Comments
  Future<int> insertComment(Map<String, dynamic> comment) async {
    Database db = await database;
    return await db.insert('comments', comment);
  }

  Future<List<Map<String, dynamic>>> getTaskComments(String taskId) async {
    Database db = await database;
    return await db.query(
      'comments',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'created_at DESC',
    );
  }
}