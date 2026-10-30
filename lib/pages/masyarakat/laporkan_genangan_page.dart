import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class LaporkanGenanganPage extends StatefulWidget {
  const LaporkanGenanganPage({super.key});

  @override
  State<LaporkanGenanganPage> createState() => _LaporkanGenanganPageState();
}

class _LaporkanGenanganPageState extends State<LaporkanGenanganPage> {
  final TextEditingController lokasiController = TextEditingController();

  final TextEditingController deskripsiController = TextEditingController();

  String tingkatGenangan = 'Sedang';

  double? latitude;
  double? longitude;

  bool isLoadingLocation = false;
  bool isSubmitting = false;
  final ImagePicker _picker = ImagePicker();
  XFile? _fotoGenangan;
  // ==========================================================
  // MENGAMBIL LOKASI
  // ==========================================================

  Future<void> getCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aktifkan lokasi/GPS di HP terlebih dahulu.'),
          ),
        );

        setState(() {
          isLoadingLocation = false;
        });

        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak.')));

        setState(() {
          isLoadingLocation = false;
        });

        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Izin lokasi ditolak permanen. '
              'Aktifkan melalui Pengaturan aplikasi.',
            ),
          ),
        );

        setState(() {
          isLoadingLocation = false;
        });

        return;
      }

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      setState(() {
        latitude = position.latitude;

        longitude = position.longitude;

        lokasiController.text =
            'Lat: ${position.latitude.toStringAsFixed(7)}, '
            'Lng: ${position.longitude.toStringAsFixed(7)}';

        isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        isLoadingLocation = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal mengambil lokasi: $e')));
    }
  }

  Future<void> _pilihFoto(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image == null || !mounted) return;

      setState(() {
        _fotoGenangan = image;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $e')));
    }
  }

  // ==========================================================
  // MENGIRIM LAPORAN KE API LARAVEL
  // ==========================================================
  Future<void> _kirimLaporan() async {
    if (isSubmitting) return;

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan ambil lokasi GPS terlebih dahulu.'),
        ),
      );
      return;
    }

    if (lokasiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi laporan belum tersedia.')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.50:8000/api/laporan'),
      );

      request.headers['Accept'] = 'application/json';
      request.fields.addAll({
        'lokasi': lokasiController.text.trim(),
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'tingkat_genangan': tingkatGenangan,
        'deskripsi': deskripsiController.text.trim(),
      });

      if (_fotoGenangan != null) {
        request.files.add(
          await http.MultipartFile.fromPath('foto', _fotoGenangan!.path),
        );
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );
      final response = await http.Response.fromStream(streamedResponse);

      String message = 'Gagal mengirim laporan.';
      Map<String, dynamic>? responseData;

      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          responseData = decoded;
          message = decoded['message']?.toString() ?? message;

          // Tampilkan pesan validasi Laravel yang lebih spesifik.
          final errors = decoded['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              message = firstError.first.toString();
            }
          }
        }
      } on FormatException {
        // Respons bukan JSON; gunakan pesan umum di bawah.
      }

      if (!mounted) return;

      if (response.statusCode == 201 && responseData?['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData?['message']?.toString() ??
                  'Laporan berhasil dikirim.',
            ),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          lokasiController.clear();
          deskripsiController.clear();
          latitude = null;
          longitude = null;
          _fotoGenangan = null;
          tingkatGenangan = 'Sedang';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$message (HTTP ${response.statusCode})'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Koneksi ke server gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    lokasiController.dispose();
    deskripsiController.dispose();

    super.dispose();
  }

  // ==========================================================
  // TAMPILAN LAPORAN
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,

        title: const Text(
          'Laporkan Genangan',

          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Form Pelaporan',

              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Isi informasi genangan yang Anda temukan.',

              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            // =================================================
            // LOKASI
            // =================================================
            const Text(
              'Lokasi Genangan',

              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: lokasiController,

              readOnly: true,

              decoration: InputDecoration(
                hintText: 'Belum ada lokasi',

                prefixIcon: const Icon(Icons.location_on, color: Colors.blue),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 48,

              child: OutlinedButton.icon(
                onPressed: isLoadingLocation ? null : getCurrentLocation,

                icon: isLoadingLocation
                    ? const SizedBox(
                        width: 18,
                        height: 18,

                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),

                label: Text(
                  isLoadingLocation
                      ? 'Mengambil lokasi...'
                      : 'Gunakan Lokasi Saya',
                ),
              ),
            ),

            const SizedBox(height: 12),

            // =================================================
            // HASIL LOKASI
            // =================================================
            if (latitude != null && longitude != null)
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Colors.green.shade50,

                  borderRadius: BorderRadius.circular(12),

                  border: Border.all(color: Colors.green.shade200),
                ),

                child: Text(
                  'Lokasi berhasil diambil\n'
                  'Latitude: ${latitude!.toStringAsFixed(7)}\n'
                  'Longitude: ${longitude!.toStringAsFixed(7)}',

                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // =================================================
            // TINGKAT GENANGAN
            // =================================================
            const Text(
              'Tingkat Genangan',

              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: tingkatGenangan,

              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.water_drop, color: Colors.blue),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              items: const [
                DropdownMenuItem(value: 'Rendah', child: Text('Rendah')),

                DropdownMenuItem(value: 'Sedang', child: Text('Sedang')),

                DropdownMenuItem(value: 'Tinggi', child: Text('Tinggi')),
              ],

              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  tingkatGenangan = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // =================================================
            // DESKRIPSI
            // =================================================
            const Text(
              'Deskripsi',

              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: deskripsiController,

              maxLines: 5,

              decoration: InputDecoration(
                hintText: 'Jelaskan kondisi genangan...',

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // FOTO
            // =================================================
            const Text(
              'Foto Genangan',

              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _fotoGenangan == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 45,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Belum ada foto genangan',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_fotoGenangan!.path),
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pilihFoto(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Kamera'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pilihFoto(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Galeri'),
                      ),
                    ),
                  ],
                ),
                if (_fotoGenangan != null)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _fotoGenangan = null;
                      });
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Hapus foto'),
                  ),
              ],
            ),

            const SizedBox(height: 25),

            // =================================================
            // KIRIM LAPORAN
            // =================================================
            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : _kirimLaporan,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  isSubmitting ? 'Mengirim...' : 'Kirim Laporan',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ============================================================
// HALAMAN DAFTAR LAPORAN MASYARAKAT
// ============================================================
