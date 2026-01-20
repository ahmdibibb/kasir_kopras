import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../utils/constants.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductController _productController = Get.find<ProductController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _productController.setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    _productController.setSearchQuery(value);
                  },
                ),
              ),
              
              // Category Filter
              Obx(() => SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingM,
                      ),
                      children: [
                        _buildCategoryChip('Semua'),
                        ...AppConstants.defaultCategories.map(
                          (category) => _buildCategoryChip(category),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: AppTheme.spacingM),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (_productController.filteredProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Belum ada produk',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  'Tap tombol + untuk menambah produk',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: AppTheme.spacingM,
            mainAxisSpacing: AppTheme.spacingM,
          ),
          itemCount: _productController.filteredProducts.length,
          itemBuilder: (context, index) {
            final product = _productController.filteredProducts[index];
            return _buildProductCard(product);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const ProductFormScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Obx(() {
      final isSelected = _productController.selectedCategory.value == category;
      return Padding(
        padding: const EdgeInsets.only(right: AppTheme.spacingS),
        child: FilterChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            _productController.setCategory(category);
          },
          selectedColor: AppTheme.primaryColor.withOpacity(0.2),
          checkmarkColor: AppTheme.primaryColor,
        ),
      );
    });
  }

  Widget _buildProductCard(product) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Get.to(() => ProductFormScreen(product: product));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            AspectRatio(
              aspectRatio: 1,
              child: product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage();
                      },
                    )
                  : _buildPlaceholderImage(),
            ),
            
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  
                  // Price
                  Text(
                    Formatters.currency(product.price),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  
                  // Stock
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 14,
                        color: product.isLowStock
                            ? AppTheme.errorColor
                            : AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: AppTheme.spacingXS),
                      Text(
                        'Stok: ${product.stock}',
                        style: TextStyle(
                          fontSize: 12,
                          color: product.isLowStock
                              ? AppTheme.errorColor
                              : AppTheme.textSecondaryColor,
                          fontWeight: product.isLowStock
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppTheme.backgroundColor,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: AppTheme.textSecondaryColor,
        ),
      ),
    );
  }
}
