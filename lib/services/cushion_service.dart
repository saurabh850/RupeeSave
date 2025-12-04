import 'package:sqflite/sqflite.dart';
import 'db_service.dart';
import '../models/cushion.dart';

class CushionService {
  final DatabaseService _dbService = DatabaseService();

  Future<int> getAvailableCushions() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(points) as total FROM cushions 
      WHERE expires_at > ?
    ''', [DateTime.now().toIso8601String()]);

    return result.first['total'] as int? ?? 0;
  }

  Future<void> awardCushion() async {
    final db = await _dbService.database;
    final cushion = Cushion(
      points: 1,
      acquiredAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 365)),
    );

    await db.insert('cushions', cushion.toMap());
  }

  Future<bool> useCushion() async {
    final available = await getAvailableCushions();
    if (available <= 0) return false;

    final db = await _dbService.database;
    // Find oldest valid cushion
    final List<Map<String, dynamic>> cushions = await db.query(
      'cushions',
      where: 'points > 0 AND expires_at > ?',
      whereArgs: [DateTime.now().toIso8601String()],
      orderBy: 'acquired_at ASC',
      limit: 1,
    );

    if (cushions.isNotEmpty) {
      final cushion = Cushion.fromMap(cushions.first);
      await db.update(
        'cushions',
        {'points': cushion.points - 1},
        where: 'id = ?',
        whereArgs: [cushion.id],
      );
      return true;
    }
    return false;
  }
}
