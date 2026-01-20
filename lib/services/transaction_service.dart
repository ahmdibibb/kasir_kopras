import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../models/transaction.dart';
import '../models/product.dart';
import '../supabase_config.dart';
import 'auth_service.dart';
import 'product_service.dart';

class TransactionService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();
  final ProductService _productService = Get.find<ProductService>();

  // Get transactions stream for current user
  Stream<List<Transaction>> getTransactionsStream() {
    final userId = _authService.currentUserId;
    if (userId == null) return Stream.value([]);

    return supabase
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) {
          return data.map((item) => Transaction.fromSupabase(item)).toList();
        });
  }

  // Get single transaction
  Future<Transaction?> getTransaction(String transactionId) async {
    try {
      final data = await supabase
          .from('transactions')
          .select()
          .eq('id', transactionId)
          .single();

      return Transaction.fromSupabase(data);
    } catch (e) {
      throw Exception('Gagal mengambil transaksi: ${e.toString()}');
    }
  }

  // Create transaction
  Future<String> createTransaction({
    required List<TransactionItem> items,
    required double totalAmount,
    required PaymentMethod paymentMethod,
    required double amountPaid,
  }) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) throw Exception('User tidak terautentikasi');

      final change = amountPaid - totalAmount;

      // Convert items to JSON
      final itemsJson = items.map((item) => item.toMap()).toList();

      final transactionData = {
        'items': itemsJson,
        'total_amount': totalAmount,
        'payment_method': paymentMethod.name,
        'amount_paid': amountPaid,
        'change': change,
        'status': TransactionStatus.completed.name,
        'user_id': userId,
      };

      // Insert transaction
      final response = await supabase
          .from('transactions')
          .insert(transactionData)
          .select()
          .single();

      // Update stock for each product
      for (var item in items) {
        final product = await _productService.getProduct(item.productId);
        if (product != null) {
          final newStock = product.stock - item.quantity;
          await _productService.updateStock(item.productId, newStock);
        }
      }

      return response['id'] as String;
    } catch (e) {
      throw Exception('Gagal membuat transaksi: ${e.toString()}');
    }
  }

  // Update transaction
  Future<void> updateTransaction({
    required String transactionId,
    required TransactionStatus status,
  }) async {
    try {
      await supabase
          .from('transactions')
          .update({'status': status.name}).eq('id', transactionId);
    } catch (e) {
      throw Exception('Gagal update transaksi: ${e.toString()}');
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await supabase.from('transactions').delete().eq('id', transactionId);
    } catch (e) {
      throw Exception('Gagal menghapus transaksi: ${e.toString()}');
    }
  }

  // Get transactions by date range
  Future<List<Transaction>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) return [];

      final data = await supabase
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: false);

      return data
          .map<Transaction>((item) => Transaction.fromSupabase(item))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil transaksi: ${e.toString()}');
    }
  }

  // Get transactions by payment method
  Stream<List<Transaction>> getTransactionsByPaymentMethod(
      PaymentMethod paymentMethod) {
    final userId = _authService.currentUserId;
    if (userId == null) return Stream.value([]);

    return supabase
        .from('transactions')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {
          return data
              .where((item) {
                final currentUserId = _authService.currentUserId;
                if (currentUserId == null) return false;
                return item['user_id'] == currentUserId &&
                    item['payment_method'] == paymentMethod.name;
              })
              .map((item) => Transaction.fromSupabase(item))
              .toList();
        });
  }

  // Get today's transactions
  Stream<List<Transaction>> getTodayTransactions() {
    final userId = _authService.currentUserId;
    if (userId == null) return Stream.value([]);

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return supabase
        .from('transactions')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {
          return data
              .where((item) {
                final currentUserId = _authService.currentUserId;
                if (currentUserId == null) return false;
                final createdAt = DateTime.parse(item['created_at']);
                return item['user_id'] == currentUserId &&
                    createdAt.isAfter(startOfDay);
              })
              .map((item) => Transaction.fromSupabase(item))
              .toList();
        });
  }

  // Calculate total sales for a period
  Future<double> calculateTotalSales({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final transactions = await getTransactionsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );

      double total = 0.0;
      for (var transaction in transactions) {
        if (transaction.status == TransactionStatus.completed) {
          total += transaction.totalAmount;
        }
      }
      return total;
    } catch (e) {
      throw Exception('Gagal menghitung total penjualan: ${e.toString()}');
    }
  }

  // Get transaction statistics
  Future<Map<String, dynamic>> getTransactionStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final transactions = await getTransactionsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );

      final completedTransactions = transactions
          .where((t) => t.status == TransactionStatus.completed)
          .toList();

      final totalSales = completedTransactions.fold(
          0.0, (sum, transaction) => sum + transaction.totalAmount);

      final totalTransactions = completedTransactions.length;

      final totalItems = completedTransactions.fold(
          0, (sum, transaction) => sum + transaction.totalItems);

      final averageTransaction =
          totalTransactions > 0 ? totalSales / totalTransactions : 0.0;

      // Payment method breakdown
      final cashTransactions = completedTransactions
          .where((t) => t.paymentMethod == PaymentMethod.cash)
          .length;
      final cardTransactions = completedTransactions
          .where((t) => t.paymentMethod == PaymentMethod.card)
          .length;
      final eWalletTransactions = completedTransactions
          .where((t) => t.paymentMethod == PaymentMethod.eWallet)
          .length;

      return {
        'totalSales': totalSales,
        'totalTransactions': totalTransactions,
        'totalItems': totalItems,
        'averageTransaction': averageTransaction,
        'cashTransactions': cashTransactions,
        'cardTransactions': cardTransactions,
        'eWalletTransactions': eWalletTransactions,
      };
    } catch (e) {
      throw Exception('Gagal mengambil statistik: ${e.toString()}');
    }
  }
}
