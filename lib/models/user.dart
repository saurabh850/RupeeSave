class User {
  final int id;
  final String? name;
  final int baseDailyLimit;
  final String? limitPasswordHash;
  final int delayMinutes;
  final DateTime createdAt;
  final DateTime? lastBackupAt;

  User({
    this.id = 1,
    this.name,
    required this.baseDailyLimit,
    this.limitPasswordHash,
    this.delayMinutes = 30,
    required this.createdAt,
    this.lastBackupAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      baseDailyLimit: map['base_daily_limit'],
      limitPasswordHash: map['limit_password_hash'],
      delayMinutes: map['delay_minutes'],
      createdAt: DateTime.parse(map['created_at']),
      lastBackupAt: map['last_backup_at'] != null
          ? DateTime.parse(map['last_backup_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'base_daily_limit': baseDailyLimit,
      'limit_password_hash': limitPasswordHash,
      'delay_minutes': delayMinutes,
      'created_at': createdAt.toIso8601String(),
      'last_backup_at': lastBackupAt?.toIso8601String(),
    };
  }
}
