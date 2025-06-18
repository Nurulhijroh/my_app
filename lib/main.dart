import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_app/screens/home_screen.dart';
import 'package:my_app/screens/settings_screen.dart'; // Pastikan ini mengarah ke file SettingsScreen yang sudah diperbaiki!
import 'package:my_app/screens/daily_prayer_times_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart'; // Diperlukan untuk ChangeNotifierProvider dan Consumer
import 'package:my_app/theme_provider.dart'; // Pastikan path dan nama file ini benar

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(
    ChangeNotifierProvider(
      create:
          (context) =>
              ThemeProvider(), // Pastikan ThemeProvider ada dan extend ChangeNotifier
      child: const MyApp(), // MyApp adalah widget root aplikasi
    ),
  );
}

// MyApp HARUS menjadi StatelessWidget karena tugasnya hanya membungkus MaterialApp dan Consumer.
// Semua logika state (_selectedIndex, _pages, _onItemTapped) dipindahkan ke AppShell.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer digunakan untuk mendengarkan perubahan pada ThemeProvider.
    return Consumer<ThemeProvider>(
      // Ganti 'ThemeProvider' dengan nama variabel yang berbeda (misalnya 'themeProvider' saja),
      // karena 'themeProviderInstance' agak panjang dan biasanya cukup 'themeProvider'.
      // Ini bukan konflik nama, hanya saran penamaan yang lebih umum.
      builder: (context, themeProvider, child) {
        // Perbaikan: Gunakan 'themeProvider' sebagai nama variabel
        return MaterialApp(
          title: 'Pengingat Asrama',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.light, // Penting: Ini untuk tema TERANG
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            // Opsional: Aktifkan Material 3 jika ingin tampilan modern.
            // useMaterial3: true,
            // colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent, brightness: Brightness.light),
          ),
          darkTheme: ThemeData(
            // Ini adalah definisi untuk TEMA GELAP
            primarySwatch:
                Colors.blueGrey, // Warna primer yang berbeda untuk gelap
            brightness: Brightness.dark, // Penting: Ini untuk tema GELAP
            appBarTheme: const AppBarTheme(
              backgroundColor:
                  Colors
                      .blueGrey, // Warna AppBar yang lebih gelap untuk tema gelap
              foregroundColor: Colors.white,
            ),
            // Opsional: Aktifkan Material 3 jika ingin tampilan modern.
            // useMaterial3: true,
            // colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey, brightness: Brightness.dark),
          ),
          // Mengambil themeMode dari instance ThemeProvider.
          themeMode:
              themeProvider.themeMode, // Menggunakan 'themeProvider.themeMode'
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', ''), Locale('id', '')],
          locale: const Locale('id', ''),

          // home menunjuk ke AppShell yang akan menangani Scaffold dan BottomNavigationBar.
          home: const AppShell(), // Pastikan ini const AppShell()
        );
      },
    );
  }
}

// AppShell adalah StatefulWidget yang mengelola state untuk BottomNavigationBar.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState(); // Perbaikan: Typo '_AppShaleState' menjadi '_AppShellState'.
}

// State class untuk AppShell.
class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0; // State untuk mengelola indeks tab yang aktif.

  // Daftar widget/halaman yang akan ditampilkan saat tab dipilih.
  final List<Widget> _pages = const [
    // Perbaikan: Gunakan 'const' karena isi list konstan.
    HomeScreen(),
    DailyPrayerTimesScreen(),
    SettingsScreen(), // Perbaikan: Pastikan ini SettingsScreen() (sesuai nama kelas yang diperbaiki)
  ];

  // Fungsi yang dipanggil saat item di BottomNavigationBar ditekan.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Mengupdate indeks tab yang aktif.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _pages[_selectedIndex], // Menampilkan halaman yang aktif sesuai _selectedIndex.
      bottomNavigationBar: BottomNavigationBar(
        // Ini sudah benar, BottomNavigationBar bukan BottomAppBar.
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings), // Icon Pengaturan
            label: 'Pengaturan', // Label Pengaturan
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor:
            Colors
                .grey, // Opsional: Tambahkan warna untuk item yang tidak dipilih agar lebih terlihat.
        onTap: _onItemTapped,
      ),
    );
  }
}
