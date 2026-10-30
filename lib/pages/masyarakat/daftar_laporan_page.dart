import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DaftarLaporanPage extends StatefulWidget {
  const DaftarLaporanPage({super.key});

  @override
  State<DaftarLaporanPage> createState() => _DaftarLaporanPageState();
}

class _DaftarLaporanPageState extends State<DaftarLaporanPage> {
  List<Map<String, dynamic>> daftarLaporan = [];

  bool isLoading = true;
  String? errorMessage;

  final String apiUrl = 'http://192.168.1.50:8000/api/laporan';

  @override
  void initState() {
    super.initState();
    ambilLaporan();
  }

  Future<void> ambilLaporan() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http
          .get(Uri.parse(apiUrl), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final hasil = jsonDecode(response.body);

        if (hasil is Map && hasil['data'] is List) {
          setState(() {
            daftarLaporan = List<Map<String, dynamic>>.from(hasil['data']);
            isLoading = false;
          });
        } else {
          throw Exception('Format data laporan tidak sesuai.');
        }
      } else {
        throw Exception(
          'Gagal mengambil laporan. Kode: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  String? alamatFoto(dynamic foto) {
    if (foto == null || foto.toString().isEmpty) {
      return null;
    }

    final path = foto.toString();

    if (path.startsWith('http')) {
      return path;
    }

    return 'http://192.168.1.50:8000/storage/$path';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Laporan Masyarakat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: ambilLaporan,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 55, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text(
                      'Gagal mengambil data laporan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: ambilLaporan,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          : daftarLaporan.isEmpty
          ? RefreshIndicator(
              onRefresh: ambilLaporan,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 150),
                  Icon(Icons.inbox_outlined, size: 65, color: Colors.grey),
                  SizedBox(height: 12),
                  Center(child: Text('Belum ada laporan genangan.')),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: ambilLaporan,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: daftarLaporan.length,
                itemBuilder: (context, index) {
                  final laporan = daftarLaporan[index];

                  final foto = alamatFoto(laporan['foto']);
                  final status = laporan['status']?.toString() ?? 'menunggu';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    clipBehavior: Clip.antiAlias,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (foto != null)
                          Image.network(
                            foto,
                            width: double.infinity,
                            height: 190,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 150,
                                color: Colors.grey.shade100,
                                alignment: Alignment.center,
                                child: const Text('Foto tidak dapat dimuat'),
                              );
                            },
                          )
                        else
                          Container(
                            height: 120,
                            width: double.infinity,
                            color: Colors.grey.shade100,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.water_drop_outlined,
                              size: 45,
                              color: Colors.grey,
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Laporan #${laporan['id'] ?? '-'}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text('Lokasi: ${laporan['lokasi'] ?? '-'}'),

                              const SizedBox(height: 6),

                              Text('Latitude: ${laporan['latitude'] ?? '-'}'),

                              Text('Longitude: ${laporan['longitude'] ?? '-'}'),

                              const SizedBox(height: 8),

                              Text(
                                'Tingkat Genangan: ${laporan['tingkat_genangan'] ?? '-'}',
                              ),

                              const SizedBox(height: 8),

                              Text('Deskripsi: ${laporan['deskripsi'] ?? '-'}'),

                              const SizedBox(height: 12),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Status: $status',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
