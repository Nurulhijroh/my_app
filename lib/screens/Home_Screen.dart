import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentGregorianDate = '';
  String _currentHijriDate = '';
  String _currentTime = '';
  String _nextPrayerName = 'Loading...';
  String _nextPrayerTime = '--:--';
  Duration _timeUntilNextPrayer = Duration.zero;

  final Map<String, String> _prayerTimes = {
    'Fajar': '04:45',
    'sunrise': '06:05',
    'duhur': '12:00',
    'ashar': '14:47',
    'Magrib': '17:19',
    'isya': '18:30',
    'subuh': '04:50',
  };

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateCurrentTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCurrentTime();
      _calculateNextPrayer();
    });

    TODO:
    _calculateNextPrayer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateCurrentTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(now);
      _currentGregorianDate = DateFormat(
        'EEE, d MMMM YYYY',
        'id_ID',
      ).format(now);
      _currentHijriDate = 'Loading Hijri Date...';
    });
  }

  void _calculateNextPrayer() {
    final now = DateTime.now();
    DateTime? nextPrayerDateTime;
    String nextPrayerName = 'Loading...';

    final List<String> prayerOrder = [
      'Fajar',
      'Sunrise',
      'Duhur',
      'Asar',
      'Maghrib',
      'Isya',
      'subuh',
    ];

    for (var prayer in prayerOrder) {
      if (_prayerTimes.containsKey(prayer)) {
        final timeString = _prayerTimes[prayer]!;
        final parts = timeString.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]);
          final minute = int.tryParse(parts[1]);

          if (hour != null && minute != null) {
            final prayerTime = DateTime(
              now.year,
              now.month,
              now.day,
              hour,
              minute,
            );

            if (prayerTime.isAfter(now)) {
              nextPrayerDateTime = prayerTime;
              nextPrayerName = prayer;
              break;
            }
          }
        }
      }
    }

    if (nextPrayerDateTime != null) {
      _timeUntilNextPrayer = nextPrayerDateTime.difference(now);
      _nextPrayerName = nextPrayerName;
      _nextPrayerTime = DateFormat('HH:mm').format(nextPrayerDateTime);
    } else {
      _nextPrayerName = 'Tidak Ada Sholat Berikutnya';
      _nextPrayerTime = '--:--';
      _timeUntilNextPrayer = Duration.zero;
    }
    setState(() {});
  }

  //TODO :
  // Future<void> _fetchPrayerTimesFromApi() async {
  //   // Contoh URL (perlu disesuaikan dengan koordinat atau kota asramamu)
  //   // final String apiUrl = 'https://api.aladhan.com/v1/timingsByCity/15-06-2025?city=Jakarta&country=Indonesia&method=11'; // method 11 = Kemenag RI
  //   // final response = await http.get(Uri.parse(apiUrl));
  //   // if (response.statusCode == 200) {
  //   //   final data = jsonDecode(response.body);
  //   //   setState(() {
  //   //     _prayerTimes = Map<String, String>.from(data['data']['timings']);
  //   //     _calculateNextPrayer(); // Hitung ulang setelah data API didapat
  //   //   });
  //   // } else {
  //   //   // Handle error
  //   //   print('Failed to load prayer times: ${response.statusCode}');
  //   // }
  // }

  // TODO: Fungsi untuk mengambil tanggal Hijriyah dari Aladhan API (akan diimplementasikan nanti)
  // Future<void> _fetchHijriDateFromApi() async {
  //   // final String apiUrl = 'https://api.aladhan.com/v1/gregorianToHijri?date=${DateFormat('dd-MM-yyyy').format(DateTime.now())}';
  //   // final response = await http.get(Uri.parse(apiUrl));
  //   // if (response.statusCode == 200) {
  //   //   final data = jsonDecode(response.body);
  //   //   setState(() {
  //   //     final hijri = data['data']['hijri'];
  //   //     _currentHijriDate = '${hijri['day']} ${hijri['month']['en']} ${hijri['year']} H';
  //   //   });
  //   // } else {
  //   //   print('Failed to load Hijri date: ${response.statusCode}');
  //   // }
  // }

  @override
  Widget build(BuildContext context) {
    // TODO: implement ==
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Digital Falak KW hehe',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white),
                Text(
                  'Asrama UIM',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _currentGregorianDate,
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            Text(
              _currentHijriDate,
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            Text(
              _currentTime,
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withAlpha((255 * 0.1).round()),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Waktu sholat berikutnya:',
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _nextPrayerName,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent.shade700,
                    ),
                  ),
                  Text(
                    '$_nextPrayerTime WIB',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.blueAccent.shade700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tersisa ${NumberFormat('00').format(_timeUntilNextPrayer.inHours % 24)}:'
                    '${NumberFormat('00').format(_timeUntilNextPrayer.inMinutes % 60)}:'
                    '${NumberFormat('00').format(_timeUntilNextPrayer.inSeconds % 60)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Jadwal sholat Hari ini ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 15),
            ..._prayerTimes.entries.map((entry) {
              final isNext = _nextPrayerName == entry.key;
              return _buildPrayerTimeItem(
                entry.key,
                entry.value,
                isNext: isNext,
              );
            }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimeItem(
    String prayerName,
    String time, {
    bool isNext = false,
  }) {
    String displayPrayerName = prayerName;
    switch (prayerName) {
      case 'fajar':
        displayPrayerName = 'subuh';
        break;
      case 'sunrise':
        displayPrayerName = 'terbit';
        break;
      case 'duhur':
        displayPrayerName = 'duhur';
        break;
      case 'ashar':
        displayPrayerName = 'ashar';
        break;
      case 'maghrib':
        displayPrayerName = 'maghrib';
        break;
      case 'isya':
        displayPrayerName = 'isya';
        break;
      case 'imsak':
        displayPrayerName = 'imsak';
        break;
      case 'midnight':
        displayPrayerName = 'midnight';
        break;
    }

    return Card(
      elevation: isNext ? 4 : 1,
      color: isNext ? Colors.blueAccent.shade100 : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              displayPrayerName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                color: isNext ? Colors.blueAccent.shade700 : Colors.black87,
              ),
            ),
            Text(
              time,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                color: isNext ? Colors.blueAccent.shade700 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
