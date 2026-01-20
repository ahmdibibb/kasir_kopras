import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../models/product.dart';
import '../../models/transaction.dart';
import '../../services/product_service.dart';
import '../../services/transaction_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final ProductService _productService = Get.find<ProductService>();
  final TransactionService _transactionService = Get.find<TransactionService>();
  
  final Map<String, int> _cart = {}; // productId -> quantity
  final Map<String, Product> _products = {}; // productId -> Product
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  final TextEditingController _amountPaidController = TextEditingController();
  bool _isProcessing = false;

  double get _totalAmount {
    double total = 0;
    _cart.forEach((productId, quantity) {
      final product = _products[productId];
      if (product != null) {
        total += product.price * quantity;
      }
    });
    return total;
  }

  double get _change {
    final amountPaid = double.tryParse(_amountPaidController.text) ?? 0;
    return amountPaid - _totalAmount;
  }

  @override
  void dispose() {
    _amountPaidController.dispose();
    super.dispose();
  }

  void _addToCart(Product product) {
    setState(() {
      _products[product.id] = product;
      _cart[product.id] = (_cart[product.id] ?? 0) + 1;
    });
  }

  void _removeFromCart(String productId) {
    setState(() {
      if (_cart[productId] != null) {
        if (_cart[productId]! > 1) {
          _cart[productId] = _cart[productId]! - 1;
        } else {
          _cart.remove(productId);
          _products.remove(productId);
        }
      }
    });
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
      _products.clear();
      _amountPaidController.clear();
    });
  }

  Future<void> _processTransaction() async {
    if (_cart.isEmpty) {
      Get.snackbar('Error', 'Keranjang masih kosong');
      return;
    }

    final amountPaid = double.tryParse(_amountPaidController.text) ?? 0;
    if (amountPaid < _totalAmount) {
      Get.snackbar('Error', 'Jumlah bayar kurang dari total');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create transaction items
      final items = _cart.entries.map((entry) {
        final product = _products[entry.key]!;
        return TransactionItem(
          productId: product.id,
          productName: product.name,
          quantity: entry.value,
          price: product.price,
          subtotal: product.price * entry.value,
        );
      }).toList();

      // Create transaction
      await _transactionService.createTransaction(
        items: items,
        totalAmount: _totalAmount,
        paymentMethod: _selectedPaymentMethod,
        amountPaid: amountPaid,
      );

      Get.snackbar(
        'Berhasil',
        'Transaksi berhasil diproses',
        snackPosition: SnackPosition.BOTTOM,
      );

      _clearCart();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penjualan'),
        actions: [
          if (_cart.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Hapus Keranjang'),
                    content: const Text(
                        'Apakah Anda yakin ingin menghapus semua item?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _clearCart();
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                        ),
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Product Selection
          Expanded(
            flex: 2,
            child: _buildProductSelection(),
          ),
          
          // Cart
          Expanded(
            flex: 3,
            child: _buildCart(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSelection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.textHintColor.withOpacity(0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Text(
              'Pilih Produk',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _productService.getProductsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Belum ada produk'),
                  );
                }

                final products = snapshot.data!;

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductItem(product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    return Card(
      margin: const EdgeInsets.only(
        right: AppTheme.spacingM,
        bottom: AppTheme.spacingS,
      ),
      child: InkWell(
        onTap: product.stock > 0 ? () => _addToCart(product) : null,
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(AppTheme.spacingS),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        ),
                        child: const Center(
                          child: Icon(Icons.image_outlined),
                        ),
                      ),
              ),
              const SizedBox(height: AppTheme.spacingXS),
              Text(
                product.name,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                Formatters.currency(product.price),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Stok: ${product.stock}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: product.stock > 0
                          ? AppTheme.textSecondaryColor
                          : AppTheme.errorColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCart() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Cart Items
          Expanded(
            child: _cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        Text(
                          'Keranjang kosong',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final productId = _cart.keys.elementAt(index);
                      final product = _products[productId]!;
                      final quantity = _cart[productId]!;
                      final subtotal = product.price * quantity;

                      return Card(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingS),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    Text(
                                      Formatters.currency(product.price),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () => _removeFromCart(productId),
                                    color: AppTheme.errorColor,
                                  ),
                                  Text(
                                    '$quantity',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: quantity < product.stock
                                        ? () => _addToCart(product)
                                        : null,
                                    color: AppTheme.primaryColor,
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  Formatters.currency(subtotal),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Payment Section
          if (_cart.isNotEmpty) _buildPaymentSection(),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                Formatters.currency(_totalAmount),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Payment Method
          DropdownButtonFormField<PaymentMethod>(
            value: _selectedPaymentMethod,
            decoration: const InputDecoration(
              labelText: 'Metode Pembayaran',
              prefixIcon: Icon(Icons.payment),
            ),
            items: PaymentMethod.values.map((method) {
              return DropdownMenuItem(
                value: method,
                child: Text(method.label),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Amount Paid
          TextFormField(
            controller: _amountPaidController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Jumlah Bayar',
              prefixIcon: Icon(Icons.money),
              prefixText: 'Rp ',
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          
          // Change
          if (_amountPaidController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppTheme.spacingM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kembalian',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    Formatters.currency(_change >= 0 ? _change : 0),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: _change >= 0
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Process Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processTransaction,
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Proses Transaksi'),
            ),
          ),
        ],
      ),
    );
  }
}
