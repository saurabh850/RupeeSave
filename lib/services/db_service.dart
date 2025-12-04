import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    if (kIsWeb) {
      var factory = databaseFactoryFfiWeb;
      return await factory.openDatabase('rupeesave.db', options: OpenDatabaseOptions(
        version: 3,
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
      ));
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'rupeesave.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE achievements(
          id TEXT PRIMARY KEY,
          title TEXT,
          description TEXT,
          icon_name TEXT,
          is_unlocked INTEGER,
          unlocked_at TEXT
        )
      ''');
    }
    if (oldVersion < 3) {
      // Add currency column to user table
      await db.execute('ALTER TABLE user ADD COLUMN currency TEXT DEFAULT "INR"');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // User Settings
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        name TEXT,
        base_daily_limit INTEGER NOT NULL,
        limit_password_hash TEXT,
        delay_minutes INTEGER DEFAULT 30,
        currency TEXT DEFAULT "INR",
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        last_backup_at DATETIME
      )
    ''');

    // Daily Log
    await db.execute('''
      CREATE TABLE day_log (
        date TEXT PRIMARY KEY,
        spent INTEGER DEFAULT 0,
        limit_applied INTEGER,
        status TEXT,
        justification TEXT,
        cushions_used INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME
      )
    ''');

    // Streaks
    await db.execute('''
      CREATE TABLE streaks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        current INTEGER DEFAULT 0,
        longest INTEGER DEFAULT 0,
        last_updated DATE
      )
    ''');

    // Cushions
    await db.execute('''
      CREATE TABLE cushions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        points INTEGER DEFAULT 0,
        acquired_at DATE,
        expires_at DATE
      )
    ''');

    // Wishlist
    await db.execute('''
      CREATE TABLE wishlist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        est_price INTEGER,
        created_at DATETIME,
        planned BOOLEAN DEFAULT 0,
        purchased_date DATE
      )
    ''');

    // Audit Log
    await db.execute('''
      CREATE TABLE audit (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action TEXT,
        details TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<void> resetDatabase() async {
    final db = await _instance.database;
    await db.delete('user');
    await db.delete('day_log');
    await db.delete('streaks');
    await db.delete('cushions');
    await db.delete('wishlist');
    await db.delete('audit');
    await db.delete('achievements');
    // Re-create default user logic will be handled by onboarding check
  }

  Future<void> close() async {
    final db = await _instance.database;
    db.close();
  }
}
