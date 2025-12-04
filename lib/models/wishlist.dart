class WishlistItem {
  final int? id;
  final String title;
  final int estPrice;
  final DateTime createdAt;
  final bool planned;
  final DateTime? purchasedDate;

  WishlistItem({
    this.id,
    required this.title,
    required this.estPrice,
    required this.createdAt,
    this.planned = false,
    this.purchasedDate,
  });

  factory WishlistItem.fromMap(Map<String, dynamic> map) {
    return WishlistItem(
      id: map['id'],
      title: map['title'],
      estPrice: map['est_price'],
      createdAt: DateTime.parse(map['created_at']),
      planned: map['planned'] == 1,
      purchasedDate: map['purchased_date'] != null
          ? DateTime.parse(map['purchased_date'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'est_price': estPrice,
      'created_at': createdAt.toIso8601String(),
      'planned': planned ? 1 : 0,
      'purchased_date': purchasedDate?.toIso8601String(),
    };
  }
}
