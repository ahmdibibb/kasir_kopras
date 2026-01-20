# Kasir Kopras - Aplikasi Kasir Mobile

Aplikasi kasir mobile berbasis Flutter dengan integrasi Supabase untuk manajemen penjualan, produk, dan laporan bisnis.

## Fitur Utama

- ✅ Autentikasi dengan Email/Password
- ✅ Manajemen Produk (CRUD)
- ✅ Transaksi Penjualan & Pembayaran
- ✅ Riwayat Transaksi
- ✅ Laporan & Analisis Penjualan
- ✅ Grafik Pendapatan
- ✅ Export Laporan PDF (Coming Soon)
- ✅ Notifikasi Push (Coming Soon)
- ✅ Real-time Data Sync

## Teknologi

- **Framework:** Flutter 3.0+
- **Bahasa:** Dart 3.0+
- **Backend:** Supabase (PostgreSQL, Authentication, Storage, Real-time)
- **State Management:** GetX
- **Database:** PostgreSQL (via Supabase)

## Setup Project

### Prerequisites

1. Install Flutter SDK: https://flutter.dev/docs/get-started/install
2. Install Android Studio atau VS Code dengan Flutter extension
3. Setup Supabase project di https://supabase.com (GRATIS, tanpa kartu kredit!)

### Instalasi

```bash
# Clone atau download project
cd Kasir_Kopras

# Install dependencies
flutter pub get

# Run aplikasi
flutter run
```

### Konfigurasi Supabase

Ikuti panduan lengkap di [SUPABASE_SETUP.md](SUPABASE_SETUP.md)

**Ringkasan:**
1. Buat project baru di Supabase
2. Copy SQL schema dari SUPABASE_SETUP.md
3. Dapatkan URL dan anon key
4. Update `lib/supabase_config.dart` dengan credentials Anda
5. Run aplikasi!

## Struktur Project

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # App configuration
├── models/                   # Data models
├── screens/                  # UI Screens
├── widgets/                  # Reusable widgets
├── services/                 # Business logic
├── controllers/              # State management
├── utils/                    # Utilities
└── theme/                    # Theme configuration
```

## Build APK

```bash
# Debug APK
flutter build apk

# Release APK
flutter build apk --release
```

## License

MIT License
