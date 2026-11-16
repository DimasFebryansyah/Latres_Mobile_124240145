# Serially — TV Series Explorer

Aplikasi Flutter untuk menjelajahi acara TV dari [TVMaze](https://www.tvmaze.com/api), menyimpan favorit, dan mencoba materi praktikum Pemrograman Mobile.

## Fitur responsi

- Login menerima NIM numerik tepat 9 digit dan password `123`; sesi dan username disimpan di `SharedPreferences`.
- Beranda dengan pencarian, daftar TV show dari `https://api.tvmaze.com/shows`, gambar, judul, rating, indikator loading, dan tarik-untuk-muat-ulang.
- Halaman detail mengambil data baru dari `https://api.tvmaze.com/shows/{id}` dan menampilkan gambar, judul, rating, genre, serta ringkasan.
- Tambah/hapus favorit dari kartu maupun halaman detail. Data favorit disimpan sebagai objek `TvShow` dengan Hive `TypeAdapter`; data JSON dari versi sebelumnya dimigrasikan ke box baru saat aplikasi dibuka.
- Profil dapat mengubah nama tampilan dan bio, menampilkan NIM serta jumlah favorit, dan memilih/mengambil foto profil. Foto yang sudah diperkecil disimpan lokal (maksimal 1 MB).
- Navigasi tab memakai `NavigationBar`, halaman detail memakai `Navigator.push`/`pop`, login memakai `pushReplacement`, dan logout membersihkan riwayat dengan `pushAndRemoveUntil`.
- Profil menampilkan kesan dan pesan praktikum serta tombol logout yang menghapus sesi.

## Materi dari MODUL FULL

| Materi | Penerapan dalam aplikasi |
| --- | --- |
| Modul I — Pengenalan & Setup Flutter | Aplikasi Flutter/Dart lintas platform dengan bootstrap asinkron sebelum `runApp`. |
| Modul II — Widget | UI disusun dari widget Material seperti `Scaffold`, `NavigationBar`, `Card`, `GridView`, form, dan widget yang dapat digunakan ulang. |
| Modul III — State & Data | State login, daftar, favorit, pencarian, dan lokasi dikelola dengan controller GetX dan state reaktif. |
| Modul IV — Navigation | Tab Beranda/Favorit/Profil memakai `NavigationBar`; detail memakai `Navigator.push`/`pop`, login memakai `pushReplacement`, dan logout memakai `pushAndRemoveUntil`. |
| Modul V — HTTP Request | Service terpisah mengambil daftar dan detail TVMaze, memeriksa status response, mendekode JSON, lalu mengubahnya menjadi model `TvShow`. |
| Modul VI — Local Storage | `SharedPreferences` menyimpan sesi dan data profil; Hive `TypeAdapter` menyimpan objek favorit. Data favorit JSON versi lama dimigrasikan tanpa menghilangkan koleksi yang telah tersimpan. |
| Modul VII — Notification & LBS | Di Android/iOS, profil dapat mengirim notifikasi uji dan mengambil lokasi saat diminta. Jika berada dalam radius 150 m dari titik contoh, aplikasi mengirim satu notifikasi kedekatan; halaman detail juga dapat menjadwalkan pengingat sekitar satu menit kemudian. |
| Modul VIII — Flutter Lanjutan: GetX | `GetMaterialApp`, dependency injection, `GetxController`, dan `Obx` mengelola state reaktif; perpindahan halaman utama menggunakan API Navigator klasik. |

LBS memeriksa kedekatan ketika pengguna menekan tombol **Ambil lokasi saya**; aplikasi tidak melakukan pelacakan/geofencing di latar belakang. Titik koordinat adalah contoh dan dapat diganti di `watch_spot.dart`. Notifikasi dan LBS merupakan fitur tambahan, bukan bagian wajib kriteria responsi; keduanya hanya ditampilkan pada Android/iOS. Pengingat terjadwal menggunakan waktu lokal WIB dan penjadwalan Android yang tidak presisi, sehingga waktu kemunculannya dapat sedikit bergeser mengikuti kebijakan sistem.

## Menjalankan aplikasi

Pastikan Flutter tersedia, lalu ambil dependency:

```bash
flutter pub get
```

Gunakan NIM berupa tepat 9 angka (NIM yang diawali angka `0` juga valid) dan password `123`. Semua NIM 9 digit diterima; tidak ada satu NIM khusus yang perlu ditanam di source atau diberikan lewat `--dart-define`.

TVMaze memerlukan koneksi internet. Lokasi meminta izin perangkat saat tombol lokasi digunakan. Jika izin ditolak permanen, aktifkan melalui pengaturan aplikasi pada perangkat. Pemilihan foto menggunakan galeri atau kamera; pada iOS, aplikasi meminta izin yang dijelaskan di `ios/Runner/Info.plist`. Foto diperkecil saat dipilih dan dibatasi maksimal 1 MB sebelum disimpan.

## Struktur penting

```text
lib/
  main.dart
  app/
    controllers/   # state login, profil, show, favorit, dan lokasi
    models/        # model TV show dan titik lokasi demo
    screens/       # login, beranda, favorit, profil, dan detail
    services/      # API TVMaze, lokasi, dan notifikasi
    widgets/       # komponen kartu show yang digunakan ulang
```

## Mengadaptasi jika studi kasus berbeda

Pisahkan perubahan berdasarkan tanggung jawabnya, bukan hanya mengganti teks di layar:

1. **Sumber dan bentuk data API** — ganti URL serta metode di [`lib/app/services/tvmaze_service.dart`](lib/app/services/tvmaze_service.dart). Ubah field dan parsing di [`lib/app/models/tv_show.dart`](lib/app/models/tv_show.dart), lalu sesuaikan daftar dan detail di `shows_page.dart` serta `show_detail_page.dart`. Perbarui juga tes service.
2. **Identitas data** — gunakan ID unik dari API sebagai kunci favorit. Jika bentuk objek berubah, sesuaikan model dan adapter Hive. Untuk perubahan skema yang tidak kompatibel, gunakan nama box baru dan migrasikan data lama secara eksplisit; aplikasi ini menunjukkan migrasi dari box JSON `favorites` ke box bertipe `favorite_shows`.
3. **Login** — ganti aturan NIM/password di [`lib/app/controllers/auth_controller.dart`](lib/app/controllers/auth_controller.dart) sesuai mekanisme kasus baru. Untuk login sungguhan, validasi kredensial di backend; SharedPreferences di contoh ini hanya menyimpan sesi lokal dan bukan penyimpanan password aman.
4. **Tampilan dan navigasi** — ganti label, field yang ditampilkan, serta halaman pada `shows_page.dart`, `show_detail_page.dart`, `favorites_page.dart`, dan `home_shell.dart`. Tab Beranda/Favorit/Profil dapat diubah jika studi kasus memiliki alur lain. Sesuaikan rute `Navigator` jika alur login atau logout berubah.
5. **Favorit atau data lokal** — tentukan data yang perlu disimpan untuk kasus baru, lalu perbarui model dan `FavoritesController`. SharedPreferences cocok untuk preferensi/sesi sederhana; Hive cocok untuk kumpulan objek lokal yang perlu dibaca dan diubah.
6. **Profil (opsional)** — ubah field nama dan bio di `profile_page.dart`/`profile_controller.dart`. Jika foto tidak dibutuhkan, hapus pemilih kamera/galeri, penyimpanan foto, dan deskripsi izin kamera/galeri iOS.
7. **Lokasi (opsional)** — ganti nama dan koordinat contoh di [`lib/app/models/watch_spot.dart`](lib/app/models/watch_spot.dart), atau sesuaikan ambang 150 m di `location_controller.dart`. Hapus fitur lokasi dan izin platform bila kasus tidak memerlukannya. Minta izin hanya jika fitur digunakan.
8. **Notifikasi (opsional)** — ubah judul, isi, serta waktu pengingat di `notification_service.dart` dan halaman yang memicunya. Jika kasus baru tidak memerlukan notifikasi, hapus pemanggil serta konfigurasi izin/receiver platform yang tidak lagi dipakai.

## Pengujian

```bash
flutter analyze
flutter test
```

