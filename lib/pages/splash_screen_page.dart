// Mengimpor pustaka kontrol waktu dan timer asinkron bawaan bahasa Dart
import 'dart:async';

// Mengimpor pustaka antarmuka Material Design utama Flutter
import 'package:flutter/material.dart';

// Mengimpor halaman navigasi utama (MainNavigationPage) sebagai tujuan perpindahan layar
import 'main_navigation_page.dart';

// Komponen/Widget SplashScreenPage turunan StatefulWidget:
// Mengelola status timer hitung mundur
class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

// Kelas pengelola state, timer asinkron, dan logika navigasi Splash Screen
class _SplashScreenPageState extends State<SplashScreenPage> {
  // --- DEKLARASI VARIABEL STATE & TIMER ---

  // Deklarasi variabel durasi hitung mundur dalam satuan detik
  // (Nilai awal: 10 detik)
  int _durasiDetik = 10;

  // Deklarasi variabel objek timer asinkron
  // (Nullable '?' karena belum dibuat saat kelas diinisialisasi)
  Timer? _timer;

  // Method initState:
  // Siklus hidup (lifecycle) yang dieksekusi otomatis satu kali
  // saat widget pertama dipasang
  @override
  void initState() {
    super.initState();

    // Memulai fungsi penghitung waktu mundur otomatis
    // saat layar splash screen terbuka
    _mulaiHitungMundur();
  }

  // --- FUNGSI LOGIKA HITUNG MUNDUR & NAVIGASI OTOMATIS ---
  void _mulaiHitungMundur() {
    // KONTROL PERULANGAN WAKTU ASINKRON:
    // Mengeksekusi fungsi callback setiap interval 1 detik secara berulang
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // --- KONTROL PERCABANGAN LOGIKA EVALUASI TIMER ---

      // Percabangan Kondisi 1:
      // Jika waktu durasi masih lebih besar dari 1 detik
      if (_durasiDetik > 1) {
        // KONTROL LOGIKA STATE MANAGEMENT:
        // Mengurangi angka durasi dan memperbarui angka di layar
        setState(() {
          // Operasi decrement
          _durasiDetik--;
        });
      }
      // Percabangan Kondisi 2:
      // Jika waktu durasi telah habis
      else {
        _timer?.cancel();

        // KONTROL PERCABANGAN KEAMANAN WIDGET TREE (SAFETY CHECK)
        // Memastikan widget masih terpasang di memori
        if (!mounted) return;

        // LOGIKA NAVIGASI PERPINDAHAN HALAMAN SATU ARAH
        // Mengganti Splash Screen dengan MainNavigationPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationPage()),
        );
      }
    });
  }

  // Method dispose:
  // Siklus hidup pembersihan memori saat widget dihancurkan
  @override
  void dispose() {
    // PEMBERSIHAN SUMBER DAYA (RESOURCE CLEANUP)
    // Mematikan timer untuk mencegah memory leak
    _timer?.cancel();

    super.dispose();
  }

  // Method build:
  // Merender tata letak visual halaman pembuka Splash Screen
  @override
  Widget build(BuildContext context) {
    // Komponen/Widget Scaffold:
    // Layar penuh dengan latar belakang warna biru navy
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),

      // Komponen/Widget Center:
      // Memposisikan seluruh komponen tepat di tengah layar
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // =====================================================================
            // BAGIAN 1: LOGO APLIKASI SMARTKASIR BERELEVASI
            // =====================================================================

            // Komponen/Widget Container:
            // Wadah lingkaran putih dengan bayangan elevasi
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),

              // Komponen/Widget Icon:
              // Ikon mesin kasir
              child: const Icon(
                Icons.point_of_sale_rounded,
                size: 72,
                color: Color(0xFF1E3A8A),
              ),
            ),

            const SizedBox(height: 24),

            // =====================================================================
            // BAGIAN 2: IDENTITAS & TAGLINE PRODUK DIGITAL
            // =====================================================================
            const Text(
              'SmartKasir',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Aplikasi Kasir Point of Sale Digital',
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),

            const SizedBox(height: 36),

            // =====================================================================
            // BAGIAN 3: INDIKATOR LOADING & TIMER
            // =====================================================================
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: Colors.amber,
                strokeWidth: 3,
              ),
            ),

            const SizedBox(height: 14),

            // mengubah teks keterangan loading
            Text(
              'Menyiapkan sistem SmartKasir ($_durasiDetik detik)...',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),

            const SizedBox(height: 40),

            // Komponen/Widget Text:
            // Catatan versi aplikasi
            Text(
              'Versi 1.0.0 - Modul Pertemuan 10',
              style: TextStyle(fontSize: 11, color: Colors.blue.shade200),
            ),
          ],
        ),
      ),
    );
  }
}
