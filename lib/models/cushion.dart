class Cushion {
  final int? id;
  final int points;
  final DateTime acquiredAt;
  final DateTime expiresAt;

  Cushion({
    this.id,
    this.points = 0,
    required this.acquiredAt,
    required this.expiresAt,
  });

  factory Cushion.fromMap(Map<String, dynamic> map) {
    return Cushion(
      id: map['id'],
      points: map['points'],
      acquiredAt: DateTime.parse(map['acquired_at']),
      expiresAt: DateTime.parse(map['expires_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'points': points,
      'acquired_at': acquiredAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }
}
