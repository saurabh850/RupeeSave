import 'package:sqflite/sqflite.dart';
import 'db_service.dart';
import '../models/achievement.dart';
import '../models/streak.dart';

class AchievementService {
  final DatabaseService _dbService = DatabaseService();

  // Predefined achievements
  final List<Achievement> _defaultAchievements = [
    Achievement(id: 'first_step', title: 'First Step', description: 'Log your first spend', iconName: 'footprint'),
    Achievement(id: 'week_warrior', title: 'Week Warrior', description: 'Reach a 7-day streak', iconName: 'calendar'),
    Achievement(id: 'month_master', title: 'Month Master', description: 'Reach a 30-day streak', iconName: 'crown'),
    Achievement(id: 'saver_squad', title: 'Saver Squad', description: 'Use a cushion to save a streak', iconName: 'shield'),
  ];

  Future<void> initAchievements() async {
    final db = await _dbService.database;
    
    // Ensure table exists (Web/Migration fallback)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS achievements(
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        icon_name TEXT,
        is_unlocked INTEGER,
        unlocked_at TEXT
      )
    ''');

    // Check if achievements exist, if not insert defaults
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM achievements'));
    if (count == 0) {
      for (var a in _defaultAchievements) {
        await db.insert('achievements', a.toMap());
      }
    }
  }

  Future<List<Achievement>> getAchievements() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query('achievements');
    return List.generate(maps.length, (i) => Achievement.fromMap(maps[i]));
  }

  Future<Achievement?> checkUnlock(String trigger, {dynamic value}) async {
    final db = await _dbService.database;
    String? achievementId;

    if (trigger == 'log_spend') {
      achievementId = 'first_step';
    } else if (trigger == 'streak') {
      final streak = value as int;
      if (streak >= 7) achievementId = 'week_warrior';
      if (streak >= 30) achievementId = 'month_master';
    } else if (trigger == 'use_cushion') {
      achievementId = 'saver_squad';
    }

    if (achievementId != null) {
      final maps = await db.query('achievements', where: 'id = ? AND is_unlocked = 0', whereArgs: [achievementId]);
      if (maps.isNotEmpty) {
        // Unlock it
        await db.update(
          'achievements',
          {'is_unlocked': 1, 'unlocked_at': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [achievementId],
        );
        return Achievement.fromMap((await db.query('achievements', where: 'id = ?', whereArgs: [achievementId])).first);
      }
    }
    return null;
  }
}
