# Supabase Setup Guide

## 1. Buat Supabase Project

1. Buka [supabase.com](https://supabase.com)
2. Klik **"Start your project"** atau **"New Project"**
3. Login dengan GitHub (atau buat akun baru - **GRATIS, tanpa kartu kredit**)
4. Klik **"New Project"**
5. Isi detail project:
   - **Name:** Kasir Kopras
   - **Database Password:** Buat password yang kuat (simpan baik-baik!)
   - **Region:** Singapore (terdekat untuk Indonesia)
   - **Pricing Plan:** Free (sudah terpilih otomatis)
6. Klik **"Create new project"**
7. Tunggu ~2 menit sampai project siap

## 2. Dapatkan API Credentials

Setelah project siap:

1. Di dashboard Supabase, klik **Settings** (icon gear) di sidebar kiri
2. Klik **API** di menu settings
3. Anda akan melihat:
   - **Project URL:** `https://xxxxx.supabase.co`
   - **anon public key:** `eyJhbGc...` (key panjang)

**SIMPAN kedua nilai ini!** Anda akan membutuhkannya nanti.

## 3. Setup Database Tables

### Buat Tables via SQL Editor

1. Di dashboard Supabase, klik **SQL Editor** di sidebar kiri
2. Klik **"New query"**
3. Copy-paste SQL berikut dan klik **"Run"**:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (otomatis dibuat oleh Supabase Auth)
-- Kita hanya perlu table tambahan untuk profile

-- Products table
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  category TEXT NOT NULL,
  stock INTEGER NOT NULL DEFAULT 0,
  image_url TEXT,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Transactions table
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  items JSONB NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  payment_method TEXT NOT NULL,
  amount_paid DECIMAL(10,2) NOT NULL,
  change DECIMAL(10,2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'completed',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Categories table
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for better performance
CREATE INDEX idx_products_user_id ON products(user_id);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_transactions_created_at ON transactions(created_at);

-- Enable Row Level Security (RLS)
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- RLS Policies for Products
CREATE POLICY "Users can view their own products"
  ON products FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own products"
  ON products FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own products"
  ON products FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own products"
  ON products FOR DELETE
  USING (auth.uid() = user_id);

-- RLS Policies for Transactions
CREATE POLICY "Users can view their own transactions"
  ON transactions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own transactions"
  ON transactions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own transactions"
  ON transactions FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own transactions"
  ON transactions FOR DELETE
  USING (auth.uid() = user_id);

-- RLS Policies for Categories
CREATE POLICY "Users can view their own categories"
  ON categories FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own categories"
  ON categories FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for products table
CREATE TRIGGER update_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

4. Klik **"Run"** untuk execute SQL
5. Anda akan melihat "Success. No rows returned" - ini normal!

## 4. Setup Storage untuk Gambar Produk

1. Di dashboard Supabase, klik **Storage** di sidebar kiri
2. Klik **"Create a new bucket"**
3. Isi detail:
   - **Name:** `product-images`
   - **Public bucket:** ✅ Centang (agar gambar bisa diakses)
4. Klik **"Create bucket"**

### Setup Storage Policy

1. Klik bucket `product-images` yang baru dibuat
2. Klik tab **"Policies"**
3. Klik **"New Policy"**
4. Pilih **"For full customization"**
5. Isi policy:

**Policy 1 - Upload (INSERT):**
```sql
CREATE POLICY "Users can upload product images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'product-images' AND
  auth.role() = 'authenticated'
);
```

**Policy 2 - View (SELECT):**
```sql
CREATE POLICY "Anyone can view product images"
ON storage.objects FOR SELECT
USING (bucket_id = 'product-images');
```

**Policy 3 - Delete:**
```sql
CREATE POLICY "Users can delete their own images"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'product-images' AND
  auth.role() = 'authenticated'
);
```

## 5. Enable Email Authentication

1. Di dashboard Supabase, klik **Authentication** di sidebar kiri
2. Klik **"Providers"**
3. **Email** sudah enabled by default ✅
4. (Opsional) Customize email templates di tab **"Email Templates"**

## 6. Konfigurasi di Flutter App

### Buat file lib/supabase_config.dart

Buat file baru dengan isi:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL'; // Ganti dengan URL Anda
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY'; // Ganti dengan anon key Anda
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}

// Helper untuk akses Supabase client
final supabase = Supabase.instance.client;
```

**PENTING:** Ganti `YOUR_SUPABASE_URL` dan `YOUR_SUPABASE_ANON_KEY` dengan nilai dari Step 2!

## 7. Install Dependencies

Jalankan di terminal:

```bash
flutter pub get
```

## 8. Test Koneksi

Jalankan aplikasi:

```bash
flutter run
```

Coba register akun baru untuk test!

## 📊 Monitoring & Dashboard

### Lihat Data Real-time

1. **Table Editor:** Lihat data di tables
2. **SQL Editor:** Run custom queries
3. **Database:** Lihat struktur database
4. **Storage:** Manage uploaded files
5. **Authentication:** Lihat users yang terdaftar

### Logs & Monitoring

- **Logs:** Lihat API requests & errors
- **Reports:** Usage statistics
- **Settings > API:** Monitor API usage

## 🔒 Security Checklist

- ✅ Row Level Security (RLS) enabled
- ✅ Policies untuk semua tables
- ✅ Storage policies configured
- ✅ Email auth enabled
- ✅ Anon key (bukan service_role key) di app

## 💡 Tips

1. **Backup:** Supabase auto-backup di free tier (7 days retention)
2. **Limits:** Monitor usage di dashboard
3. **Real-time:** Sudah enabled by default
4. **API Docs:** Auto-generated di Settings > API

## 🆘 Troubleshooting

### Error: "Invalid API key"
- Pastikan anon key benar (bukan service_role key)
- Check URL sudah benar

### Error: "Row Level Security"
- Pastikan RLS policies sudah dibuat
- Pastikan user sudah login

### Error: "Storage upload failed"
- Pastikan bucket sudah dibuat
- Pastikan storage policies sudah dibuat

## 📚 Resources

- [Supabase Docs](https://supabase.com/docs)
- [Flutter Package](https://pub.dev/packages/supabase_flutter)
- [SQL Reference](https://supabase.com/docs/guides/database)
