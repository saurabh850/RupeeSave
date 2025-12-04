class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName; // e.g., 'star', 'fire'
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon_name': iconName,
      'is_unlocked': isUnlocked ? 1 : 0,
      'unlocked_at': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      iconName: map['icon_name'],
      isUnlocked: map['is_unlocked'] == 1,
      unlockedAt: map['unlocked_at'] != null ? DateTime.parse(map['unlocked_at']) : null,
    );
  }
}
