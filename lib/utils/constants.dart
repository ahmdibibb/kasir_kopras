class AppConstants {
  // App Info
  static const String appName = 'Kasir Kopras';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String transactionsCollection = 'transactions';
  static const String categoriesCollection = 'categories';
  
  // Payment Methods
  static const String paymentCash = 'cash';
  static const String paymentCard = 'card';
  static const String paymentEWallet = 'e-wallet';
  
  // Transaction Status
  static const String statusCompleted = 'completed';
  static const String statusPending = 'pending';
  static const String statusCancelled = 'cancelled';
  
  // Default Categories
  static const List<String> defaultCategories = [
    'Makanan',
    'Minuman',
    'Snack',
    'Lainnya',
  ];
  
  // Notification Topics
  static const String lowStockTopic = 'low_stock';
  static const String pendingTransactionTopic = 'pending_transaction';
  
  // Low Stock Threshold
  static const int lowStockThreshold = 10;
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
}
