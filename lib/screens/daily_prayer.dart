import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class DailyPrayerTimesScreen extends StatefulWidget {
  const DailyPrayerTimesScreen({super.key});

  @override
  State<DailyPrayerTimesScreen> createState() => _DailyPrayerTimesScreenState();
}

class _DailyPrayerTimesScreenState extends State<DailyPrayerTimesScreen> {
  Map<String, dynamic>? _prayerData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDailyPrayerTimes();
  }

  Future<void> _fetchDailyPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _prayerData = null;
    });

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

        if (data['code'] == 200 &&
            data['status'] == 'OK' &&
            data['data'] != null) {
          setState(() {
            _prayerData = data['data'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage =
                'Gagal mengambil waktu sholat: ${data['status'] ?? 'Status tidak diketahui'}';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Gagal Terhubung. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Kesalahan Jaringan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _getIndonesianPrayerName(String englishName) {
    switch (englishName) {
      case 'Fajr':
        return 'Subuh';
      case 'Sunrise':
        return 'Terbit';
      case 'Dhuhr':
        return 'Dzuhur';
      case 'Asr':
        return 'Ashar';
      case 'Sunset':
        return 'Maghrib (Sunset)';
      case 'Maghrib':
        return 'Maghrib';
      case 'Isha':
        return 'Isya';
      case 'Imsak':
        return 'Imsak';
      case 'Midnight':
        return 'Tengah Malam';
      default:
        return englishName;
    }
  }

  List<Widget> _buildPrayerTimeList(Map<String, dynamic> timings) {
    final List<String> prayerOrder = [
      'Imsak',
      'Fajr',
      'Sunrise',
      'Dhuhr',
      'Asr',
      'Sunset',
      'Maghrib',
      'Isha',
      'Midnight',
    ];

    List<Widget> items = [];

    for (var name in prayerOrder) {
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
                    timings[name].toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jadwal Sholat Harian',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
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
                        child: const Text('Coba Lagi !!'),
                      ),
                    ],
                  ),
                ),
              )
              : _prayerData == null ||
                  _prayerData!['timings'] == null ||
                  _prayerData!['timings'].isEmpty
              ? const Center(
                child: Text('Tidak ada waktu sholat yang tersedia.'),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal Masehi: ${_prayerData!['date']?['readable'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Tanggal Hijriah: ${_prayerData!['date']?['hijriah']?['day']}/${_prayerData!['date']?['hijriah']?['month']?['number']}/${_prayerData!['date']?['hijriah']?['year']} (${_prayerData!['date']?['hijriah']?['month']?['en']} - ${_prayerData!['date']?['hijriah']?['month']?['ar']})',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Text(
                      'Lokasi: Lat ${_prayerData!['meta']?['latitude']}, Lon ${_prayerData!['meta']?['longitude']}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    ..._buildPrayerTimeList(_prayerData!['timings']),
                  ],
                ),
              ),
    );
  }
}
