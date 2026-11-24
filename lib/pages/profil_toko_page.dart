import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'kelola_karyawan_page.dart';
import 'kelola_pelanggan_page.dart';

// Halaman Pengaturan Profil Toko dan Footer Struk Kasir
class ProfilTokoPage extends StatefulWidget {
  const ProfilTokoPage({super.key});

  @override
  State<ProfilTokoPage> createState() => _ProfilTokoPageState();
}

class _ProfilTokoPageState extends State<ProfilTokoPage> {
  // Controller formulir identitas toko
  final TextEditingController _namaTokoController = TextEditingController();

  final TextEditingController _alamatController = TextEditingController();

  final TextEditingController _noWaController = TextEditingController();

  final TextEditingController _footerController = TextEditingController();

  // Status tombol simpan
  bool _sedangMenyimpan = false;

  // Nama kasir aktif
  String _activeCashierName = 'Belum Ditentukan';

  @override
  void initState() {
    super.initState();

    // Memuat profil toko dan kasir aktif
    _muatProfilToko();
  }

  @override
  void dispose() {
    _namaTokoController.dispose();
    _alamatController.dispose();
    _noWaController.dispose();
    _footerController.dispose();

    super.dispose();
  }

  // Membaca pengaturan toko dan nama kasir aktif
  // dari SharedPreferences
  Future<void> _muatProfilToko() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      // Memuat identitas toko
      _namaTokoController.text = prefs.getString('nama_toko') ?? '';

      _alamatController.text = prefs.getString('alamat_toko') ?? '';

      _noWaController.text = prefs.getString('no_wa') ?? '';

      _footerController.text = prefs.getString('footer_struk') ?? '';

      // Memuat nama kasir aktif
      _activeCashierName =
          prefs.getString('active_cashier_name') ?? 'Belum Ditentukan';
    });
  }

  // Menyimpan pengaturan profil toko
  Future<void> _simpanProfilToko() async {
    setState(() {
      _sedangMenyimpan = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('nama_toko', _namaTokoController.text.trim());

      await prefs.setString('alamat_toko', _alamatController.text.trim());

      await prefs.setString('no_wa', _noWaController.text.trim());

      await prefs.setString('footer_struk', _footerController.text.trim());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Identitas toko berhasil diperbarui!'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan pengaturan: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sedangMenyimpan = false;
        });
      }
    }
  }

  // Membuka halaman Kelola Karyawan
  Future<void> _bukaKelolaKaryawan() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const KelolaKaryawanPage()),
    );

    if (!mounted) return;

    // Memperbarui nama kasir setelah kembali
    await _muatProfilToko();
  }

  // Membuka halaman Kelola Pelanggan
  void _bukaKelolaPelanggan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const KelolaPelangganPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // APP BAR
      appBar: AppBar(
        title: const Text(
          'Profil & Pengaturan Toko',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // KONTEN HALAMAN
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. KARTU RINGKASAN KASIR AKTIF
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF1E3A8A),
                    child: Icon(
                      Icons.storefront,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KASIR AKTIF SHIFT INI',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          _activeCashierName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  OutlinedButton.icon(
                    onPressed: _bukaKelolaKaryawan,
                    icon: const Icon(Icons.people_outline, size: 16),
                    label: const Text('Kelola'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 2. MENU MANAJEMEN DATA PELANGGAN
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF0D9488),
                  child: Icon(Icons.people_alt, color: Colors.white, size: 20),
                ),

                title: const Text(
                  'Data Pelanggan & Lokasi GPS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),

                subtitle: const Text(
                  'Kelola member CRM dan navigasi rute pengantaran',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),

                trailing: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF1E3A8A),
                ),

                onTap: _bukaKelolaPelanggan,
              ),
            ),

            const SizedBox(height: 20),

            // 3. FORM IDENTITAS USAHA
            const Text(
              'IDENTITAS USAHA & STRUK KASIR',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF1E3A8A),
              ),
            ),

            const SizedBox(height: 12),

            // Nama Toko
            TextFormField(
              controller: _namaTokoController,
              decoration: InputDecoration(
                labelText: 'Nama Toko / Usaha',
                prefixIcon: const Icon(Icons.store),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 14),

            // Alamat Toko
            TextFormField(
              controller: _alamatController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Alamat Toko',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 14),

            // Nomor WhatsApp Toko
            TextFormField(
              controller: _noWaController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Nomor WhatsApp / Kontak Toko',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 14),

            // Footer Struk
            TextFormField(
              controller: _footerController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Catatan Kaki Struk (Footer Nota)',
                hintText: 'Contoh: Terima kasih atas kunjungan Anda!',
                prefixIcon: const Icon(Icons.receipt_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            // 4. TOMBOL SIMPAN PENGATURAN
            ElevatedButton.icon(
              onPressed: _sedangMenyimpan ? null : _simpanProfilToko,

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              icon: _sedangMenyimpan
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save),

              label: Text(
                _sedangMenyimpan
                    ? 'Menyimpan Pengaturan...'
                    : 'Simpan Profil Toko',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
