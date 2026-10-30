import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const GenangLaporApp());
}

// ============================================================
// DATA AKUN SEMENTARA
// ============================================================
//
// akun masih disimpan sementara di memory.
// dibagian ini bisa kita ganti dengan Firebase.
// ============================================================

Map<String, String> akunUsers = {
  'demo@gmail.com': '12345678',
  'admin@genanglapor.com': 'Admin123',
};

Map<String, String> roleUsers = {
  'demo@gmail.com': '12345678',
  'admin@genanglapor.com': 'admin',
};

String? emailPenggunaAktif;
String? rolePenggunaAktif;

// ============================================================
// APLIKASI UTAMA
// ============================================================

class GenangLaporApp extends StatelessWidget {
  const GenangLaporApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GenangLapor',

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),

        scaffoldBackgroundColor: const Color(0xFFF5F8FC),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),

      // Halaman pertama yang dibuka
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 25),

              // Logo aplikasi
              const Icon(
                Icons.water_drop_rounded,
                size: 75,
                color: Colors.blue,
              ),

              const SizedBox(height: 12),

              const Text(
                'GenangLapor',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Peduli Genangan, Selamat di Perjalanan',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 35),

              // Sambutan utama
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_searching,
                      color: Colors.white,
                      size: 42,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Kenali Genangan, '
                      'Hindari Risiko!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Bantu masyarakat mengetahui titik '
                      'genangan dan berbagi informasi kondisi '
                      'jalan di sekitar Anda.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Satu aplikasi, banyak manfaat',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              _WelcomeFeature(
                icon: Icons.map_outlined,
                title: 'Lihat Peta',
                description: 'Kenali lokasi titik genangan.',
              ),

              _WelcomeFeature(
                icon: Icons.camera_alt_outlined,
                title: 'Laporkan Genangan',
                description: 'Bagikan foto dan kondisi genangan.',
              ),

              _WelcomeFeature(
                icon: Icons.people_outline,
                title: 'Laporan Masyarakat',
                description: 'Dapatkan informasi dari warga.',
              ),

              const SizedBox(height: 25),

              // Tombol masuk
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Masuk',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Buat Akun Baru'),
              ),

              const SizedBox(height: 20),

              const Text(
                'Bersama kita peduli lingkungan sekitar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Komponen ringkasan fitur di halaman welcome
class _WelcomeFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _WelcomeFeature({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LOGIN PAGE
// ============================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isPasswordHidden = true;
  bool isLoading = false;

  // ==========================================================
  // FUNGSI LOGIN
  // ==========================================================

  void login() async {
    // Cek validasi form
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Simulasi proses login
    await Future.delayed(const Duration(milliseconds: 800));

    String email = emailController.text.trim().toLowerCase();

    String password = passwordController.text;

    if (akunUsers.containsKey(email) && akunUsers[email] == password) {
      emailPenggunaAktif = email;
      rolePenggunaAktif = roleUsers[email] ?? 'masyarakat';
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Login berhasil! Selamat datang.'),
            ],
          ),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Email atau password salah.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ==========================================================
  // TAMPILAN LOGIN
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [
                  // =================================================
                  // LOGO
                  // =================================================

                  Container(
                    width: 90,
                    height: 90,

                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,

                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),

                    child: const Icon(
                      Icons.water_drop,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // =================================================
                  // JUDUL
                  // =================================================
                  const Text(
                    'GenangLapor',
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Laporkan genangan di sekitar Anda',
                    textAlign: TextAlign.center,

                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),

                  const SizedBox(height: 35),

                  // =================================================
                  // CARD LOGIN
                  // =================================================
                  Container(
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(20),

                      border: Border.all(color: Colors.grey.shade200),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text(
                          'Selamat Datang 👋',

                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Silakan masuk untuk melanjutkan.',

                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),

                        const SizedBox(height: 25),

                        // =================================================
                        // EMAIL
                        // =================================================
                        const Text(
                          'Email',

                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextFormField(
                          controller: emailController,

                          keyboardType: TextInputType.emailAddress,

                          decoration: const InputDecoration(
                            hintText: 'Masukkan email Anda',

                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: Colors.blue,
                            ),
                          ),

                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email wajib diisi';
                            }

                            if (!value.contains('@')) {
                              return 'Masukkan email yang valid';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // =================================================
                        // PASSWORD
                        // =================================================
                        const Text(
                          'Password',

                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextFormField(
                          controller: passwordController,

                          obscureText: isPasswordHidden,

                          decoration: InputDecoration(
                            hintText: 'Masukkan password',

                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Colors.blue,
                            ),

                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isPasswordHidden = !isPasswordHidden;
                                });
                              },

                              icon: Icon(
                                isPasswordHidden
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password wajib diisi';
                            }

                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 25),

                        // =================================================
                        // TOMBOL LOGIN
                        // =================================================
                        SizedBox(
                          width: double.infinity,
                          height: 52,

                          child: ElevatedButton(
                            onPressed: isLoading ? null : login,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,

                              foregroundColor: Colors.white,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),

                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,

                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Masuk',

                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // =================================================
                  // REGISTER
                  // =================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      const Text(
                        'Belum punya akun?',

                        style: TextStyle(color: Colors.grey),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },

                        child: const Text(
                          'Daftar',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // =================================================
                  // AKUN DEMO
                  // =================================================
                  Container(
                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,

                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: const Column(
                      children: [
                        Text(
                          'Akun Demo',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          'Email: demo@gmail.com\n'
                          'Password: 12345678',

                          textAlign: TextAlign.center,

                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// REGISTER PAGE
// ============================================================

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;

  // ==========================================================
  // REGISTER
  // ==========================================================

  void register() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    String email = emailController.text.trim().toLowerCase();

    String password = passwordController.text;

    // Cek email sudah digunakan
    if (akunUsers.containsKey(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Email sudah terdaftar.'),
        ),
      );

      return;
    }

    // Simpan akun
    akunUsers[email] = password;
    roleUsers[email] = 'masyarakat';

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text('Akun berhasil dibuat.'),
      ),
    );

    // Kembali ke halaman login
    Navigator.pop(context);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  // ==========================================================
  // TAMPILAN REGISTER
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,

        title: const Text(
          'Daftar Akun',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Form(
            key: formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                // =================================================
                // ICON
                // =================================================

                const Icon(
                  Icons.person_add_alt_1,
                  size: 70,
                  color: Colors.blue,
                ),

                const SizedBox(height: 15),

                const Text(
                  'Buat Akun Baru',

                  textAlign: TextAlign.center,

                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Daftar untuk mulai menggunakan GenangLapor.',

                  textAlign: TextAlign.center,

                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 30),

                // =================================================
                // EMAIL
                // =================================================
                const Text(
                  'Email',

                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: emailController,

                  keyboardType: TextInputType.emailAddress,

                  decoration: const InputDecoration(
                    hintText: 'Masukkan email',

                    prefixIcon: Icon(Icons.email_outlined, color: Colors.blue),
                  ),

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }

                    if (!value.contains('@')) {
                      return 'Masukkan email yang valid';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // =================================================
                // PASSWORD
                // =================================================
                const Text(
                  'Password',

                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: passwordController,

                  obscureText: isPasswordHidden,

                  decoration: InputDecoration(
                    hintText: 'Minimal 6 karakter',

                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.blue,
                    ),

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isPasswordHidden = !isPasswordHidden;
                        });
                      },

                      icon: Icon(
                        isPasswordHidden
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password wajib diisi';
                    }

                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // =================================================
                // KONFIRMASI PASSWORD
                // =================================================
                const Text(
                  'Konfirmasi Password',

                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: confirmPasswordController,

                  obscureText: isConfirmPasswordHidden,

                  decoration: InputDecoration(
                    hintText: 'Masukkan ulang password',

                    prefixIcon: const Icon(
                      Icons.lock_reset_outlined,
                      color: Colors.blue,
                    ),

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isConfirmPasswordHidden = !isConfirmPasswordHidden;
                        });
                      },

                      icon: Icon(
                        isConfirmPasswordHidden
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi password wajib diisi';
                    }

                    if (value != passwordController.text) {
                      return 'Password tidak sama';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // =================================================
                // TOMBOL DAFTAR
                // =================================================
                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: ElevatedButton(
                    onPressed: register,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,

                      foregroundColor: Colors.white,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: const Text(
                      'Daftar',

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // =================================================
                // KEMBALI KE LOGIN
                // =================================================
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text('Sudah punya akun? Masuk'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HOME PAGE / DASHBOARD
// ============================================================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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

class ProfilPage extends StatelessWidget {
  final String email;

  const ProfilPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final String nama = email.split('@').first;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 15),

            // Avatar pengguna
            const CircleAvatar(
              radius: 55,
              backgroundColor: Color(0xFFDCEBFF),
              child: Icon(Icons.person, size: 65, color: Colors.blue),
            ),

            const SizedBox(height: 15),

            Text(
              nama,
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(email, style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 30),

            // Informasi akun
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.person_outline,
                      color: Colors.blue,
                    ),
                    title: const Text('Nama Pengguna'),
                    subtitle: Text(nama),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.email_outlined,
                      color: Colors.blue,
                    ),
                    title: const Text('Email'),
                    subtitle: Text(email),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(
                      Icons.verified_user_outlined,
                      color: Colors.blue,
                    ),
                    title: Text('Status Akun'),
                    subtitle: Text('Pengguna GenangLapor'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Tombol logout
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final bool? keluar = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Keluar dari akun?'),
                      content: const Text(
                        'Apakah kamu yakin ingin keluar '
                        'dari GenangLapor?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext, false);
                          },
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext, true);
                          },
                          child: const Text('Keluar'),
                        ),
                      ],
                    ),
                  );

                  if (keluar == true && context.mounted) {
                    emailPenggunaAktif = null;
                    rolePenggunaAktif = null;

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WelcomePage(),
                      ),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Keluar dari Akun',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
// HALAMAN LAPORKAN GENANGAN
// ============================================================

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
