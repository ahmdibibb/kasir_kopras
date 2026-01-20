import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/product_controller.dart';
import '../../models/product.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ProductController _productController = Get.find<ProductController>();
  
  String _selectedCategory = AppConstants.defaultCategories[0];
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
      _descriptionController.text = widget.product!.description ?? '';
      _selectedCategory = widget.product!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final price = double.parse(_priceController.text);
      final stock = int.parse(_stockController.text);
      final description = _descriptionController.text.trim();

      bool success;
      if (isEditing) {
        success = await _productController.updateProduct(
          productId: widget.product!.id,
          name: name,
          price: price,
          category: _selectedCategory,
          stock: stock,
          description: description.isEmpty ? null : description,
          imageFile: _imageFile,
          existingImageUrl: widget.product!.imageUrl,
        );
      } else {
        success = await _productController.addProduct(
          name: name,
          price: price,
          category: _selectedCategory,
          stock: stock,
          description: description.isEmpty ? null : description,
          imageFile: _imageFile,
        );
      }

      if (success && mounted) {
        Get.back();
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _productController.deleteProduct(
        widget.product!.id,
        widget.product!.imageUrl,
      );
      if (success && mounted) {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Produk' : 'Tambah Produk'),
        actions: isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _handleDelete,
                ),
              ]
            : null,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            // Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  border: Border.all(color: AppTheme.textHintColor),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : (isEditing && widget.product!.imageUrl != null)
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusM),
                            child: Image.network(
                              widget.product!.imageUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 48,
                                color: AppTheme.textSecondaryColor,
                              ),
                              const SizedBox(height: AppTheme.spacingS),
                              Text(
                                'Tap untuk menambah foto',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Produk *',
                prefixIcon: Icon(Icons.shopping_bag_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama produk tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategori *',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: AppConstants.defaultCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Price Field
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Harga *',
                prefixIcon: Icon(Icons.attach_money),
                prefixText: 'Rp ',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Harga tidak boleh kosong';
                }
                if (double.tryParse(value) == null) {
                  return 'Harga tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Stock Field
            TextFormField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Stok *',
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Stok tidak boleh kosong';
                }
                if (int.tryParse(value) == null) {
                  return 'Stok tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Deskripsi (Opsional)',
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),

            // Submit Button
            Obx(() => ElevatedButton(
                  onPressed: _productController.isLoading.value
                      ? null
                      : _handleSubmit,
                  child: _productController.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isEditing ? 'Update Produk' : 'Tambah Produk'),
                )),
          ],
        ),
      ),
    );
  }
}
