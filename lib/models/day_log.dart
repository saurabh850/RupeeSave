class DayLog {
  final String date; // YYYY-MM-DD
  final int spent;
  final int? limitApplied;
  final String status; // 'good', 'bad', 'planned', 'not_logged'
  final String? justification;
  final int cushionsUsed;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DayLog({
    required this.date,
    this.spent = 0,
    this.limitApplied,
    required this.status,
    this.justification,
    this.cushionsUsed = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory DayLog.fromMap(Map<String, dynamic> map) {
    return DayLog(
      date: map['date'],
      spent: map['spent'],
      limitApplied: map['limit_applied'],
      status: map['status'],
      justification: map['justification'],
      cushionsUsed: map['cushions_used'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'spent': spent,
      'limit_applied': limitApplied,
      'status': status,
      'justification': justification,
      'cushions_used': cushionsUsed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
