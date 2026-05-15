import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/splash_screen_controller.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            // Logo
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 250,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 60),
            // Progress Bar
            SizedBox(
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  backgroundColor: Color(0xFF2C2C2C),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FFCC)),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Loading Text
            const Text(
              'Veriler Alınıyor...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(flex: 4),
            // Version Text
            const Text(
              'Version: 2.1.8',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
