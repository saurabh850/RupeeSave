import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'db_service.dart';

class BackupService {
  final DatabaseService _dbService = DatabaseService();

  Future<String> exportData() async {
    final db = await _dbService.database;
    
    // Fetch all data
    final user = await db.query('user');
    final logs = await db.query('day_log');
    final streaks = await db.query('streaks');
    final cushions = await db.query('cushions');
    final wishlist = await db.query('wishlist');

    final data = {
      'version': 1,
      'timestamp': DateTime.now().toIso8601String(),
      'user': user,
      'day_log': logs,
      'streaks': streaks,
      'cushions': cushions,
      'wishlist': wishlist,
    };

    final jsonString = jsonEncode(data);
    
    // For Web/Desktop, we might want to save to a file
    // Simple implementation: Return JSON string to show or copy
    return jsonString;
  }

  Future<void> importData(String jsonString) async {
    try {
      final data = jsonDecode(jsonString);
      final db = await _dbService.database;

      await db.transaction((txn) async {
        // Clear existing data
        await txn.delete('user');
        await txn.delete('day_log');
        await txn.delete('streaks');
        await txn.delete('cushions');
        await txn.delete('wishlist');

        // Insert new data
        for (var item in (data['user'] as List)) {
          await txn.insert('user', item);
        }
        for (var item in (data['day_log'] as List)) {
          await txn.insert('day_log', item);
        }
        for (var item in (data['streaks'] as List)) {
          await txn.insert('streaks', item);
        }
        for (var item in (data['cushions'] as List)) {
          await txn.insert('cushions', item);
        }
        for (var item in (data['wishlist'] as List)) {
          await txn.insert('wishlist', item);
        }
      });
    } catch (e) {
      throw Exception('Invalid backup file');
    }
  }
}
