import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/product.dart';
import '../utils/constants.dart';
import '../supabase_config.dart';
import 'auth_service.dart';

class ProductService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();

  // Get products stream for current user
  Stream<List<Product>> getProductsStream() {
    final userId = _authService.currentUserId;
    if (userId == null) return Stream.value([]);

    return supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) {
          return data.map((item) => Product.fromSupabase(item)).toList();
        });
  }

  // Get single product
  Future<Product?> getProduct(String productId) async {
    try {
      final data =
          await supabase.from('products').select().eq('id', productId).single();

      return Product.fromSupabase(data);
    } catch (e) {
      throw Exception('Gagal mengambil produk: ${e.toString()}');
    }
  }

  // Add product
  Future<String> addProduct({
    required String name,
    required double price,
    required String category,
    required int stock,
    String? description,
    File? imageFile,
    Uint8List? webImage,
  }) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) throw Exception('User tidak terautentikasi');

      String? imageUrl;

      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile: imageFile);
      } else if (webImage != null) {
        imageUrl = await _uploadImage(webImage: webImage);
      }

      final productData = {
        'name': name,
        'price': price,
        'category': category,
        'stock': stock,
        'description': description,
        'image_url': imageUrl,
        'user_id': userId,
      };

      final response =
          await supabase.from('products').insert(productData).select().single();

      return response['id'] as String;
    } catch (e) {
      throw Exception('Gagal menambah produk: ${e.toString()}');
    }
  }

  // Update product
  Future<void> updateProduct({
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
      String? imageUrl = existingImageUrl;

      // Upload new image if provided
      if (imageFile != null) {
        // Delete old image if exists
        if (existingImageUrl != null) {
          await _deleteImage(existingImageUrl);
        }
        imageUrl = await _uploadImage(imageFile: imageFile);
      }

      final updateData = {
        'name': name,
        'price': price,
        'category': category,
        'stock': stock,
        'description': description,
        'image_url': imageUrl,
      };

      await supabase.from('products').update(updateData).eq('id', productId);
    } catch (e) {
      throw Exception('Gagal update produk: ${e.toString()}');
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId, String? imageUrl) async {
    try {
      // Delete image if exists
      if (imageUrl != null) {
        await _deleteImage(imageUrl);
      }

      // Delete product
      await supabase.from('products').delete().eq('id', productId);
    } catch (e) {
      throw Exception('Gagal menghapus produk: ${e.toString()}');
    }
  }

  // Update stock
  Future<void> updateStock(String productId, int newStock) async {
    try {
      await supabase
          .from('products')
          .update({'stock': newStock}).eq('id', productId);
    } catch (e) {
      throw Exception('Gagal update stok: ${e.toString()}');
    }
  }

  // Search products
  Future<List<Product>> searchProducts(String query) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) return [];

      final data = await supabase
          .from('products')
          .select()
          .eq('user_id', userId)
          .ilike('name', '%$query%');

      return data.map<Product>((item) => Product.fromSupabase(item)).toList();
    } catch (e) {
      throw Exception('Gagal mencari produk: ${e.toString()}');
    }
  }

  // Get products by category
  Stream<List<Product>> getProductsByCategory(String category) {
    final userId = _authService.currentUserId;
    if (userId == null) return Stream.value([]);

    return supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {
          return data
              .where((item) {
                final currentUserId = _authService.currentUserId;
                if (currentUserId == null) return false;
                return item['user_id'] == currentUserId &&
                    item['category'] == category;
              })
              .map((item) => Product.fromSupabase(item))
              .toList();
        });
  }

  // Get low stock products
  Stream<List<Product>> getLowStockProducts() {
    final userId = _authService.currentUserId;
    if (userId == null) return Stream.value([]);

    return supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {
          return data
              .where((item) {
                final currentUserId = _authService.currentUserId;
                if (currentUserId == null) return false;
                return item['user_id'] == currentUserId &&
                    (item['stock'] ?? 0) <= AppConstants.lowStockThreshold;
              })
              .map((item) => Product.fromSupabase(item))
              .toList();
        });
  }

  // Upload image to Supabase Storage
  Future<String> _uploadImage({File? imageFile, Uint8List? webImage}) async {
    try {
      final userId = _authService.currentUserId;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$userId/$fileName';

      if (imageFile != null) {
        // Mobile: upload File
        await supabase.storage
            .from('product-images')
            .upload(filePath, imageFile);
      } else if (webImage != null) {
        // Web: upload Uint8List
        await supabase.storage
            .from('product-images')
            .uploadBinary(filePath, webImage);
      } else {
        throw Exception('No image provided');
      }

      final publicUrl =
          supabase.storage.from('product-images').getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Gagal upload gambar: ${e.toString()}');
    }
  }

  // Delete image from Supabase Storage
  Future<void> _deleteImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Find 'product-images' index and get path after it
      final bucketIndex = pathSegments.indexOf('product-images');
      if (bucketIndex == -1) return;

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      await supabase.storage.from('product-images').remove([filePath]);
    } catch (e) {
      // Ignore error if image doesn't exist
      print('Error deleting image: $e');
    }
  }
}
