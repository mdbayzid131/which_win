import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/splash_screen_controller.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121418),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            // Logo with ambient glow
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF10B981).withValues(alpha: 0.18),
                          const Color(0xFF10B981).withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/images/logo.png',
                    width: 250,
                    fit: BoxFit.contain,
                  ),
                ],
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
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Loading Text
            Text(
              'veriler_aliniyor'.tr,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(flex: 4),
            // Version Text
            Obx(() => Text(
              controller.appVersion.value.isNotEmpty
                  ? '${'version'.tr}: ${controller.appVersion.value}'
                  : '${'version'.tr}: ...',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            )),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
