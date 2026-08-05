# 🏆 Digital Arisan Antigravity

**Digital Arisan Antigravity** adalah aplikasi pengelolaan arisan modern, elegan, dan profesional berbasis **Flutter Web & Mobile** yang terintegrasi secara *real-time* dengan **Firebase Cloud Firestore** dan **Google Drive API v3**.

---

## 🌟 Fitur Unggulan

### 📱 1. Responsive & Dynamic UI Header
- **Header Scrolled Backdrop**: Mengubah warna background `AppBar` menjadi *Deep Dark Teal* (`#193B43`) secara dinamis saat halaman di-scroll dengan aksen border lime (`#D3F36B`).
- **Visual Banner & Gallery Grid**: Tampilan banner grafis gradient dan grid galeri foto kegiatan arisan.
- **4 Tab Utama Clean Navigation Bar**:
  - 🏠 **Dashboard**: Ringkasan kelompok, banner visual, pemenang aktif, selector periode (Bulan 1, Bulan 2, Bulan 3...), dan status pembayaran anggota (*LUNAS / BELUM LUNAS*).
  - 🎰 **Kocokan Roulette**: Wheel roulette interaktif dengan suara, efek konfeti hiasan, dan pencatatan pemenang otomatis.
  - 📊 **Kas & Audit Log**: Pencatatan keluar kas elegan, rincian pengeluaran, dan audit history per periode full-page.
  - 👤 **Profil**: Kelola akun, ganti kelompok arisan, dan tambah kelompok arisan baru.

### 🔥 2. Real-time Firebase Cloud Firestore Integration
- **Persistensi Data**: Menyimpan status pembayaran anggota, urutan kocokan arisan, serta pengeluaran uang kas secara otomatis ke koleksi Firestore (`groups`, `expenses`, `gallery`).
- **Web Compat JS SDK**: Terintegrasi secara aman dengan Firebase Web SDK (v10.8.0) di `index.html`.

### 📁 3. Google Drive Integration (Drive v3 API)
- **Google OAuth Sign-In**: Login menggunakan Akun Google resmi (`google_sign_in`).
- **Upload Otomatis ke Folder Dedicated**: Pengunggahan foto & dokumentasi arisan otomatis diarahkan langsung ke folder Google Drive:
  - **Nama Folder**: `arisan-antigravity`
  - **Folder ID**: `1bU-HL9pQHyHyDNn8awxabxrSrVr8_6DI`

---

## 🚀 Panduan Menjalankan Aplikasi (Getting Started)

### 1. Prasyarat
- Flutter SDK `>=3.0.0`
- Web Browser (Google Chrome / Edge)

### 2. Instalasi & Pub Get
```bash
# Clone repository ini (jika belum)
cd app_arisan_antigravity

# Download seluruh dependencies package
flutter pub get
```

### 3. Menjalankan Mode Development
```bash
# Menjalankan di Chrome
flutter run -d chrome
```

### 4. Build Release Web & Jalankan Server Lokal
```bash
# Build bundle versi web
flutter build web

# Jalankan server lokal Python di port 8080
python3 -m http.server 8080 --directory build/web
```
Buka browser dan akses **[http://localhost:8080](http://localhost:8080)**.

### 5. Build Android App Bundle (.aab) Lokal via Terminal Mac
Jika SDK Android dan Java (OpenJDK) belum dikenali otomatis, atur variabel lingkungan ini sebelum menjalankan proses *build*:
```bash
# Atur path Java (OpenJDK)
export JAVA_HOME="/usr/local/opt/openjdk@17"
export PATH="/usr/local/opt/openjdk@17/bin:$PATH"

# Atur path Android SDK Command-line Tools
export ANDROID_HOME="/usr/local/share/android-commandlinetools"

# Jalankan proses build ke format AAB untuk Google Play Store
flutter build appbundle
```
*File output AAB dapat ditemukan di `build/app/outputs/bundle/release/app-release.aab`.*

---

## 🛠️ Struktur Proyek

```text
lib/
├── core/
│   ├── models/           # Data models (GroupModel, MemberModel)
│   ├── services/         # FirebaseService & GoogleDriveService
│   └── theme/            # AppTheme design system (Colours & Typography)
├── features/
│   ├── dashboard/        # Dashboard screen, header banner & period chips
│   ├── group/            # Modal urutan pemenang & buat kelompok baru
│   ├── history/          # Kas, pengeluaran & audit log full-page
│   ├── profile/          # Profil pengguna & group switcher
│   └── roulette/         # Kocokan arisan interaktif & konfeti
├── firebase_options.dart # Konfigurasi resmi Firebase arisan-antigravity
└── main.dart             # Main entry point & Bottom Navigation Bar (4 Tab)
```


