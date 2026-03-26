import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../models/inspiration.dart';

/// SQLite 数据库服务类
/// 管理灵感记录和讨论记录的增删改查
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  /// 获取数据库实例
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = path.join(databasesPath, 'inspiration_capsule.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreateDatabase,
      onUpgrade: _onUpgradeDatabase,
    );
  }

  /// 创建数据库表
  Future<void> _onCreateDatabase(Database db, int version) async {
    // 创建灵感记录表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS inspirations(
        id TEXT PRIMARY KEY,
        rawText TEXT NOT NULL,
        refinedText TEXT NOT NULL,
        tags TEXT DEFAULT '',
        category TEXT DEFAULT '未分类',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // 创建讨论记录表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS discussions(
        id TEXT PRIMARY KEY,
        inspirationId TEXT NOT NULL,
        role TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (inspirationId) REFERENCES inspirations(id) ON DELETE CASCADE
      )
    ''');

    // 创建索引
    await db.execute('CREATE INDEX IF NOT EXISTS idx_category ON inspirations(category)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_createdAt ON inspirations(createdAt DESC)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_inspirationId ON discussions(inspirationId)');
  }

  /// 数据库升级处理
  Future<void> _onUpgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 未来版本升级逻辑
    }
  }

  // ==================== 灵感记录 CRUD ====================

  /// 插入或替换灵感记录
  Future<void> insertInspiration(Inspiration inspiration) async {
    final db = await database;
    await db.insert(
      'inspirations',
      inspiration.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取所有灵感记录（按创建时间倒序）
  Future<List<Inspiration>> getAllInspirations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'inspirations',
      orderBy: 'createdAt DESC',
    );

    final inspirations = <Inspiration>[];
    for (var map in maps) {
      final inspiration = Inspiration.fromMap(map);
      final discussions = await getDiscussions(inspiration.id);
      inspirations.add(inspiration.copyWith(discussions: discussions));
    }

    return inspirations;
  }

  /// 按分类获取灵感记录
  Future<List<Inspiration>> getInspirationsByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'inspirations',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'createdAt DESC',
    );

    final inspirations = <Inspiration>[];
    for (var map in maps) {
      final inspiration = Inspiration.fromMap(map);
      final discussions = await getDiscussions(inspiration.id);
      inspirations.add(inspiration.copyWith(discussions: discussions));
    }

    return inspirations;
  }

  /// 根据 ID 获取单条灵感记录
  Future<Inspiration?> getInspiration(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'inspirations',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final inspiration = Inspiration.fromMap(maps.first);
    final discussions = await getDiscussions(inspiration.id);
    return inspiration.copyWith(discussions: discussions);
  }

  /// 更新灵感记录
  Future<void> updateInspiration(Inspiration inspiration) async {
    final db = await database;
    final updated = inspiration.copyWith(updatedAt: DateTime.now());
    await db.update(
      'inspirations',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [inspiration.id],
    );
  }

  /// 删除灵感记录（关联的讨论会自动删除）
  Future<void> deleteInspiration(String id) async {
    final db = await database;
    await db.delete(
      'inspirations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 讨论记录 CRUD ====================

  /// 插入讨论记录
  Future<void> insertDiscussion(String inspirationId, Discussion discussion) async {
    final db = await database;
    await db.insert(
      'discussions',
      discussion.toMap(inspirationId),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取某条灵感的所有讨论记录
  Future<List<Discussion>> getDiscussions(String inspirationId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'discussions',
      where: 'inspirationId = ?',
      whereArgs: [inspirationId],
      orderBy: 'timestamp ASC',
    );

    return List.generate(maps.length, (i) => Discussion.fromMap(maps[i]));
  }

  /// 删除单条讨论记录
  Future<void> deleteDiscussion(String discussionId) async {
    final db = await database;
    await db.delete(
      'discussions',
      where: 'id = ?',
      whereArgs: [discussionId],
    );
  }

  // ==================== 分类查询 ====================

  /// 获取所有分类列表
  Future<List<String>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT category FROM inspirations ORDER BY category ASC'
    );

    return maps.map((m) => m['category'] as String).toList();
  }

  /// 获取分类统计
  Future<Map<String, int>> getCategoryCounts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT category, COUNT(*) as count FROM inspirations GROUP BY category'
    );

    return {for (var m in maps) m['category'] as String: m['count'] as int};
  }

  // ==================== 数据库管理 ====================

  /// 关闭数据库连接
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// 删除整个数据库（谨慎使用）
  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = path.join(databasesPath, 'inspiration_capsule.db');
    await databaseFactory.deleteDatabase(dbPath);
    _database = null;
  }

  /// 获取数据库统计信息
  Future<Map<String, dynamic>> getStats() async {
    final db = await database;
    final inspirationCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM inspirations')
    ) ?? 0;
    final discussionCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM discussions')
    ) ?? 0;

    return {
      'inspirations': inspirationCount,
      'discussions': discussionCount,
    };
  }
}
