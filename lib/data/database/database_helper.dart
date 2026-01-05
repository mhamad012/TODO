import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'taskflow.db');
    return await openDatabase(
      path,
      version: 3, // Incremented to version 3 for the userId addition
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tasks table - WITH userId column
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        dueDate TEXT NOT NULL,
        priority TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        category TEXT,
        tags TEXT,
        createdAt TEXT NOT NULL,
        userId TEXT NOT NULL
      )
    ''');

    // Users/Profile table - Multiple users supported
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        notificationEnabled INTEGER NOT NULL DEFAULT 1,
        themeMode TEXT NOT NULL DEFAULT 'system',
        createdAt TEXT NOT NULL
      )
    ''');

    // NO default profile row - users register themselves
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migrate from version 1 to 2
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE profile ADD COLUMN password TEXT');
    }

    // Migrate from version 2 to 3
    if (oldVersion < 3) {
      // Add userId column to tasks table
      await db.execute('ALTER TABLE tasks ADD COLUMN userId TEXT');
      
      // Rename profile table to users and add proper constraints
      await db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          notificationEnabled INTEGER NOT NULL DEFAULT 1,
          themeMode TEXT NOT NULL DEFAULT 'system',
          createdAt TEXT NOT NULL
        )
      ''');
      
      // Copy existing profile data to users table (if any exists)
      await db.execute('''
        INSERT INTO users (name, email, password, notificationEnabled, themeMode, createdAt)
        SELECT name, email, COALESCE(password, ''), notificationEnabled, themeMode, datetime('now')
        FROM profile
        WHERE email IS NOT NULL AND email != ''
      ''');
      
      // Drop old profile table
      await db.execute('DROP TABLE IF EXISTS profile');
    }
  }
}