import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/app/routes/app_pages.dart';
import '../controllers/race_analysis_controller.dart';

class RaceAnalysisView extends GetView<RaceAnalysisController> {
  const RaceAnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DB6AC)),
            ),
          );
        }

        final details = controller.raceDetails.value;
        if (details == null) {
          return Center(
            child: Text(
              'failed_load_analysis'.tr,
              style: const TextStyle(color: Colors.white38),
            ),
          );
        }

        final winnerResult = (details.results != null && details.results!.isNotEmpty) ? details.results!.first : null;
        final winnerName = winnerResult?.horse?.name ?? 'Unknown Winner';
        final winnerJockeyName = winnerResult?.jockey?.name ?? 'Unknown Jockey';
        final winnerTime = winnerResult?.time ?? '';

        final country = details.country ?? 'Unknown';
        final flagCode = _getFlagCode(country);
        final dateStr = details.date != null ? details.date!.split('T').first : '';

        final entries = details.entries ?? [];
        final hasTopHorse = entries.isNotEmpty;
        final hasSecondHorse = entries.length > 1;

        final topHorseScore = hasTopHorse ? (entries[0].normalizedScore ?? 0.0) : 0.0;
        final topHorsePlaceProb = hasTopHorse ? (entries[0].placeProb ?? 0.0) : 0.0;
        final secondHorseScore = hasSecondHorse ? (entries[1].normalizedScore ?? 0.0) : 0.0;

        final card1Percent = '${topHorseScore.toInt()}%';
        final cardXPercent = '${(topHorsePlaceProb * 100 * 2.5).clamp(50, 95).toInt()}%';
        final card2Percent = '${secondHorseScore.toInt()}%';

        final topHorseName = hasTopHorse ? (entries[0].horse?.name ?? 'Home') : 'Home';
        final secondHorseName = hasSecondHorse ? (entries[1].horse?.name ?? 'Away') : 'Away';

        final topHorseObj = hasTopHorse ? entries[0].horse : null;
        final secondHorseObj = hasSecondHorse ? entries[1].horse : null;

        final topWins = topHorseObj?.wins ?? 0;
        final topTotal = topHorseObj?.totalRaces ?? 0;
        final topSeconds = topHorseObj?.seconds ?? 0;
        final topLosses = topTotal - topWins - topSeconds;

        final secondWins = secondHorseObj?.wins ?? 0;
        final secondTotal = secondHorseObj?.totalRaces ?? 0;
        final secondSeconds = secondHorseObj?.seconds ?? 0;
        final secondLosses = secondTotal - secondWins - secondSeconds;

        return SingleChildScrollView(
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
                        image: AssetImage(
                          'assets/images/race_analysis_header.png',
                        ),
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
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
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
                                    'https://flagcdn.com/w80/$flagCode.png',
                                    width: 24.w,
                                    height: 24.w,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.grey[900],
                                      child: const Icon(Icons.flag, color: Colors.white24),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                country,
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
                            details.location ?? '',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16.sp,
                            ),
                          ),
                          Text(
                            '$dateStr • ${details.time ?? ''}',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B5E20).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              details.status ?? 'FINISHED',
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
                            child: Icon(
                              Icons.emoji_events_outlined,
                              color: Colors.white,
                              size: 40.sp,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            winnerName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${'jockey'.tr}$winnerJockeyName',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '${'winner_label'.tr} - $winnerTime',
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
                        _buildPredictionCard('1', card1Percent, true),
                        _buildPredictionCard('X', cardXPercent, false),
                        _buildPredictionCard('2', card2Percent, false),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildInfoColumn('which_win_tahmini'.tr, details.tahmin1X ?? '1X'),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFF310000),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'riskli_mac'.tr,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                Text(
                                  '%${details.riskRate ?? 50}',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'guven_seviyesi'.tr,
                                  style: TextStyle(
                                    color: Colors.white24,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: _buildInfoColumn(
                            'program_onerisi'.tr,
                            details.predictionMessage ?? 'program_onerisi_fallback'.tr,
                            isSmallText: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        _buildActionButton('mac_sonu'.tr, true),
                        SizedBox(width: 12.w),
                        _buildActionButton(
                          'racing_details'.tr,
                          false,
                          onTap: () => Get.toNamed(AppRoutes.RACE_DETAILS, arguments: controller.race.value),
                        ),
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
                      'yapay_zeka_tahmini'.tr,
                      style: TextStyle(color: Colors.white38, fontSize: 12.sp),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(child: Text(topHorseName, textAlign: TextAlign.center, style: _tableHeaderStyle())),
                        const SizedBox(width: 10),
                        Expanded(child: Text(secondHorseName, textAlign: TextAlign.center, style: _tableHeaderStyle())),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    _buildAnalysisRow('$topWins', 'galip'.tr, '$secondWins'),
                    _buildAnalysisRow('$topSeconds', 'berabere'.tr, '$secondSeconds'),
                    _buildAnalysisRow('$topLosses', 'maglup'.tr, '$secondLosses'),
                  ],
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        );
      }),
    ),
    );
  }

  String _getFlagCode(String countryName) {
    final c = countryName.toLowerCase();
    if (c.contains('united kingdom') || c.contains('uk') || c.contains('great britain') || c.contains('gb')) {
      return 'gb';
    }
    if (c.contains('france') || c.contains('fr')) {
      return 'fr';
    }
    if (c.contains('turkey') || c.contains('tr') || c.contains('türkiye')) {
      return 'tr';
    }
    if (c.contains('united states') || c.contains('usa') || c.contains('us')) {
      return 'us';
    }
    if (c.contains('ireland') || c.contains('ie')) {
      return 'ie';
    }
    if (c.contains('australia') || c.contains('au')) {
      return 'au';
    }
    return 'tr';
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
                color: index < (isSelected ? 3 : 2)
                    ? Colors.orange
                    : Colors.white12,
                size: 14.sp,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Pearl',
            style: TextStyle(color: Colors.white24, fontSize: 10.sp),
          ),
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

  Widget _buildInfoColumn(
    String title,
    String value, {
    bool isSmallText = false,
  }) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
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

  Widget _buildActionButton(
    String text,
    bool isSelected, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF003D33)
                : const Color(0xFF003D33),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF4DB6AC)
                    : const Color(0xFF4DB6AC),
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
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
