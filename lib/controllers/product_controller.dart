import 'package:get/get.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();

  final RxList<Product> products = <Product>[].obs;
  final RxList<Product> filteredProducts = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'Semua'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProducts();
  }

  void _loadProducts() {
    _productService.getProductsStream().listen((productList) {
      products.value = productList;
      _filterProducts();
    });
  }

  void _filterProducts() {
    var filtered = products.toList();

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered
          .where((product) => product.name
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    // Filter by category
    if (selectedCategory.value != 'Semua') {
      filtered = filtered
          .where((product) => product.category == selectedCategory.value)
          .toList();
    }

    filteredProducts.value = filtered;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    _filterProducts();
  }

  void setCategory(String category) {
    selectedCategory.value = category;
    _filterProducts();
  }

  Future<bool> addProduct({
    required String name,
    required double price,
    required String category,
    required int stock,
    String? description,
    File? imageFile,
    Uint8List? webImage,
  }) async {
    try {
      isLoading.value = true;

      await _productService.addProduct(
        name: name,
        price: price,
        category: category,
        stock: stock,
        description: description,
        imageFile: imageFile,
        webImage: webImage,
      );

      Get.snackbar(
        'Berhasil',
        'Produk berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProduct({
    required String productId,
    required String name,
    required double price,
    required String category,
    required int stock,
    String? description,
    File? imageFile,
    String? existingImageUrl,
  }) async {
    try {
      isLoading.value = true;

      await _productService.updateProduct(
        productId: productId,
        name: name,
        price: price,
        category: category,
        stock: stock,
        description: description,
        imageFile: imageFile,
        existingImageUrl: existingImageUrl,
      );

      Get.snackbar(
        'Berhasil',
        'Produk berhasil diupdate',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteProduct(String productId, String? imageUrl) async {
    try {
      isLoading.value = true;

      await _productService.deleteProduct(productId, imageUrl);

      Get.snackbar(
        'Berhasil',
        'Produk berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStock(String productId, int newStock) async {
    try {
      await _productService.updateStock(productId, newStock);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
