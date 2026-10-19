# KLiK

KLiK adalah prototipe aplikasi dating lintas platform untuk Android dan iOS, dibangun dengan
Flutter. Aplikasi ini mendemonstrasikan alur menemukan profil, memberi Like, melihat match,
membuka percakapan, dan mengedit profil.

## Demo iOS

https://github.com/user-attachments/assets/152c2a1f-4121-4587-bd26-e789d1809544

Demo memperlihatkan urutan **Temukan (swipe profil) → Likes → Chat → Profil**.

Video direkam pada iPhone 17 Pro Simulator dengan iOS 26.3. Pada rekaman, emoji dapat terlihat
sebagai kotak tanda tanya karena masalah rendering pada runtime simulator tersebut.

---

## Daftar Isi

- [Tentang](#tentang)
- [Fitur](#fitur)
- [Batasan Prototipe](#batasan-prototipe)
- [Tech Stack](#tech-stack)
- [Struktur Proyek](#struktur-proyek)
- [Prasyarat](#prasyarat)
- [Menjalankan Aplikasi](#menjalankan-aplikasi)
- [Alur Penggunaan](#alur-penggunaan)
- [Pengujian](#pengujian)

---

## Tentang

KLiK dibuat sebagai prototipe UI mobile untuk memperlihatkan pengalaman dating app yang
sederhana dan mudah dijelajahi. Antarmuka memakai bahasa Indonesia, dengan navigasi utama di
bagian bawah layar.

## Fitur

### Temukan profil
- Kartu profil dengan foto, nama, usia, kota, bio, dan minat.
- Geser ke kiri untuk melewati, ke kanan untuk Like, dan ke atas untuk Super Like.
- Filter berdasarkan rentang usia dan jarak maksimum.
- Animasi feedback Like dan layar match saat Like bersifat mutual.

### Likes
- Daftar profil yang menyukai pengguna, dengan foto yang disamarkan.
- Tombol filter, notifikasi, dan buka Likes menampilkan informasi bahwa alur tersebut masih
  berupa demo.

### Chat
- Daftar percakapan dan tampilan pesan.
- Kirim pesan teks serta sisipkan emoji melalui pemilih emoji.
- Menu lampiran dan info percakapan tersedia sebagai tampilan demo.

### Profil
- Lihat profil, kota, bio, minat, dan indikator kelengkapan.
- Edit informasi profil dan pilih foto dari pilihan foto demo.

### Match
- Animasi match dan pilihan untuk mulai mengirim pesan atau melanjutkan melihat profil.

## Batasan Prototipe

- Data profil dan percakapan adalah data contoh yang disimpan dalam memori aplikasi.
- Belum ada backend, autentikasi, sinkronisasi akun, atau penyimpanan permanen.
- Likes, notifikasi, lampiran, dan beberapa kontrol lain hanya menunjukkan informasi demo.
- Foto profil menggunakan URL gambar jaringan; koneksi internet diperlukan untuk memuatnya.

## Tech Stack

| Bagian | Teknologi |
|---|---|
| Bahasa | Dart |
| Framework UI | Flutter |
| Navigasi kartu | `flutter_card_swiper` |
| Animasi | Lottie (`lottie`) |
| Target aplikasi | Android dan iOS |
| Pengujian UI | Flutter Test |

## Struktur Proyek

```text
klik-dating/
├── android/                 # konfigurasi host Android
├── ios/                     # konfigurasi host iOS
├── assets/animations/       # animasi Like dan match
├── docs/media/              # video demo iOS
├── lib/
│   ├── data/                # data profil dan pesan demo
│   ├── features/            # layar Temukan, Likes, Chat, Match, Profil
│   ├── models/              # model profil dan pesan
│   ├── widgets/             # komponen bersama, termasuk brand KLiK
│   ├── app.dart             # tema, navigasi, dan state aplikasi
│   └── main.dart            # entry point
└── test/                    # widget dan alur UI
```

## Prasyarat

- Flutter SDK yang memenuhi batas versi di [`pubspec.yaml`](pubspec.yaml).
- Xcode untuk menjalankan aplikasi di iOS Simulator atau perangkat iOS.
- Android Studio dan Android SDK untuk menjalankan aplikasi di Android Emulator atau perangkat.

## Menjalankan Aplikasi

Pasang dependensi lalu jalankan aplikasi pada simulator atau perangkat yang tersedia:

```bash
flutter pub get
flutter devices
flutter run
```

Untuk memilih perangkat tertentu:

```bash
flutter run -d <device-id>
```

### iOS Simulator

```bash
open -a Simulator
flutter run -d <ios-simulator-id>
```

### Android Emulator

Jalankan emulator dari Android Studio, lalu:

```bash
flutter run -d <android-device-id>
```

## Alur Penggunaan

1. Buka tab **Temukan** dan lihat kartu profil.
2. Geser kartu atau gunakan tombol Like untuk berinteraksi dengan profil.
3. Pada Like mutual, layar **Kalian cocok!** menawarkan tombol **Kirim pesan**.
4. Buka tab **Chat** untuk memilih percakapan, lalu tulis pesan atau pilih emoji.
5. Buka tab **Profil** untuk melihat atau mengedit profil dan memilih foto demo.
6. Buka tab **Likes** untuk melihat contoh profil yang menyukai pengguna.

## Pengujian

Jalankan analisis statis dan widget test dengan:

```bash
flutter analyze
flutter test
```
