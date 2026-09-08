import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/app/modules/race_details/controllers/race_details_controller.dart';
import 'package:which_win/data/models/race_details_model.dart';
import 'package:which_win/core/utils/helpers.dart';

class PremiumLockOverlay extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;

  const PremiumLockOverlay({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE6A817), Color(0xFFCC8800)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                color: Colors.black87,
                size: 30.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              description,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12.sp,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: () => showPremiumPrompt(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE6A817), Color(0xFFCC8800)],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '✦  ${'upgrade_to_premium'.tr}',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LockedCard extends StatelessWidget {
  final Widget card;

  const LockedCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IgnorePointer(child: Opacity(opacity: 0.2, child: card)),
        Positioned.fill(
          child: GestureDetector(
            onTap: () => showPremiumPrompt(context),
            child: Container(
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFE6A817).withValues(alpha: 0.2),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: const Color(0xFFE6A817),
                      size: 16.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'premium_only'.tr,
                      style: TextStyle(
                        color: const Color(0xFFE6A817),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

void showPremiumPrompt(BuildContext context) {
  Get.bottomSheet(
    Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        border: Border.all(
          color: const Color(0xFF2DD4BF).withValues(alpha: 0.2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: const Color(0xFF2DD4BF).withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2DD4BF).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                color: const Color(0xFF2DD4BF),
                size: 32.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Unlock Premium Access',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Unlock advanced AI analytics, win probabilities,\nfair odds, and daily horse ratings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 13.sp,
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: () {
                Get.back();
                Get.toNamed('/subscription');
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2DD4BF), Color(0xFF0D9488)],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2DD4BF).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'View Plans',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF0F1419),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Maybe Later',
                style: TextStyle(color: Colors.white38, fontSize: 13.sp),
              ),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

void showHorseDetails(
  BuildContext context,
  String horseName,
  int hpVal,
  RaceDetailsController controller, {
  RaceEntry? entry,
}) {
  Get.bottomSheet(
    Obx(() {
      if (controller.isHorseLoading.value) {
        return Container(
          height: Get.height * 0.88,
          decoration: BoxDecoration(
            color: const Color(0xFF14171F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            border: Border.all(color: Colors.white24),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
            ),
          ),
        );
      }

      final horse = controller.horseDetails.value;
      if (horse == null && entry?.horse == null) {
        return Container(
          height: Get.height * 0.88,
          decoration: BoxDecoration(
            color: const Color(0xFF14171F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            border: Border.all(color: Colors.white24),
          ),
          child: Center(
            child: Text(
              'failed_load_details'.tr,
              style: TextStyle(color: Colors.white60, fontSize: 14.sp),
            ),
          ),
        );
      }

      final activeHorse = horse ?? entry?.horse;
      final displayName = (activeHorse?.name ?? horseName).toUpperCase();
      final age = activeHorse?.age != null
          ? '${activeHorse!.age}yo'
          : (entry?.horse?.age != null ? '${entry!.horse!.age}yo' : '');
      final color = activeHorse?.color ?? entry?.horse?.color ?? '';
      final sex = activeHorse?.sex ?? entry?.horse?.sex ?? '';
      final jockey = entry?.jockeyName ?? 'N/A';
      final weight = entry?.weight != null
          ? '${entry!.weight!.toStringAsFixed(0)} kg'
          : 'N/A';
      final hp = hpVal > 0
          ? hpVal
          : (entry?.horsePower?.toInt() ??
              entry?.normalizedScore?.toInt() ??
              0);

      final wins = activeHorse?.wins ?? 0;
      final seconds = activeHorse?.seconds ?? 0;
      final thirds = activeHorse?.thirds ?? 0;
      final totalRaces = activeHorse?.totalRaces ?? 0;
      final winRate = totalRaces > 0
          ? ((wins / totalRaces) * 100).toStringAsFixed(0)
          : '0';
      final top3Rate = totalRaces > 0
          ? (((wins + seconds + thirds) / totalRaces) * 100).toStringAsFixed(0)
          : '0';

      final results = activeHorse?.results ?? [];
      final totalEarnings = activeHorse?.totalEarnings ?? 0.0;
      final earningsText = totalEarnings > 0
          ? Helpers.formatCurrency(totalEarnings)
          : 'N/A';
      final formStr = (entry?.form != null &&
              entry!.form != 'N/A' &&
              entry!.form!.isNotEmpty)
          ? entry!.form!
          : (results.isNotEmpty
              ? results.take(6).map((r) => '${r.position ?? "-"}').join('-')
              : '0-0-0-0');

      return Container(
        height: Get.height * 0.88,
        decoration: BoxDecoration(
          color: const Color(0xFF14171F),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          border: Border.all(color: Colors.white24, width: 0.8),
        ),
        child: Column(
          children: [
            // Top Drag Handle & Close Row
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 12.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white60, size: 22.sp),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Horse Main Header Card (like Middle screen)
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C212B),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Number / Index Badge
                              if (entry?.number != null || entry?.draw != null)
                                Container(
                                  width: 28.w,
                                  height: 28.w,
                                  margin: EdgeInsets.only(right: 10.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6.r),
                                    border: Border.all(
                                      color: const Color(0xFF10B981)
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${entry?.number ?? entry?.draw}',
                                    style: TextStyle(
                                      color: const Color(0xFF10B981),
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  displayName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            '$age $color $sex · $weight · ${'jockey'.tr}$jockey',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          // Key Metrics Row: Race Weight & HP | Earnings
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF242A36),
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.08)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'race_weight_hp'.tr,
                                        style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 10.sp),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        '$weight · $hp HP',
                                        style: TextStyle(
                                          color: const Color(0xFF10B981),
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF242A36),
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.08)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'horse_earnings'.tr,
                                        style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 10.sp),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        earningsText,
                                        style: TextStyle(
                                          color: Colors.amber,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 14.h),

                    // PEDİGRİ VE EKİP (Pedigree & Team)
                    _buildProfileSectionCard(
                      title: 'pedigree_team'.tr.toUpperCase(),
                      iconColor: Colors.amber,
                      children: [
                        _buildProfileInfoLine(
                          '${'sire'.tr}: ${activeHorse?.sireName ?? "N/A"} · ${'dam'.tr}: ${activeHorse?.damName ?? "N/A"}',
                        ),
                        if (activeHorse?.damSireName != null &&
                            activeHorse!.damSireName!.isNotEmpty &&
                            activeHorse!.damSireName != 'N/A') ...[
                          SizedBox(height: 4.h),
                          _buildProfileInfoLine(
                            '${'dam_sire'.tr}: ${activeHorse!.damSireName}',
                          ),
                        ],
                        SizedBox(height: 4.h),
                        _buildProfileInfoLine(
                          '${'trainer'.tr}: ${activeHorse?.trainer ?? entry?.trainerName ?? "N/A"} · ${'owner'.tr}: ${activeHorse?.owner ?? entry?.ownerName ?? "N/A"}',
                        ),
                      ],
                    ),

                    SizedBox(height: 14.h),

                    // KARİYER PERFORMANSI (Career Performance)
                    _buildProfileSectionCard(
                      title: 'career_performance'.tr.toUpperCase(),
                      iconColor: const Color(0xFF10B981),
                      children: [
                        _buildProfileInfoLine(
                          '${'total_starts'.tr}: $totalRaces · ${'wins_1st'.tr}: $wins · ${'places_2_3'.tr}: ${seconds + thirds}',
                        ),
                        SizedBox(height: 4.h),
                        _buildProfileInfoLine(
                          '${'win_rate'.tr}: $winRate% · ${'place_rate'.tr}: $top3Rate%',
                        ),
                        SizedBox(height: 4.h),
                        _buildProfileInfoLine(
                          '${'career_form'.tr}: $formStr',
                        ),
                      ],
                    ),

                    SizedBox(height: 14.h),

                    // SON KOŞULARI (Recent Races - Last 6 Table)
                    _buildProfileSectionCard(
                      title: 'recent_races_history'.tr,
                      iconColor: Colors.cyanAccent,
                      children: [
                        SizedBox(height: 6.h),
                        _buildLast6RacesTable(results),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

Widget _buildProfileSectionCard({
  required String title,
  required Color iconColor,
  required List<Widget> children,
}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1F29),
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: Colors.white12, width: 0.8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                color: iconColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        ...children,
      ],
    ),
  );
}

Widget _buildProfileInfoLine(String text) {
  return Text(
    text,
    style: TextStyle(
      color: Colors.white,
      fontSize: 12.5.sp,
      height: 1.3,
    ),
  );
}

Widget _buildLast6RacesTable(List<RaceResult> results) {
  if (results.isEmpty) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Center(
        child: Text(
          'no_data_available'.tr,
          style: TextStyle(color: Colors.white54, fontSize: 12.sp),
        ),
      ),
    );
  }

  final displayResults = results.take(6).toList();

  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF141820),
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(color: Colors.white12, width: 0.8),
    ),
    clipBehavior: Clip.antiAlias,
    child: Table(
      columnWidths: const {
        0: FlexColumnWidth(0.7), // #
        1: FlexColumnWidth(1.3), // Hp Puan
        2: FlexColumnWidth(1.0), // Kg
        3: FlexColumnWidth(1.5), // Mesafe
        4: FlexColumnWidth(1.2), // Pist
        5: FlexColumnWidth(1.5), // Derece
        6: FlexColumnWidth(1.1), // Kaçıncı
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // Header Row
        TableRow(
          decoration: const BoxDecoration(
            color: Color(0xFF222834),
          ),
          children: [
            _buildTableHeaderCell('#'),
            _buildTableHeaderCell('hp_score'.tr),
            _buildTableHeaderCell('kg'.tr),
            _buildTableHeaderCell('distance'.tr),
            _buildTableHeaderCell('track'.tr),
            _buildTableHeaderCell('time'.tr),
            _buildTableHeaderCell('rank'.tr),
          ],
        ),
        // Data Rows
        ...List.generate(displayResults.length, (index) {
          final run = displayResults[index];
          final pos = run.position;
          final hp = run.rpr ?? run.or ?? '-';
          final kg = run.weight != null ? run.weight!.toStringAsFixed(0) : '-';
          final distance = run.race?.distance ?? '-';
          final track = run.race?.trackType ?? run.race?.surface ?? '-';
          final time = run.time != null && run.time != 'N/A' ? run.time! : '-';

          final isEven = index % 2 == 0;
          return TableRow(
            decoration: BoxDecoration(
              color: isEven
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.02),
            ),
            children: [
              _buildTableCell('${index + 1}', isBold: true),
              _buildTableCell(hp),
              _buildTableCell(kg),
              _buildTableCell(distance),
              _buildTableCell(track),
              _buildTableCell(time),
              _buildTableRankCell(pos),
            ],
          );
        }),
      ],
    ),
  );
}

Widget _buildTableHeaderCell(String title) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
    child: Text(
      title,
      style: TextStyle(
        color: Colors.white70,
        fontSize: 10.sp,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

Widget _buildTableCell(String text, {bool isBold = false}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 7.h),
    child: Text(
      text,
      style: TextStyle(
        color: isBold ? Colors.white : Colors.white70,
        fontSize: 11.sp,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

Widget _buildTableRankCell(int? pos) {
  if (pos == null) {
    return _buildTableCell('-');
  }
  Color badgeColor = Colors.white24;
  Color textColor = Colors.white;
  if (pos == 1) {
    badgeColor = const Color(0xFF10B981);
    textColor = Colors.black;
  } else if (pos == 2) {
    badgeColor = const Color(0xFF06B6D4);
    textColor = Colors.black;
  } else if (pos == 3) {
    badgeColor = Colors.orange;
    textColor = Colors.black;
  }

  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.symmetric(vertical: 4.h),
    child: Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      alignment: Alignment.center,
      child: Text(
        '$pos',
        style: TextStyle(
          color: textColor,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
