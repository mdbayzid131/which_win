import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/race_analysis_controller.dart';

class RaceAnalysisView extends GetView<RaceAnalysisController> {
  const RaceAnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header Section
            Stack(
              children: [
                Container(
                  height: 350.h,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/race_analysis_header.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Get.back(),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: const BoxDecoration(
                                color: Colors.white12,
                                shape: BoxShape.circle,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.r),
                                child: Image.network(
                                  'https://flagcdn.com/w80/gb.png',
                                  width: 24.w,
                                  height: 24.w,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'United Kingdom',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(width: 40.w),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Royal Ascot - Gold Cup',
                          style: TextStyle(color: Colors.white70, fontSize: 16.sp),
                        ),
                        Text(
                          'May 6, 2026 • 15:30',
                          style: TextStyle(color: Colors.white38, fontSize: 12.sp),
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B5E20).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'FINISHED',
                            style: TextStyle(
                              color: const Color(0xFF81C784),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE53935),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.emoji_events_outlined, color: Colors.white, size: 40.sp),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Thunder Bolt',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Jockey: J. Smith',
                          style: TextStyle(color: Colors.white38, fontSize: 14.sp),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Winner - 2:04.32',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Middle Prediction Section
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPredictionCard('1', '90%', true),
                      _buildPredictionCard('X', '75%', false),
                      _buildPredictionCard('2', '70%', false),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildInfoColumn('Which Win Tahmini', '1X'),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF310000),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Riskli Maç',
                                style: TextStyle(color: Colors.red, fontSize: 12.sp),
                              ),
                              Text(
                                '%50',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Güven Seviyesi',
                                style: TextStyle(color: Colors.white24, fontSize: 10.sp),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildInfoColumn(
                          'Program Önerisi',
                          'Beraberlik İhmal edilmemeli',
                          isSmallText: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      _buildActionButton('Maç sonu', true),
                      SizedBox(width: 12.w),
                      _buildActionButton('Racing Details', false),
                    ],
                  ),
                ],
              ),
            ),
            
            // Bottom Analysis Table
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1419),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                children: [
                  Text(
                    'Yapay Zeka Tahmini',
                    style: TextStyle(color: Colors.white38, fontSize: 12.sp),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Evinde', style: _tableHeaderStyle()),
                      const SizedBox(width: 40),
                      Text('Evinde', style: _tableHeaderStyle()),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildAnalysisRow('4', 'Galip', '4'),
                  _buildAnalysisRow('1', 'Berabere', '0'),
                  _buildAnalysisRow('0', 'Mağlup', '1'),
                ],
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  TextStyle _tableHeaderStyle() => TextStyle(
        color: Colors.white,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      );

  Widget _buildPredictionCard(String title, String percent, bool isSelected) {
    return Container(
      width: 110.w,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected ? Colors.orange : Colors.white12,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Icon(
                Icons.star,
                color: index < (isSelected ? 3 : 2) ? Colors.orange : Colors.white12,
                size: 14.sp,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text('Pearl', style: TextStyle(color: Colors.white24, fontSize: 10.sp)),
          Text(
            percent,
            style: TextStyle(
              color: const Color(0xFF4DB6AC),
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value, {bool isSmallText = false}) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSmallText ? Colors.orange.withOpacity(0.7) : Colors.white,
            fontSize: isSmallText ? 11.sp : 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, bool isSelected) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF003D33) : const Color(0xFF003D33),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? const Color(0xFF4DB6AC) : const Color(0xFF4DB6AC),
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisRow(String left, String label, String right) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            left,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.white38, fontSize: 14.sp),
          ),
          Text(
            right,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
