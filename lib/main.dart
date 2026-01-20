import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'supabase_config.dart';
import 'app.dart';
import 'services/auth_service.dart';
import 'services/product_service.dart';
import 'services/transaction_service.dart';
import 'controllers/auth_controller.dart';
import 'controllers/product_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  // Initialize Services
  Get.put(AuthService());
  Get.put(ProductService());
  Get.put(TransactionService());
  
  // Initialize Controllers
  Get.put(AuthController());
  Get.put(ProductController());
  
  runApp(const MyApp());
}
