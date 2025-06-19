import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:my_app/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            centerTitle: true,
            backgroundColor: Colors.blueAccent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              ListTile(
                title: const Text('Mode Tema'),
                subtitle: Text(_getThemeModeText(themeProvider.themeMode)),
                trailing: DropdownButton<ThemeMode>(
                  value: themeProvider.themeMode,
                  onChanged: (ThemeMode? newValue) {
                    if (newValue != null) {
                      themeProvider.setThemeMode(newValue);
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
              const Divider(),
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
                    applicationName: 'Waktu Sholat',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2025 @_',
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
    );
  }

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
