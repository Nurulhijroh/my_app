import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class DailyPrayerTimesScreen extends StatefulWidget {
  const DailyPrayerTimesScreen({super.key});

  @override
  State<DailyPrayerTimesScreen> createState() => _DailyPrayerTimesScreenState();
}

class _DailyPrayerTimesScreenState extends State<DailyPrayerTimesScreen> {
  Map<String, dynamic>? _prayerData;
  bool _isLoading = true;
  String _errorMessage = '';
  String _currentLocationString = 'Mendeteksi lokasi...';

  @override
  void initState() {
    super.initState();
    _fetchDailyPrayerTimes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _errorMessage = 'Layanan lokasi dinonaktifkan.';
        _isLoading = false;
        _currentLocationString = 'Layanan lokasi dinonaktifkan.';
      });
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = 'Izin lokasi ditolak.';
          _isLoading = false;
          _currentLocationString = 'Izin lokasi ditolak.';
        });
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage =
            'Izin lokasi ditolak secara permanen. Mohon aktifkan di pengaturan aplikasi.';
        _isLoading = false;
        _currentLocationString = 'Izin lokasi ditolak secara permanen.';
      });
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocationString =
            'Lokasi: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      });
      return position;
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mendapatkan lokasi: $e';
        _isLoading = false;
        _currentLocationString = 'Gagal mendapatkan lokasi.';
      });
      return null;
    }
  }

  Future<void> _fetchDailyPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    Position? position = await _getCurrentLocation();
    if (position == null) {
      return;
    }

    final double latitude = -6.2088;
    final double longitude = 106.8456;
    final String method = '5';
    final String date = DateFormat('dd-MM-yyyy').format(DateTime.now());

    final url = Uri.parse(
      'http://api.aladhan.com/v1/timings/$date?latitude=$latitude&longitude=$longitude&method=$method',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['code'] == 200 && data['status'] == 'OK') {
          setState(() {
            _prayerData = data['data'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage =
                'Gagal mengambil data waktu sholat: ${data['status']}';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Gagal terhubung ke server API. Status Code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan jaringan: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jadwal Sholat ',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF006C4C),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchDailyPrayerTimes,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _fetchDailyPrayerTimes,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              )
              : _prayerData == null
              ? const Center(
                child: Text('Tidak ada data waktu sholat tersedia.'),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ' ${_prayerData!['date']['readable'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      ' '
                      '${_prayerData!['date']['hijri']?['day'] ?? 'N/A'} '
                      '${_prayerData!['date']['hijri']?['month']?['en'] ?? 'N/A'} '
                      '${_prayerData!['date']['hijri']?['year'] ?? 'N/A'} H',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      _currentLocationString,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ..._buildPrayerTimeList(_prayerData!['timings']),
                  ],
                ),
              ),
    );
  }

  List<Widget> _buildPrayerTimeList(Map<String, dynamic> timings) {
    final List<String> prayerNames = [
      'Fajr',
      'Sunrise',
      'Dhuhr',
      'Asr',
      'Maghrib',
      'Isha',
      'Imsak',
      'Midnight',
    ];
    List<Widget> items = [];

    for (var name in prayerNames) {
      if (timings.containsKey(name)) {
        items.add(
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getIndonesianPrayerName(name),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    timings[name],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006C4C),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    return items;
  }

  String _getIndonesianPrayerName(String englishName) {
    switch (englishName) {
      case 'Fajr':
        return 'Subuh';
      case 'Dhuhr':
        return 'Dzuhur';
      case 'Asr':
        return 'Ashar';
      case 'Maghrib':
        return 'Maghrib';
      case 'Isha':
        return 'Isya';
      case 'Sunrise':
        return 'Terbit';
      case 'Imsak':
        return 'Imsak';
      case 'Midnight':
        return 'Tengah Malam';
      default:
        return englishName;
    }
  }
}
