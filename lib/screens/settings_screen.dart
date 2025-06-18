import 'package:flutter/material.dart';
// import 'package:my_app/screens/settings_screen.dart'; // <--- BARIS INI HAPUS, INI IMPORT DIRI SENDIRI
import 'package:provider/provider.dart'; // <--- TAMBAH INI
import 'package:my_app/theme_provider.dart'; // <--- TAMBAH INI (pastikan path benar)

// PERHATIKAN: Saya akan mengubah nama kelas dari SettingScreen menjadi SettingsScreen
// Sesuai dengan standar penamaan kelas di Dart/Flutter (PascalCase).
// Juga karena Anda mengimpor 'settings_screen.dart' yang mungkin merujuk pada dirinya sendiri
// atau membuat kebingungan jika ada file lain dengan nama serupa.
class SettingsScreen extends StatelessWidget {
  // <--- UBAH NAMA KELAS DI SINI
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // <--- TAMBAH BAGIAN CONSUMER INI UNTUK MENGAKSES THEMEPROVIDER
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Pengaturan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.blueAccent, // Warna app bar konsisten
            iconTheme: const IconThemeData(
              color: Colors.white,
            ), // Warna icon back
          ),
          body: ListView(
            // <--- UBAH DARI Center ke ListView
            padding: const EdgeInsets.all(16.0),
            children: [
              // Pengaturan Tema: Ini adalah bagian yang Anda inginkan
              ListTile(
                title: const Text('Mode Tema'),
                subtitle: Text(_getThemeModeText(themeProvider.themeMode)),
                trailing: DropdownButton<ThemeMode>(
                  value:
                      themeProvider
                          .themeMode, // Menampilkan nilai tema saat ini
                  onChanged: (ThemeMode? newValue) {
                    // Dipanggil saat pengguna memilih opsi baru
                    if (newValue != null) {
                      themeProvider.setThemeMode(
                        newValue,
                      ); // Mengubah tema melalui ThemeProvider
                    }
                  },
                  items: const <DropdownMenuItem<ThemeMode>>[
                    DropdownMenuItem<ThemeMode>(
                      value: ThemeMode.system,
                      child: Text('Ikuti Sistem'),
                    ),
                    DropdownMenuItem<ThemeMode>(
                      value: ThemeMode.light,
                      child: Text('Terang'),
                    ),
                    DropdownMenuItem<ThemeMode>(
                      value: ThemeMode.dark,
                      child: Text('Gelap'),
                    ),
                  ],
                ),
              ),
              const Divider(), // Garis pemisah
              // Anda bisa menambahkan pengaturan lain di bawah sini
              ListTile(
                title: const Text('Pengaturan Notifikasi'),
                subtitle: const Text('Kelola pengaturan notifikasi Adzan'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur pengaturan notifikasi akan datang!'),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Tentang Aplikasi'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Digital Falak',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2024 Your Company Name',
                    children: [
                      const Text(
                        'Aplikasi ini membantu Anda melacak waktu sholat.',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    ); // <--- AKHIR DARI CONSUMER
  }

  // <--- TAMBAH FUNGSI HELPER INI
  // Fungsi pembantu untuk mendapatkan teks yang sesuai dengan ThemeMode
  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Ikuti Sistem';
      case ThemeMode.light:
        return 'Terang';
      case ThemeMode.dark:
        return 'Gelap';
    }
  }
}
