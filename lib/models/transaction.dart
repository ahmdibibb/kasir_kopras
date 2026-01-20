enum PaymentMethod {
  cash('Cash'),
  card('Kartu'),
  eWallet('E-Wallet');

  final String label;
  const PaymentMethod(this.label);
}

enum TransactionStatus {
  completed('Selesai'),
  pending('Pending'),
  cancelled('Dibatalkan');

  final String label;
  const TransactionStatus(this.label);
}

class TransactionItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double subtotal;

  TransactionItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
    );
  }
}

class Transaction {
  final String id;
  final List<TransactionItem> items;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final double amountPaid;
  final double change;
  final TransactionStatus status;
  final DateTime createdAt;
  final String userId;

  Transaction({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.amountPaid,
    required this.change,
    required this.status,
    required this.createdAt,
    required this.userId,
  });

  // Get total items count
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod.name,
      'amountPaid': amountPaid,
      'change': change,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }

  // Create from Firestore Document
  factory Transaction.fromMap(Map<String, dynamic> map, String id) {
    return Transaction(
      id: id,
      items: (map['items'] as List<dynamic>)
          .map((item) => TransactionItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == map['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      amountPaid: (map['amountPaid'] ?? 0).toDouble(),
      change: (map['change'] ?? 0).toDouble(),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TransactionStatus.completed,
      ),
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      userId: map['userId'] ?? '',
    );
  }

  // Create from Supabase Map
  factory Transaction.fromSupabase(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      items: (map['items'] as List<dynamic>)
          .map((item) => TransactionItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (map['total_amount'] ?? 0).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == map['payment_method'],
        orElse: () => PaymentMethod.cash,
      ),
      amountPaid: (map['amount_paid'] ?? 0).toDouble(),
      change: (map['change'] ?? 0).toDouble(),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TransactionStatus.completed,
      ),
      createdAt: DateTime.parse(map['created_at']),
      userId: map['user_id'] ?? '',
    );
  }

  // CopyWith method
  Transaction copyWith({
    String? id,
    List<TransactionItem>? items,
    double? totalAmount,
    PaymentMethod? paymentMethod,
    double? amountPaid,
    double? change,
    TransactionStatus? status,
    DateTime? createdAt,
    String? userId,
  }) {
    return Transaction(
      id: id ?? this.id,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountPaid: amountPaid ?? this.amountPaid,
      change: change ?? this.change,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}
