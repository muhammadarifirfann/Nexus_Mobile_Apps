import 'package:education_apps/app/modules/Onboboarding/onboarding_view.dart';
import 'package:education_apps/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreenView extends StatefulWidget {
  @override
  _LoadingScreenViewState createState() => _LoadingScreenViewState();
}

class _LoadingScreenViewState extends State<LoadingScreenView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Membuat AnimationController untuk animasi pop-up
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    // Membuat animasi skala (scale)
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    // Memulai animasi
    _controller.forward();

    // Menunggu 3 detik sebelum memeriksa status login
    Future.delayed(Duration(seconds: 3), () async {
      // Periksa status login
      await _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // Jika sudah login, pindah ke MainPage
      Get.off(() => MainPage());
    } else {
      // Jika belum login, pindah ke OnboardingView
      Get.off(() => OnboardingView());
    }
  }

  @override
  void dispose() {
    // Jangan lupa untuk membersihkan controller agar tidak menyebabkan memory leak
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background warna putih
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation, // Menggunakan animasi skala
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Menambahkan gambar logo
              Image.asset(
                'assets/icon/img/nexus.png',
                width: 150,
                height: 150,
              ),
              SizedBox(height: 20),
              // Indikator loading
            ],
          ),
        ),
      ),
    );
  }
}
