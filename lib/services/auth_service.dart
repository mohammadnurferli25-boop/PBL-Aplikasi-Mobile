// Penyimpanan akun sementara untuk demo.
// Catatan: data ini hanya tersimpan selama aplikasi berjalan.
Map<String, String> akunUsers = {
  'demo@gmail.com': '12345678',
  'admin@genanglapor.com': 'Admin123',
};

Map<String, String> roleUsers = {
  'demo@gmail.com': 'masyarakat',
  'admin@genanglapor.com': 'admin',
};

Map<String, String> akunNama = {
  'demo@gmail.com': 'Pengguna Demo',
  'admin@genanglapor.com': 'Administrator',
};

// Akun pengguna yang sedang login
String? emailPenggunaAktif;
String? rolePenggunaAktif;
