import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../masyarakat/masyarakat_home_page.dart';
import 'register_page.dart';

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
        MaterialPageRoute(builder: (context) => const MasyarakatHomePage()),
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
