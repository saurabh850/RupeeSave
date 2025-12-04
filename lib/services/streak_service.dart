import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'db_service.dart';
import '../models/streak.dart';
import '../models/day_log.dart';
import '../models/day_log.dart';
import 'cushion_service.dart';
import 'achievement_service.dart';
import '../screens/dialogs/milestone_dialog.dart';
import 'package:flutter/material.dart';

// Global key to access context for dialogs (hacky but works for MVP service-triggered UI)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class StreakService {
  final DatabaseService _dbService = DatabaseService();
  final CushionService _cushionService = CushionService();
  final AchievementService _achievementService = AchievementService();

  Future<Streak> getDailyStreak() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'streaks',
      where: 'type = ?',
      whereArgs: ['daily'],
    );

    if (maps.isNotEmpty) {
      return Streak.fromMap(maps.first);
    } else {
      // Initialize if not exists
      final newStreak = Streak(type: 'daily');
      await db.insert('streaks', newStreak.toMap());
      return newStreak;
    }
  }

  Future<void> updateDailyStreak(bool isGoodDay) async {
    final db = await _dbService.database;
    final streak = await getDailyStreak();
    
    int newCurrent = isGoodDay ? streak.current + 1 : 0;
    int newLongest = newCurrent > streak.longest ? newCurrent : streak.longest;

    await db.update(
      'streaks',
      {
        'current': newCurrent,
        'longest': newLongest,
        'last_updated': DateTime.now().toIso8601String(),
      },
      where: 'type = ?',
      whereArgs: ['daily'],
    );

    // Check for Cushion Award (every 7 days)
    if (isGoodDay && newCurrent > 0 && newCurrent % 7 == 0) {
      await _cushionService.awardCushion();
    }
  }

  Future<DayLog?> getTodayLog() async {
    final db = await _dbService.database;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    final List<Map<String, dynamic>> maps = await db.query(
      'day_log',
      where: 'date = ?',
      whereArgs: [today],
    );

    if (maps.isNotEmpty) {
      return DayLog.fromMap(maps.first);
    }
    return null;
  }

  Future<void> logSpend({
    required int amount,
    required int limit,
    String? justification,
  }) async {
    final db = await _dbService.database;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    final isGoodDay = amount <= limit;
    
    final log = DayLog(
      date: today,
      spent: amount,
      limitApplied: limit,
      status: isGoodDay ? 'good' : 'bad',
      justification: justification,
      createdAt: DateTime.now(),
    );

    await db.insert(
      'day_log',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await updateDailyStreak(isGoodDay);
    
    // Check Achievements
    final achievement = await _achievementService.checkUnlock('log_spend');
    if (achievement != null) {
      _showMilestone(achievement);
    }
  }

  void _showMilestone(achievement) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        builder: (_) => MilestoneDialog(
          title: achievement.title,
          message: achievement.description,
          iconName: achievement.iconName,
        ),
      );
    }
  }
  Future<Map<DateTime, int>> getAllLogs() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query('day_log');
    
    final Map<DateTime, int> dataset = {};
    for (var map in maps) {
      final date = DateTime.parse(map['date']);
      final status = map['status'];
      // 1 = Good (Green), 2 = Bad (Red)
      dataset[DateTime(date.year, date.month, date.day)] = status == 'good' ? 1 : 2;
    }
    return dataset;
  }

  Future<List<DayLog>> getWeeklySummary() async {
    final db = await _dbService.database;
    final today = DateTime.now();
    final sevenDaysAgo = today.subtract(const Duration(days: 7));
    final startDate = DateFormat('yyyy-MM-dd').format(sevenDaysAgo);
    
    final List<Map<String, dynamic>> maps = await db.query(
      'day_log',
      where: 'date >= ?',
      whereArgs: [startDate],
      orderBy: 'date ASC',
    );
    
    return List.generate(maps.length, (i) => DayLog.fromMap(maps[i]));
  }
}
