class Streak {
  final int? id;
  final String type; // 'daily', 'weekly', 'monthly', 'yearly'
  final int current;
  final int longest;
  final DateTime? lastUpdated;

  Streak({
    this.id,
    required this.type,
    this.current = 0,
    this.longest = 0,
    this.lastUpdated,
  });

  factory Streak.fromMap(Map<String, dynamic> map) {
    return Streak(
      id: map['id'],
      type: map['type'],
      current: map['current'],
      longest: map['longest'],
      lastUpdated: map['last_updated'] != null
          ? DateTime.parse(map['last_updated'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'current': current,
      'longest': longest,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }
}
