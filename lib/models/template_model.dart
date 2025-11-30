class TemplateModel {
  final String id;
  final String name;
  final String description;
  final String type; // 'arco', 'columna', 'centro'
  final double basePrice;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;

  TemplateModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.basePrice,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory TemplateModel.fromMap(Map<String, dynamic> map, String id) {
    return TemplateModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? '',
      basePrice: (map['basePrice'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'],
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'type': type,
      'basePrice': basePrice,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }
}

