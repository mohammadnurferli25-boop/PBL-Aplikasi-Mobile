import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'profil_page.dart';
import 'laporkan_genangan_page.dart';
import 'daftar_laporan_page.dart';

class MasyarakatHomePage extends StatelessWidget {
  const MasyarakatHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'GenangLapor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =================================================
            // HEADER
            // =================================================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.blue,

                borderRadius: BorderRadius.circular(20),
              ),

              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    'Halo! 👋',

                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Lapor Titik Genangan\n'
                    'Di Sekitar Anda',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    'Bantu masyarakat mengetahui '
                    'lokasi rawan genangan.',

                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // MENU UTAMA
            // =================================================
            const Text(
              'Menu Utama',

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            // LAPORKAN GENANGAN
            _MenuCard(
              icon: Icons.water_drop,

              title: 'Laporkan Genangan',

              description: 'Laporkan lokasi genangan yang Anda temukan.',

              iconColor: Colors.blue,

              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (context) => const LaporkanGenanganPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // LIHAT PETA
            _MenuCard(
              icon: Icons.map,

              title: 'Lihat Peta',

              description: 'Lihat lokasi genangan yang telah dilaporkan.',

              iconColor: Colors.green,

              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Fitur peta akan dibuat pada tahap berikutnya.',
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // LAPORAN MASYARAKAT
            _MenuCard(
              icon: Icons.people,
              title: 'Laporan Masyarakat',
              description: 'Lihat laporan genangan dari pengguna lain.',
              iconColor: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DaftarLaporanPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            // =================================================
            // LOKASI
            // =================================================
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(16),

                border: Border.all(color: Colors.grey.shade200),
              ),

              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(Icons.location_on, color: Colors.blue),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Gunakan lokasi Anda',

                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'Lokasi digunakan untuk membantu '
                          'menentukan titik genangan secara '
                          'lebih akurat.',

                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // =====================================================
      // NAVIGATION BAR
      // =====================================================
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,

        onDestinationSelected: (index) {
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProfilPage(email: emailPenggunaAktif ?? 'demo@gmail.com'),
              ),
            );
          }
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),

          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Peta',
          ),

          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Laporan',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MENU CARD
// ============================================================
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(16),

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(16),

          border: Border.all(color: Colors.grey.shade200),
        ),

        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,

              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),

                borderRadius: BorderRadius.circular(14),
              ),

              child: Icon(icon, color: iconColor, size: 28),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    description,

                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
