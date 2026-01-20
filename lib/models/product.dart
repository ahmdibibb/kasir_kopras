class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final int stock;
  final String? imageUrl;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
    this.imageUrl,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  // Check if stock is low
  bool get isLowStock => stock <= 10;

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'stock': stock,
      'imageUrl': imageUrl,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
    };
  }

  // Create from Firestore Document
  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      stock: map['stock'] ?? 0,
      imageUrl: map['imageUrl'],
      description: map['description'],
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] is String
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      userId: map['userId'] ?? '',
    );
  }

  // Create from Supabase Map
  factory Product.fromSupabase(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      stock: map['stock'] ?? 0,
      imageUrl: map['image_url'],
      description: map['description'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      userId: map['user_id'] ?? '',
    );
  }

  // CopyWith method
  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? category,
    int? stock,
    String? imageUrl,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }
}
