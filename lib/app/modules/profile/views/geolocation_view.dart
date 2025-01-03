import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

class GetLocationView extends StatefulWidget {
  const GetLocationView({super.key});

  @override
  _GetLocationViewState createState() => _GetLocationViewState();
}

class _GetLocationViewState extends State<GetLocationView> {
  String location = 'Menunggu koordinat...';
  String address = 'Menunggu alamat...';
  String city = 'Malang';
  String country = 'Indonesia';
  String altitude = 'Menunggu elevasi...';
  String accuracy = 'Menunggu akurasi...';
  String timestamp = 'Menunggu waktu...';

  Future<void> openGoogleMaps(double latitude, double longitude) async {
    final Uri url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunch(url.toString())) {
      await launch(url.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps.')),
      );
    }
  }

  Future<void> fetchAltitude(double latitude, double longitude) async {
    final apiKey = 'AlzaSy6s2abq1kMYTvuDcGYaHzBxwzoNemO-lKs';
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/elevation/json?locations=$latitude,$longitude&key=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        setState(() {
          altitude = '${data['results'][0]['elevation']} meters';
        });
      }
    } else {
      setState(() {
        altitude = 'Gagal mengambil elevasi.';
      });
    }
  }

  Future<void> _getUserLocation() async {
    var status = await Permission.location.request();

    if (status.isGranted) {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          location = 'Layanan lokasi tidak aktif.';
        });
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            location = 'Izin lokasi ditolak.';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          location = 'Izin lokasi ditolak secara permanen.';
        });
        return;
      }

      Position position =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      setState(() {
        location = 'Lat: ${position.latitude}, Lng: ${position.longitude}';
        accuracy = 'Akurasi: ${position.accuracy} meter';
        timestamp = 'Waktu: ${DateTime.now().toString()}';
      });

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          city = place.locality ?? 'Tidak ditemukan';
          country = place.country ?? 'Tidak ditemukan';
          address =
              '${place.thoroughfare ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
        });
      }

      fetchAltitude(position.latitude, position.longitude);
    }
  }

  Future openAppSettings() async {
    bool opened = await openAppSettings();
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka pengaturan aplikasi.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Anda', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 255, 255, 255),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.location_on, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              _buildLocationInfo(),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Card(
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(Icons.place, 'Lokasi', location),
            _buildInfoRow(Icons.home, 'Alamat', address),
            _buildInfoRow(Icons.location_city, 'Kota', city),
            _buildInfoRow(Icons.flag, 'Negara', country),
            _buildInfoRow(Icons.speed, 'Akurasi', accuracy),
            _buildInfoRow(Icons.access_time, 'Waktu', timestamp),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            final latLng = location.split(',');
            final lat = double.parse(latLng[0].replaceAll('Lat: ', '').trim());
            final lng = double.parse(latLng[1].replaceAll('Lng: ', '').trim());

            openGoogleMaps(lat, lng);
          },
          icon: const Icon(Icons.map, color: Colors.white),
          label: const Text('Buka di Google Maps', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _getUserLocation,
          icon: const Icon(Icons.refresh, color: Colors.white),
          label: const Text('Perbarui Lokasi', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
        ),
      ],
    );
  }
}
