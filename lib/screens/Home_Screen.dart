import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentGregorianDate = '';

  String _currentTime = '';
  String _nextPrayerName = '';
  String _nextPrayerTime = '--:--';
  Duration _timeUntilNextPrayer = Duration.zero;

  Map<String, String> _apiPrayerTimes = {};
  bool _isLoadingPrayerTimes = true;
  String _prayerTimesErrorMessage = '';

  String _currentLocationString = 'Mendeteksi lokasi...';

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateCurrentTime();
    _fetchPrayerTimesFromApi();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCurrentTime();
      _calculateNextPrayer();
    });
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
        'EEEE, d MMMM yyyy',
        'id_ID',
      ).format(now);
    });
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _prayerTimesErrorMessage = 'Layanan lokasi dinonaktifkan.';
        _isLoadingPrayerTimes = false;
        _currentLocationString = 'Layanan lokasi dinonaktifkan.';
      });
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _prayerTimesErrorMessage = 'Izin lokasi ditolak.';
          _isLoadingPrayerTimes = false;
          _currentLocationString = 'Izin lokasi ditolak.';
        });
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _prayerTimesErrorMessage =
            'Izin lokasi ditolak secara permanen. Mohon aktifkan di pengaturan aplikasi.';
        _isLoadingPrayerTimes = false;
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
        _prayerTimesErrorMessage = 'Gagal mendapatkan lokasi: $e';
        _isLoadingPrayerTimes = false;
        _currentLocationString = 'Gagal mendapatkan lokasi.';
      });
      return null;
    }
  }

  Future<void> _fetchPrayerTimesFromApi() async {
    setState(() {
      _isLoadingPrayerTimes = true;
      _prayerTimesErrorMessage = '';
      _apiPrayerTimes = {};
    });

    Position? position = await _getCurrentLocation();
    if (position == null) {
      return;
    }

    final double latitude = position.latitude;
    final double longitude = position.longitude;
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
            _apiPrayerTimes = Map<String, String>.from(data['data']['timings']);
            _isLoadingPrayerTimes = false;
            _calculateNextPrayer();
          });
        } else {
          setState(() {
            _prayerTimesErrorMessage =
                'Gagal mengambil data sholat: ${data['status']}';
            _isLoadingPrayerTimes = false;
          });
        }
      } else {
        setState(() {
          _prayerTimesErrorMessage =
              'Gagal terhubung ke server API. Status Code: ${response.statusCode}';
          _isLoadingPrayerTimes = false;
        });
      }
    } catch (e) {
      setState(() {
        _prayerTimesErrorMessage = 'Terjadi kesalahan jaringan: $e';
        _isLoadingPrayerTimes = false;
      });
    }
  }

  void _calculateNextPrayer() {
    if (_apiPrayerTimes.isEmpty) {
      setState(() {
        _nextPrayerName = 'Tidak Ada Data Sholat';
        _nextPrayerTime = '--:--';
        _timeUntilNextPrayer = Duration.zero;
      });
      return;
    }

    final now = DateTime.now();
    DateTime? nextPrayerDateTime;
    String nextPrayerName = 'Tidak Ada Sholat Berikutnya';

    final List<String> prayerOrder = [
      'Fajr',
      'Sunrise',
      'Dhuhr',
      'Asr',
      'Maghrib',
      'Isha',
    ];

    Duration shortestDuration = Duration(days: 365);

    for (var prayer in prayerOrder) {
      if (_apiPrayerTimes.containsKey(prayer)) {
        final timeString = _apiPrayerTimes[prayer]!;

        String cleanedTimeString = timeString.split(' ')[0];
        final cleanedParts = cleanedTimeString.split(':');

        if (cleanedParts.length == 2) {
          final hour = int.tryParse(cleanedParts[0]);
          final minute = int.tryParse(cleanedParts[1]);

          if (hour != null && minute != null) {
            DateTime prayerTime = DateTime(
              now.year,
              now.month,
              now.day,
              hour,
              minute,
            );

            if (prayerTime.isBefore(now)) {
              prayerTime = prayerTime.add(const Duration(days: 1));
            }

            final duration = prayerTime.difference(now);

            if (!duration.isNegative && duration < shortestDuration) {
              shortestDuration = duration;
              nextPrayerDateTime = prayerTime;
              nextPrayerName = _getIndonesianPrayerName(prayer);
            }
          }
        }
      }
    }

    setState(() {
      if (nextPrayerDateTime != null) {
        _timeUntilNextPrayer = shortestDuration;
        _nextPrayerName = nextPrayerName;
        _nextPrayerTime = DateFormat('HH:mm').format(nextPrayerDateTime);
      } else {
        _nextPrayerName = 'Tidak Ada Sholat Berikutnya';
        _nextPrayerTime = '--:--';
        _timeUntilNextPrayer = Duration.zero;
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Digital Falak ',
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
                  _currentLocationString,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      body:
          _isLoadingPrayerTimes && _apiPrayerTimes.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _prayerTimesErrorMessage.isNotEmpty
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
                        _prayerTimesErrorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _fetchPrayerTimesFromApi,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _currentGregorianDate,
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
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
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
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                            ),
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

                    ..._buildPrayerTimeList(_apiPrayerTimes),
                    const SizedBox(height: 20),
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
          _buildPrayerTimeItem(
            name,
            timings[name]!,
            isNext: _getIndonesianPrayerName(name) == _nextPrayerName,
          ),
        );
      }
    }
    return items;
  }

  Widget _buildPrayerTimeItem(
    String prayerName,
    String time, {
    bool isNext = false,
  }) {
    String displayPrayerName = _getIndonesianPrayerName(prayerName);

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
              time.split(' ')[0],
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
