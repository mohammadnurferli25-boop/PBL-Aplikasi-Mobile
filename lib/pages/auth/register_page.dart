import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

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
