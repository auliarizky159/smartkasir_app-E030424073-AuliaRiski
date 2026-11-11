import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/produk.dart';
import '../helpers/database_helper.dart';

// =====================================================
// HALAMAN FORM TAMBAH DAN EDIT PRODUK
// =====================================================

class FormProdukPage extends StatefulWidget {
  final Produk? produk;

  const FormProdukPage({super.key, this.produk});

  @override
  State<FormProdukPage> createState() => _FormProdukPageState();
}

class _FormProdukPageState extends State<FormProdukPage> {
  // =====================================================
  // 1. DEKLARASI VARIABEL DAN CONTROLLER
  // =====================================================

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _kodeController = TextEditingController();

  final TextEditingController _namaController = TextEditingController();

  final TextEditingController _hargaBeliController = TextEditingController();

  final TextEditingController _hargaJualController = TextEditingController();

  final TextEditingController _stokController = TextEditingController();

  final TextEditingController _diskonController = TextEditingController(
    text: '0',
  );

  // Daftar kategori produk
  String _kategoriTerpilih = 'Makanan';

  final List<String> _kategoriList = [
    'Makanan',
    'Minuman',
    'Snack',
    'Dessert',
    'Lainnya',
  ];

  // Status penyimpanan
  bool _sedangMenyimpan = false;

  // Pemeriksaan mode edit
  bool get _isEditMode => widget.produk != null;

  // =====================================================
  // 2. INISIALISASI FORMULIR
  // =====================================================

  @override
  void initState() {
    super.initState();

    if (_isEditMode) {
      // Mengambil data produk yang akan diedit
      final p = widget.produk!;

      _kodeController.text = p.kodeProduk;
      _namaController.text = p.nama;

      _kategoriTerpilih = _kategoriList.contains(p.kategori)
          ? p.kategori
          : 'Makanan';

      _hargaBeliController.text = p.hargaBeli.toInt().toString();

      _hargaJualController.text = p.hargaJual.toInt().toString();

      _stokController.text = p.stok.toString();

      _diskonController.text = p.diskonPersen.toString();
    } else {
      // Membuat kode produk otomatis
      _kodeController.text =
          'PRD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    }
  }

  // =====================================================
  // 3. MEMBERSIHKAN CONTROLLER
  // =====================================================

  @override
  void dispose() {
    _kodeController.dispose();
    _namaController.dispose();
    _hargaBeliController.dispose();
    _hargaJualController.dispose();
    _stokController.dispose();
    _diskonController.dispose();

    super.dispose();
  }

  // =====================================================
  // 4. MENYIMPAN DAN MEMPERBARUI DATA PRODUK
  // =====================================================

  Future<void> _simpanKeDatabase() async {
    // Validasi seluruh input formulir
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _sedangMenyimpan = true;
    });

    try {
      // Mengambil nilai dari setiap controller
      final double beli = double.parse(_hargaBeliController.text.trim());

      final double jual = double.parse(_hargaJualController.text.trim());

      final int stok = int.parse(_stokController.text.trim());

      final int diskon = int.tryParse(_diskonController.text.trim()) ?? 0;

      // Membuat objek Produk
      final produkData = Produk(
        id: _isEditMode ? widget.produk!.id : null,

        kodeProduk: _kodeController.text.trim(),

        nama: _namaController.text.trim(),

        kategori: _kategoriTerpilih,

        hargaBeli: beli,

        hargaJual: jual,

        stok: stok,

        gambarUrl: _isEditMode ? widget.produk!.gambarUrl : 'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=500',

        diskonPersen: diskon,
      );

      // Percabangan proses INSERT dan UPDATE
      if (_isEditMode) {
        // Memperbarui produk yang sudah ada
        await DatabaseHelper.instance.updateProduk(produkData);
      } else {
        // Menambahkan produk baru
        await DatabaseHelper.instance.insertProduk(produkData);
      }

      // Memastikan widget masih aktif
      if (!mounted) return;

      // Notifikasi berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'Data produk "${produkData.nama}" berhasil diperbarui!'
                : 'Produk "${produkData.nama}" berhasil disimpan ke SQLite!',
          ),
          backgroundColor: const Color(0xFF1E3A8A),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Kembali ke halaman sebelumnya
      // Mengirim nilai true sebagai tanda data berubah
      Navigator.pop(context, true);
    } catch (e) {
      // Notifikasi jika terjadi kesalahan
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.red,
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

  // =====================================================
  // 5. MEMBANGUN TAMPILAN FORMULIR
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Data Produk' : 'Tambah Produk Baru'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // =========================================
              // BANNER INFORMASI
              // =========================================

              Container(
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),

                child: Row(
                  children: [
                    Icon(
                      _isEditMode ? Icons.edit_note : Icons.playlist_add_check,
                      color: const Color(0xFF1E3A8A),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        _isEditMode
                            ? 'Anda sedang mengedit produk: ${widget.produk!.nama}'
                            : 'Pastikan harga jual kasir lebih besar dari harga beli modal toko.',

                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1E3A8A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // =========================================
              // 1. INPUT KODE PRODUK
              // =========================================
              TextFormField(
                controller: _kodeController,
                readOnly: _isEditMode,

                decoration: InputDecoration(
                  labelText: 'Kode SKU Produk',
                  prefixIcon: const Icon(Icons.qr_code),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: _isEditMode ? Colors.grey.shade100 : Colors.white,
                ),

                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Kode wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // =========================================
              // 2. INPUT NAMA PRODUK
              // =========================================
              TextFormField(
                controller: _namaController,

                decoration: InputDecoration(
                  labelText: 'Nama Produk Barang',
                  prefixIcon: const Icon(Icons.shopping_bag_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),

                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama barang tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // =========================================
              // 3. DROPDOWN KATEGORI
              // =========================================
              DropdownButtonFormField<String>(
                value: _kategoriTerpilih,

                decoration: InputDecoration(
                  labelText: 'Kelompok Kategori',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),

                items: _kategoriList.map((kat) {
                  return DropdownMenuItem<String>(value: kat, child: Text(kat));
                }).toList(),

                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _kategoriTerpilih = val;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // =========================================
              // 4. INPUT HARGA BELI DAN HARGA JUAL
              // =========================================
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hargaBeliController,

                      keyboardType: TextInputType.number,

                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],

                      decoration: InputDecoration(
                        labelText: 'Harga Modal (Rp)',
                        prefixIcon: const Icon(Icons.monetization_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),

                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Wajib diisi';
                        }

                        final beli = double.tryParse(val);

                        if (beli == null || beli <= 0) {
                          return 'Harus > 0';
                        }

                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: TextFormField(
                      controller: _hargaJualController,

                      keyboardType: TextInputType.number,

                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],

                      decoration: InputDecoration(
                        labelText: 'Harga Jual (Rp)',
                        prefixIcon: const Icon(Icons.price_check),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),

                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Wajib diisi';
                        }

                        final jual = double.tryParse(val) ?? 0;

                        final beli =
                            double.tryParse(_hargaBeliController.text) ?? 0;

                        if (jual <= 0) {
                          return 'Harus > 0';
                        }

                        if (jual <= beli) {
                          return 'Harus > Modal';
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // =========================================
              // 5. INPUT STOK DAN DISKON
              // =========================================
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stokController,

                      keyboardType: TextInputType.number,

                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],

                      decoration: InputDecoration(
                        labelText: 'Stok Fisik',
                        prefixIcon: const Icon(Icons.inventory_2_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),

                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Stok wajib diisi';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: TextFormField(
                      controller: _diskonController,

                      keyboardType: TextInputType.number,

                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],

                      decoration: InputDecoration(
                        labelText: 'Diskon (%)',
                        prefixIcon: const Icon(Icons.discount_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),

                      validator: (val) {
                        final d = int.tryParse(val ?? '0') ?? 0;

                        if (d < 0 || d > 50) {
                          return 'Diskon maksimal 50%';
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // =========================================
              // 6. TOMBOL SIMPAN / PERBARUI
              // =========================================
              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton.icon(
                  onPressed: _sedangMenyimpan ? null : _simpanKeDatabase,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  icon: _sedangMenyimpan
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          _isEditMode
                              ? Icons.check_circle_outline
                              : Icons.save_outlined,
                        ),

                  label: Text(
                    _isEditMode
                        ? 'PERBARUI DATA PRODUK'
                        : 'SIMPAN PRODUK KE DATABASE',

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
