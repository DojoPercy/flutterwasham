class WashAmBag {
  final String id;
  final String category;
  final String name;
  final String description;
  final double unitPrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  WashAmBag({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.unitPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WashAmBag.fromJson(Map<String, dynamic> json) {
    return WashAmBag(
      id: json['id'],
      category: json['category'],
      name: json['name'],
      description: json['description'],
      unitPrice: json['unitPrice'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
