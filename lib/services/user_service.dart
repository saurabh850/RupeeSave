import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import 'db_service.dart';

class UserService {
  final DatabaseService _dbService = DatabaseService();

  Future<User?> getUser() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<void> createUser({
    required int baseDailyLimit,
    required String password,
    String? name,
  }) async {
    final db = await _dbService.database;
    final passwordHash = _hashPassword(password);

    final user = User(
      id: 1,
      name: name,
      baseDailyLimit: baseDailyLimit,
      limitPasswordHash: passwordHash,
      createdAt: DateTime.now(),
    );

    await db.insert(
      'user',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> verifyPassword(String password) async {
    final user = await getUser();
    if (user == null || user.limitPasswordHash == null) return false;
    
    final hash = _hashPassword(password);
    return hash == user.limitPasswordHash;
  }

  Future<void> updateLimit(int newLimit) async {
    final db = await _dbService.database;
    await db.update(
      'user',
      {'base_daily_limit': newLimit},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
