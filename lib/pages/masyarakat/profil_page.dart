import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../auth/welcome_page.dart';

class ProfilPage extends StatefulWidget {
  final String email;

  const ProfilPage({super.key, required this.email});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController namaController;
  late TextEditingController emailController;

  final passwordLamaController = TextEditingController();
  final passwordBaruController = TextEditingController();
  final konfirmasiPasswordController = TextEditingController();

  bool isEditing = false;
  bool tampilPasswordLama = false;
  bool tampilPasswordBaru = false;
  bool tampilKonfirmasiPassword = false;

  late String emailAwal;
  late String namaAwal;

  @override
  void initState() {
    super.initState();

    emailAwal = emailPenggunaAktif ?? widget.email;

    namaAwal = akunNama[emailAwal] ?? emailAwal.split('@').first;

    namaController = TextEditingController(text: namaAwal);
    emailController = TextEditingController(text: emailAwal);
  }

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    passwordLamaController.dispose();
    passwordBaruController.dispose();
    konfirmasiPasswordController.dispose();
    super.dispose();
  }

  void mulaiEdit() {
    setState(() {
      isEditing = true;
    });
  }

  void resetForm() {
    namaController.text = namaAwal;
    emailController.text = emailAwal;

    passwordLamaController.clear();
    passwordBaruController.clear();
    konfirmasiPasswordController.clear();
  }

  Future<void> batalEdit() async {
    final bool? batal = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batalkan perubahan?'),
        content: const Text(
          'Semua perubahan yang belum disimpan '
          'akan dibatalkan. Apakah kamu yakin?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (batal == true && mounted) {
      setState(() {
        resetForm();
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perubahan berhasil dibatalkan.')),
      );
    }
  }

  Future<void> simpanPerubahan() async {
    if (!_formKey.currentState!.validate()) return;

    final namaBaru = namaController.text.trim();
    final emailBaru = emailController.text.trim().toLowerCase();

    final passwordLama = passwordLamaController.text;
    final passwordBaru = passwordBaruController.text;
    final konfirmasiPassword = konfirmasiPasswordController.text;

    // Periksa apakah email digunakan akun lain.
    if (emailBaru != emailAwal && akunUsers.containsKey(emailBaru)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email sudah digunakan akun lain.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Password baru bersifat opsional.
    final inginGantiPassword =
        passwordLama.isNotEmpty ||
        passwordBaru.isNotEmpty ||
        konfirmasiPassword.isNotEmpty;

    if (inginGantiPassword) {
      if (passwordLama.isEmpty ||
          passwordBaru.isEmpty ||
          konfirmasiPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lengkapi semua kolom password.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (akunUsers[emailAwal] != passwordLama) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password lama tidak sesuai.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (passwordBaru.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password baru minimal 8 karakter.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (passwordBaru != konfirmasiPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konfirmasi password tidak cocok.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Konfirmasi sebelum menyimpan.
    final bool? simpan = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Simpan perubahan?'),
        content: const Text(
          'Apakah kamu yakin ingin menyimpan '
          'perubahan profil ini?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Periksa Lagi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (simpan != true || !mounted) return;

    // Simpan perubahan nama.
    akunNama[emailBaru] = namaBaru;

    // Pindahkan data akun jika email berubah.
    if (emailBaru != emailAwal) {
      final passwordSaatIni = akunUsers.remove(emailAwal);
      final roleSaatIni = roleUsers.remove(emailAwal);

      if (passwordSaatIni != null) {
        akunUsers[emailBaru] = passwordSaatIni;
      }

      if (roleSaatIni != null) {
        roleUsers[emailBaru] = roleSaatIni;
      }

      akunNama.remove(emailAwal);

      if (emailPenggunaAktif == emailAwal) {
        emailPenggunaAktif = emailBaru;
      }
    }

    // Simpan password baru jika diminta.
    if (inginGantiPassword) {
      akunUsers[emailBaru] = passwordBaru;
    }

    setState(() {
      emailAwal = emailBaru;
      namaAwal = namaBaru;

      emailPenggunaAktif = emailBaru;

      resetForm();
      isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil berhasil diperbarui!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget inputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    String? Function(String?)? validator,
    bool obscureText = false,
    VoidCallback? toggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        suffixIcon: toggleVisibility == null
            ? null
            : IconButton(
                onPressed: toggleVisibility,
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                ),
              ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 15),

              const Center(
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Color(0xFFDCEBFF),
                  child: Icon(Icons.person, size: 65, color: Colors.blue),
                ),
              ),

              const SizedBox(height: 15),

              Center(
                child: Text(
                  namaAwal,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Center(
                child: Text(
                  emailAwal,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Informasi Pengguna',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              inputField(
                label: 'Nama Pengguna',
                controller: namaController,
                icon: Icons.person_outline,
                readOnly: !isEditing,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama pengguna tidak boleh kosong.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              inputField(
                label: 'Email',
                controller: emailController,
                icon: Icons.email_outlined,
                readOnly: !isEditing,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email tidak boleh kosong.';
                  }

                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Format email tidak valid.';
                  }

                  return null;
                },
              ),

              if (isEditing) ...[
                const SizedBox(height: 30),

                const Text(
                  'Ganti Password',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Kosongkan semua kolom password jika '
                  'tidak ingin menggantinya.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),

                const SizedBox(height: 15),

                inputField(
                  label: 'Password Lama',
                  controller: passwordLamaController,
                  icon: Icons.lock_outline,
                  obscureText: !tampilPasswordLama,
                  toggleVisibility: () {
                    setState(() {
                      tampilPasswordLama = !tampilPasswordLama;
                    });
                  },
                ),

                const SizedBox(height: 15),

                inputField(
                  label: 'Password Baru',
                  controller: passwordBaruController,
                  icon: Icons.lock_reset,
                  obscureText: !tampilPasswordBaru,
                  toggleVisibility: () {
                    setState(() {
                      tampilPasswordBaru = !tampilPasswordBaru;
                    });
                  },
                ),

                const SizedBox(height: 15),

                inputField(
                  label: 'Konfirmasi Password Baru',
                  controller: konfirmasiPasswordController,
                  icon: Icons.verified_user_outlined,
                  obscureText: !tampilKonfirmasiPassword,
                  toggleVisibility: () {
                    setState(() {
                      tampilKonfirmasiPassword = !tampilKonfirmasiPassword;
                    });
                  },
                ),
              ],

              const SizedBox(height: 30),

              if (!isEditing)
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: mulaiEdit,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
              else ...[
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: simpanPerubahan,
                    icon: const Icon(Icons.save),
                    label: const Text('Simpan Perubahan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: batalEdit,
                    icon: const Icon(Icons.close),
                    label: const Text('Batalkan Perubahan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              SizedBox(
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

                    if (!mounted) return;

                    if (keluar == true) {
                      emailPenggunaAktif = null;
                      rolePenggunaAktif = null;

                      Navigator.pushAndRemoveUntil(
                        this.context,
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
      ),
    );
  }
}
