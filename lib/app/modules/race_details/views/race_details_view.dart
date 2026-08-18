import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/data/models/race_details_model.dart';
import '../controllers/race_details_controller.dart';

class RaceDetailsView extends GetView<RaceDetailsController> {
  const RaceDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leadingWidth: 100.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.arrow_back, color: Colors.white, size: 16.sp),
                  SizedBox(width: 4.w),
                  Text(
                    'Back',
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                ],
              ),
            ),
          ),
        ),
        title: Obx(() {
          final details = controller.raceDetails.value;
          final raceName = details?.name ?? controller.race.value?.name ?? 'Race';
          final surfaceLabel = details?.surfaceLabel ?? controller.race.value?.surfaceLabel ?? 'N/A';
          final distance = details?.distance ?? controller.race.value?.distance ?? 'N/A';
          final time = details?.time ?? controller.race.value?.time ?? '';
          return Row(
            children: [
              Text(
                raceName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(width: 8.w),
              _buildHeaderTag(surfaceLabel, const Color(0xFF003D33),
                  textColor: const Color(0xFF4DB6AC)),
              SizedBox(width: 8.w),
              Text(
                '$distance · $time',
                style: TextStyle(color: Colors.white38, fontSize: 12.sp),
              ),
            ],
          );
        }),
      ),
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTab('Horses', 0),
                  SizedBox(width: 8.w),
                  _buildTab('Statistics', 1),
                  SizedBox(width: 8.w),
                  _buildTab('Analysis', 2),
                  SizedBox(width: 16.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'Open All Details',
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF4DB6AC),
                  ),
                );
              }
              if (controller.selectedTab.value == 0) {
                final entries = controller.raceDetails.value?.entries ?? [];
                if (entries.isEmpty) {
                  return const Center(
                    child: Text(
                      'No horse data available',
                      style: TextStyle(color: Colors.white38),
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final score = entry.normalizedScore?.toInt() ?? entry.horsePower ?? 0;
                    final Color scoreColor = score >= 80
                        ? const Color(0xFF2E7D32)
                        : score >= 60
                            ? Colors.orange
                            : Colors.red;

                    return _buildHorseCard(
                      index,
                      entry.horse?.name ?? entry.jockeyName ?? 'N/A',
                      score,
                      scoreColor,
                      entry: entry,
                    );
                  },
                );
              } else if (controller.selectedTab.value == 1) {
                return _buildStatisticsTab();
              } else if (controller.selectedTab.value == 2) {
                return _buildAnalysisTab();
              } else {
                return const Center(
                  child: Text(
                    'Content Coming Soon',
                    style: TextStyle(color: Colors.white38),
                  ),
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    final details = controller.raceDetails.value;
    final entries = details?.entries ?? [];
    final surfaceLabel = details?.surfaceLabel ?? 'N/A';
    final distance = details?.distance ?? 'N/A';
    final fieldSize = entries.isNotEmpty ? entries.length : (details?.fieldSize ?? 0);

    // Sort by aiSelectionRank if available, else by normalizedScore desc
    final sorted = List.of(entries)
      ..sort((a, b) {
        final aRank = a.aiSelectionRank ?? 999;
        final bRank = b.aiSelectionRank ?? 999;
        if (aRank != bRank) return aRank.compareTo(bRank);
        final aScore = a.normalizedScore ?? 0;
        final bScore = b.normalizedScore ?? 0;
        return bScore.compareTo(aScore);
      });

    // Colour palette for rank circles
    final rankColors = [
      const Color(0xFFE53935),
      const Color(0xFF1E88E5),
      const Color(0xFF43A047),
      const Color(0xFF8E24AA),
      const Color(0xFFFB8C00),
      const Color(0xFF00897B),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Algorithm Info Box
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1419),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Algorithm-based win probability analysis',
                  style: TextStyle(color: Colors.white38, fontSize: 13.sp),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _buildAnalysisTag(
                      'Track: $surfaceLabel',
                      const Color(0xFF1B5E20),
                      const Color(0xFF81C784),
                    ),
                    SizedBox(width: 8.w),
                    _buildAnalysisTag(
                      'Dist: $distance',
                      const Color(0xFF0D47A1),
                      const Color(0xFF64B5F6),
                    ),
                    SizedBox(width: 8.w),
                    _buildAnalysisTag(
                      'Field: $fieldSize runners',
                      const Color(0xFF4A148C),
                      const Color(0xFFBA68C8),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Analysis List — real data
          if (sorted.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No analysis data available yet',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            )
          else
            ...sorted.asMap().entries.map((e) {
              final i = e.key;
              final entry = e.value;
              final horseName = entry.horse?.name ?? entry.jockeyName ?? 'N/A';
              final prob = entry.winProb ?? (entry.normalizedScore != null ? entry.normalizedScore! / 100 : 0.0);
              final rankColor = rankColors[i % rankColors.length];
              final barColor = prob >= 0.7
                  ? const Color(0xFF4DB6AC)
                  : prob >= 0.4
                      ? const Color(0xFFFFB74D)
                      : const Color(0xFFE57373);
              return _buildAnalysisItem(
                '${i + 1}',
                horseName,
                prob.clamp(0.0, 1.0),
                rankColor,
                barColor,
              );
            }),

          SizedBox(height: 16.h),
          Text(
            '* Probabilities computed from HP, earnings, track suitability, jockey records & co-race history.',
            style: TextStyle(
              color: Colors.white24,
              fontSize: 11.sp,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildAnalysisTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: bgColor.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAnalysisItem(
    String rank,
    String name,
    double probability,
    Color rankColor,
    Color barColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: rankColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  rank,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${(probability * 100).toInt()}%',
                style: TextStyle(
                  color: barColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: probability,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 8.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return Obx(() {
      if (controller.isStatsLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF4DB6AC)),
        );
      }
      final stats = controller.raceStats.value;

      List<_StatItem> earningsItems() {
        if (stats?.earnings == null || stats!.earnings!.isEmpty) return [_StatItem('N/A', 0)];
        return stats.earnings!.map((e) => _StatItem(
          '${e.horseName ?? 'N/A'}: ${e.amount ?? 'N/A'}',
          ((e.percentage ?? 0) / 100).clamp(0.0, 1.0),
        )).toList();
      }

      List<_StatItem> originItems() {
        if (stats?.origin == null || stats!.origin!.isEmpty) return [_StatItem('N/A', 0)];
        return stats.origin!.map((e) => _StatItem(
          '${e.country ?? 'N/A'} ${e.percentage ?? 0}%',
          ((e.percentage ?? 0) / 100).clamp(0.0, 1.0),
        )).toList();
      }

      List<_StatItem> distanceItems() {
        if (stats?.distance == null || stats!.distance!.isEmpty) return [_StatItem('N/A', 0)];
        return stats.distance!.map((e) => _StatItem(
          '${e.label ?? 'N/A'}: ${e.detail ?? ''}',
          ((e.percentage ?? 0) / 100).clamp(0.0, 1.0),
        )).toList();
      }

      List<_StatItem> trackItems() {
        if (stats?.track == null || stats!.track!.isEmpty) return [_StatItem('N/A', 0)];
        return stats.track!.map((e) => _StatItem(
          '${e.surface ?? 'N/A'}: ${e.detail ?? ''}',
          ((e.percentage ?? 0) / 100).clamp(0.0, 1.0),
        )).toList();
      }

      List<_StatItem> jockeyItems() {
        if (stats?.jockey == null || stats!.jockey!.isEmpty) return [_StatItem('N/A', 0)];
        return stats.jockey!.map((e) => _StatItem(
          '${e.name ?? 'N/A'}: ${e.percentage ?? 0}%',
          ((e.percentage ?? 0) / 100).clamp(0.0, 1.0),
        )).toList();
      }

      List<_StatItem> coRaceItems() {
        if (stats?.coRaces == null || stats!.coRaces!.isEmpty) return [_StatItem('N/A', 0)];
        return stats.coRaces!.map((e) => _StatItem(
          '${e.horseName ?? 'N/A'} ${e.score ?? ''}',
          ((e.percentage ?? 0) / 100).clamp(0.0, 1.0),
        )).toList();
      }

      List<_StatItem> bestTimeItems() {
        if (stats?.bestTime == null || stats!.bestTime!.isEmpty) return [_StatItem('N/A', 0)];
        return stats.bestTime!.map((e) => _StatItem(
          '${e.horseName ?? 'N/A'} ${e.time ?? 'N/A'}',
          ((e.percentage ?? 0) / 100).clamp(0.0, 1.0),
        )).toList();
      }

      return GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.w),
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 1.1,
        children: [
          _buildStatCard('EARNINGS', earningsItems()),
          _buildStatCard('ORIGIN', originItems()),
          _buildStatCard('DISTANCE', distanceItems()),
          _buildStatCard('TRACK', trackItems()),
          _buildStatCard('JOCKEY', jockeyItems()),
          _buildStatCard('CO-RACES', coRaceItems()),
          _buildStatCard('BEST TIME', bestTimeItems()),
        ],
      );
    });
  }

  Widget _buildStatCard(String title, List<_StatItem> items) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF4DB6AC),
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      items[index].label,
                      style: TextStyle(color: Colors.white, fontSize: 11.sp),
                    ),
                    SizedBox(height: 4.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2.r),
                      child: LinearProgressIndicator(
                        value: items[index].value,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF00695C),
                        ),
                        minHeight: 4.h,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTag(
    String text,
    Color bgColor, {
    Color textColor = Colors.white,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    return Obx(() {
      final isSelected = controller.selectedTab.value == index;
      return GestureDetector(
        onTap: () => controller.setTab(index),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF004D40)
                : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? const Color(0xFF4DB6AC) : Colors.white38,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHorseCard(int index, String name, int score, Color scoreColor,
      {RaceEntry? entry}) {
    return Obx(() {
      final isExpanded = controller.expandedIndex.value == index;

      // Real data with N/A fallbacks
      final String horseName = entry?.horse?.name ?? name;
      final String age = entry?.horse?.age != null ? '${entry!.horse!.age}yo' : 'N/A';
      final String colour = entry?.colour ?? entry?.horse?.color ?? 'N/A';
      final String jockeyName = entry?.jockeyName ?? 'N/A';
      final String weight =
          entry?.weightStr ?? entry?.weight?.toStringAsFixed(0) ?? 'N/A';
      final String form = entry?.form ?? 'N/A';
      final String sireName = entry?.horse?.sireName ?? 'N/A';
      final String damName = entry?.horse?.damName ?? 'N/A';
      final String ownerName = entry?.ownerName ?? entry?.horse?.owner ?? 'N/A';
      final String trainerName =
          entry?.trainerName ?? entry?.horse?.trainer ?? 'N/A';
      final String bestTime = entry?.horse?.bestTime ?? 'N/A';
      final String aiAnalysis = entry?.aiAnalysis ?? 'N/A';
      final String winOdds = entry?.winOddsFair != null
          ? entry!.winOddsFair!.toStringAsFixed(1)
          : 'N/A';

      return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1419),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => controller.toggleExpand(index),
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  children: [
                    // Rank and Score
                    Column(
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: scoreColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: scoreColor.withOpacity(0.3),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$score',
                            style: TextStyle(
                              color: scoreColor,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 12.w),
                    // Horse Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            horseName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '$age • $colour | Jockey: $jockeyName | ${weight}kg',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Price and Code
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          winOdds == 'N/A' ? 'N/A' : '₺$winOdds',
                          style: TextStyle(
                            color: const Color(0xFF4DB6AC),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              form,
                              style: TextStyle(
                                color: Colors.white24,
                                fontSize: 10.sp,
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: const Color(0xFF4DB6AC),
                              size: 16.sp,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              const Divider(color: Colors.white12, height: 1),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildDetailSection('PEDIGREE', [
                            'Sire: $sireName',
                            'Dam: $damName',
                          ]),
                        ),
                        Expanded(
                          child: _buildDetailSection('TEAM', [
                            'Owner: $ownerName',
                            'Trainer: $trainerName',
                          ]),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                              ),
                              children: [
                                TextSpan(
                                  text: 'PERFORMANCE: ',
                                  style: TextStyle(color: Colors.white38),
                                ),
                                TextSpan(
                                  text: bestTime != 'N/A'
                                      ? 'Best: $bestTime'
                                      : aiAnalysis != 'N/A'
                                          ? aiAnalysis
                                          : 'N/A',
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showHorseDetails(horseName),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF004D40),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'VIEW RACES',
                              style: TextStyle(
                                color: const Color(0xFF4DB6AC),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  void _showHorseDetails(String name) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          border: Border.all(color: Colors.white12),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '5yo Chestnut · TR',
                      style: TextStyle(color: Colors.white38, fontSize: 14.sp),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white38, size: 24.sp),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Stats Bar
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFF00241F),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFF004D40)),
              ),
              child: Center(
                child: Text(
                  'Stats: 15% Win | 38% Top 3 | 6.2 Avg',
                  style: TextStyle(
                    color: const Color(0xFF4DB6AC),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Info Grid
            Row(
              children: [
                Expanded(child: _buildInfoBox('HP Score', '94')),
                SizedBox(width: 12.w),
                Expanded(child: _buildInfoBox('Earnings', '₺500,000')),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(child: _buildInfoBox('Best Time', '1.12.45 Istanbul')),
                SizedBox(width: 12.w),
                Expanded(child: _buildInfoBox('Last 6', '323211')),
              ],
            ),
            SizedBox(height: 20.h),

            // Details
            _buildPopupSection('PEDIGREE', 'Sire: STORM CAT · Dam: REGAL LADY'),
            SizedBox(height: 16.h),
            _buildPopupSection(
              'TEAM',
              'Owner: Ali Yılmaz · Trainer: Mehmet Demir',
            ),
            SizedBox(height: 20.h),

            // Race History
            Text(
              'RACE HISTORY (LAST 6)',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: ListView(
                children: [
                  _buildHistoryItem(
                    '3',
                    'Race 6',
                    '1200m · Turf',
                    Colors.orange,
                  ),
                  _buildHistoryItem(
                    '2',
                    'Race 5',
                    '1200m · Turf',
                    const Color(0xFF2E7D32),
                  ),
                  _buildHistoryItem(
                    '3',
                    'Race 4',
                    '1200m · Turf',
                    Colors.orange,
                  ),
                  _buildHistoryItem(
                    '2',
                    'Race 3',
                    '1200m · Turf',
                    const Color(0xFF2E7D32),
                  ),
                  _buildHistoryItem(
                    '1',
                    'Race 2',
                    '1200m · Turf',
                    const Color(0xFF1B5E20),
                  ),
                  _buildHistoryItem(
                    '1',
                    'Race 1',
                    '1200m · Turf',
                    const Color(0xFF1B5E20),
                  ),
                ],
              ),
            ),

            // Bottom Close Button
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildInfoBox(String title, String value) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white38, fontSize: 12.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white38,
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          content,
          style: TextStyle(color: Colors.white, fontSize: 14.sp),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(
    String rank,
    String title,
    String subtitle,
    Color rankColor,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: rankColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  rank,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
              const Spacer(),
              Text(
                subtitle,
                style: TextStyle(color: Colors.white38, fontSize: 12.sp),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          const Divider(color: Colors.white12, height: 1),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<String> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white38,
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        ...details.map(
          (detail) => Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Text(
              detail,
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatItem {
  final String label;
  final double value;
  _StatItem(this.label, this.value);
}
