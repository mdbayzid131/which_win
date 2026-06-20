import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/data/models/race_details_model.dart';
import 'package:which_win/data/models/race_model.dart';
import 'package:which_win/app/routes/app_pages.dart';
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
          final raceName =
              details?.name ?? controller.race.value?.name ?? 'Race Details';
          final trackType =
              details?.trackType ?? controller.race.value?.trackType ?? 'Turf';
          final distance =
              details?.distance ?? controller.race.value?.distance ?? '';
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
              ),
              SizedBox(width: 8.w),
              _buildHeaderTag(
                details?.status ?? controller.race.value?.status ?? 'UPCOMING',
                const Color(0xFF1E293B),
              ),
              SizedBox(width: 4.w),
              _buildHeaderTag(
                trackType,
                const Color(0xFF003D33),
                textColor: const Color(0xFF4DB6AC),
              ),
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
              child: Obx(() {
                final isLive = controller.isLive.value;
                final isPremium = controller.isPremium.value;
                return Row(
                  children: [
                    _buildTab('Horses', 0),
                    SizedBox(width: 8.w),
                    _buildTab('Statistics', 1),
                    SizedBox(width: 8.w),
                    _buildTab('Analysis', 2),
                    SizedBox(width: 16.w),
                    // Rankings button
                    GestureDetector(
                      onTap: () {
                        if (!isPremium) {
                          _showPremiumPrompt(context);
                          return;
                        }
                        final details = controller.raceDetails.value;
                        if (details != null) {
                          _showRankingDetails(context, details);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isPremium
                                ? [const Color(0xFF004D40), const Color(0xFF00695C)]
                                : [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)],
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                          border: isPremium
                              ? null
                              : Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPremium ? Icons.bar_chart : Icons.lock_outline,
                              color: isPremium ? const Color(0xFF4DB6AC) : Colors.white38,
                              size: 16.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Rankings',
                              style: TextStyle(
                                color: isPremium ? const Color(0xFF4DB6AC) : Colors.white38,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // LIVE badge — shown only when SSE is connected
                    if (isLive) ...[SizedBox(width: 10.w), _buildLiveBadge()],
                  ],
                );
              }),
            ),
          ),

          // Tab Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF4DB6AC),
                    ),
                  ),
                );
              }

              final details = controller.raceDetails.value;
              if (details == null) {
                return const Center(
                  child: Text(
                    'Failed to load race details',
                    style: TextStyle(color: Colors.white38),
                  ),
                );
              }

              if (controller.selectedTab.value == 0) {
                final entries = details.entries ?? [];
                if (entries.isEmpty) {
                  return const Center(
                    child: Text(
                      'No horses registered',
                      style: TextStyle(color: Colors.white38),
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    // Free users see dashes for prediction score on items after the first
                    final isPremium = controller.isPremium.value;
                    final score = isPremium
                        ? (entry.normalizedScore?.toInt() ?? 0)
                        : (index == 0 ? (entry.normalizedScore?.toInt() ?? 0) : 0);

                    Color scoreColor = Colors.orange;
                    if (score >= 70) {
                      scoreColor = const Color(0xFF2E7D32);
                    } else if (score < 50) {
                      scoreColor = Colors.red;
                    }

                    // Wrap cards after index 0 in a lock overlay for free users
                    final card = _buildHorseCard(context, index, entry, scoreColor);
                    if (!isPremium && index > 0) {
                      return _buildLockedCard(context, card);
                    }
                    return card;
                  },
                );
              } else if (controller.selectedTab.value == 1) {
                // Statistics — premium only
                if (!controller.isPremium.value) {
                  return _buildPremiumLock(
                    context,
                    icon: Icons.bar_chart,
                    label: 'Full Race Statistics',
                    description:
                        'Earnings, origin, distance & track stats\nare available for premium subscribers.',
                  );
                }
                return _buildStatisticsTab();
              } else if (controller.selectedTab.value == 2) {
                // Analysis — premium only
                if (!controller.isPremium.value) {
                  return _buildPremiumLock(
                    context,
                    icon: Icons.auto_graph,
                    label: 'AI Win Probability Analysis',
                    description:
                        'Algorithm-based predictions, win probabilities\nand confidence scores are premium features.',
                  );
                }
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
    final trackType = details?.trackType ?? 'Turf';
    final distance = details?.distance ?? '';
    final runnersCount = entries.length;

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
                      'Track Bias: $trackType',
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
                      'Field: $runnersCount runners',
                      const Color(0xFF4A148C),
                      const Color(0xFFBA68C8),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Analysis List
          ...List.generate(entries.length, (index) {
            final entry = entries[index];
            final rank = entry.rank ?? (index + 1);
            final name = entry.horse?.name ?? 'Unknown';
            final probability = entry.winProb ?? 0.0;
            final score = entry.normalizedScore?.toInt() ?? 0;

            final rankColors = [
              const Color(0xFFE53935),
              const Color(0xFF1E88E5),
              const Color(0xFF43A047),
              const Color(0xFF8E24AA),
              const Color(0xFFFB8C00),
              const Color(0xFF00897B),
            ];
            final rankColor = rankColors[(rank - 1) % rankColors.length];

            Color barColor = Colors.orange;
            if (score >= 70) {
              barColor = const Color(0xFF4DB6AC);
            } else if (score < 50) {
              barColor = const Color(0xFFE57373);
            }

            return _buildAnalysisItem(
              '$rank',
              name,
              score / 100.0,
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
    final stats = controller.raceStats.value;
    if (controller.isStatsLoading.value && stats == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DB6AC)),
        ),
      );
    }

    if (stats == null) {
      return const Center(
        child: Text(
          'No statistics available',
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(16.w),
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 1.1,
      children: [
        _buildStatCard(
          'EARNINGS',
          (stats.earnings ?? []).map((e) {
            return _StatItem(
              '${e.horseName}: ${e.amount}',
              (e.percentage ?? 0) / 100.0,
            );
          }).toList(),
        ),
        _buildStatCard(
          'ORIGIN',
          (stats.origin ?? []).map((e) {
            return _StatItem(
              '${e.country} ${e.percentage}%',
              (e.percentage ?? 0) / 100.0,
            );
          }).toList(),
        ),
        _buildStatCard(
          'DISTANCE',
          (stats.distance ?? []).map((e) {
            return _StatItem(
              '${e.label}: ${e.detail}',
              (e.percentage ?? 0) / 100.0,
            );
          }).toList(),
        ),
        _buildStatCard(
          'TRACK',
          (stats.track ?? []).map((e) {
            return _StatItem(
              '${e.surface}: ${e.detail}',
              (e.percentage ?? 0) / 100.0,
            );
          }).toList(),
        ),
        _buildStatCard(
          'CITY',
          (stats.city ?? []).map((e) {
            return _StatItem(
              '${e.name} ${e.percentage}%',
              (e.percentage ?? 0) / 100.0,
            );
          }).toList(),
        ),
        _buildStatCard(
          'JOCKEY',
          (stats.jockey ?? []).map((e) {
            return _StatItem(
              '${e.name}: ${e.percentage}%',
              (e.percentage ?? 0) / 100.0,
            );
          }).toList(),
        ),
        _buildStatCard(
          'CO-RACES',
          (stats.coRaces ?? []).map((e) {
            return _StatItem(
              '${e.horseName} ${e.score}',
              (e.percentage ?? 0) / 100.0,
            );
          }).toList(),
        ),
        _buildStatCard(
          'BEST TIME',
          (stats.bestTime ?? []).map((e) {
            return _StatItem(
              '${e.horseName} ${e.time}',
              (e.percentage ?? 0) / 100.0,
            );
          }).toList(),
        ),
      ],
    );
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

  Widget _buildHorseCard(
    BuildContext context,
    int index,
    RaceEntry entry,
    Color scoreColor,
  ) {
    final horse = entry.horse;
    final horseName = horse?.name ?? 'Unknown';
    final score = entry.normalizedScore?.toInt() ?? 0;
    final jockeyName = entry.jockeyName ?? 'Unknown Jockey';
    final age = horse?.age != null ? '${horse!.age}yo' : '';
    final color = horse?.color ?? '';
    final weightText = entry.weight != null ? '${entry.weight}kg' : '';
    // Per-horse unique fields
    final winProbPct = entry.winProb != null
        ? '${(entry.winProb! * 100).toStringAsFixed(1)}% WIN'
        : '';
    final confidenceLabel = entry.aiConfidence?.toUpperCase() ?? '';
    final confidenceColor = confidenceLabel == 'HIGH'
        ? const Color(0xFF1B5E20)
        : confidenceLabel == 'MEDIUM'
        ? const Color(0xFFF57F17)
        : const Color(0xFF37474F);

    // Form history
    String formHistory = '';
    if (horse?.results != null) {
      formHistory = horse!.results!
          .take(6)
          .map((r) => '${r.position ?? ''}')
          .join('');
    }

    return Obx(() {
      final isExpanded = controller.expandedIndex.value == index;
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
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${entry.rank ?? (index + 1)}',
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
                            '$age • $color | Jockey: $jockeyName | $weightText',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Per-horse unique stats
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (winProbPct.isNotEmpty)
                          Text(
                            winProbPct,
                            style: TextStyle(
                              color: const Color(0xFF4DB6AC),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (confidenceLabel.isNotEmpty)
                          Container(
                            margin: EdgeInsets.only(top: 4.h),
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: confidenceColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(
                                color: confidenceColor.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              confidenceLabel,
                              style: TextStyle(
                                color: confidenceColor,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            Text(
                              formHistory,
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
                            'Sire: ${horse?.sireName ?? 'N/A'}',
                            'Dam: ${horse?.damName ?? 'N/A'}',
                          ]),
                        ),
                        Expanded(
                          child: _buildDetailSection('TEAM', [
                            'Owner: ${horse?.owner ?? 'N/A'}',
                            'Trainer: ${horse?.trainer ?? 'N/A'}',
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
                                const TextSpan(
                                  text: 'PERFORMANCE: ',
                                  style: TextStyle(color: Colors.white38),
                                ),
                                TextSpan(
                                  text:
                                      'Best: ${horse?.bestTime ?? 'N/A'} ${horse?.bestTimeLocation ?? ''}',
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (horse?.id != null) {
                              controller.fetchHorseProfile(horse!.id!);
                              _showHorseDetails(
                                context,
                                horseName,
                                entry.horsePower ?? 94,
                              );
                            }
                          },
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

  void _showRankingDetails(BuildContext context, RaceDetailsData details) {
    final entries = [...(details.entries ?? [])];
    entries.sort((a, b) => (a.rank ?? 999).compareTo(b.rank ?? 999));

    final rankColors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFFCD7F32), // Bronze
      const Color(0xFF1E88E5),
      const Color(0xFF43A047),
      const Color(0xFF8E24AA),
    ];

    Get.bottomSheet(
      Container(
        height: Get.height * 0.88,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0F14),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  Icon(
                    Icons.bar_chart,
                    color: const Color(0xFF4DB6AC),
                    size: 22.sp,
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Race Rankings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${entries.length} runners · ${details.location ?? ''}',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.close,
                      color: Colors.white38,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: entries.length,
                itemBuilder: (ctx, index) {
                  final entry = entries[index];
                  final rank = entry.rank ?? (index + 1);
                  final name = entry.horse?.name ?? 'Horse ${index + 1}';
                  final score = entry.normalizedScore?.toInt() ?? 0;
                  final winProb = entry.winProb ?? 0.0;
                  final fairOdds = entry.winOddsFair;
                  final confidence = (entry.aiConfidence ?? '').toUpperCase();
                  final analysis = entry.aiAnalysis ?? '';
                  final jockeyName = entry.jockeyName ?? '';

                  final rankColor =
                      rankColors[(rank - 1).clamp(0, rankColors.length - 1)];
                  final scoreColor = score >= 70
                      ? const Color(0xFF4DB6AC)
                      : score >= 50
                      ? Colors.orange
                      : Colors.white54;

                  final confColor = confidence == 'HIGH'
                      ? const Color(0xFF1B5E20)
                      : confidence == 'MEDIUM'
                      ? const Color(0xFFF57F17)
                      : const Color(0xFF37474F);

                  return Container(
                    margin: EdgeInsets.only(bottom: 14.h),
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1419),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: rank <= 3
                            ? rankColor.withOpacity(0.3)
                            : Colors.white12,
                        width: rank <= 3 ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Rank badge
                            Container(
                              width: 36.w,
                              height: 36.w,
                              decoration: BoxDecoration(
                                color: rankColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: rankColor.withOpacity(0.5),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '#$rank',
                                style: TextStyle(
                                  color: rankColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (jockeyName.isNotEmpty)
                                    Text(
                                      'Jockey: $jockeyName',
                                      style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Score box
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$score',
                                  style: TextStyle(
                                    color: scoreColor,
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Rating',
                                  style: TextStyle(
                                    color: Colors.white24,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        // Score bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: score / 100.0,
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              scoreColor,
                            ),
                            minHeight: 6.h,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        // Stats row
                        Row(
                          children: [
                            _buildRankStat(
                              'WIN PROB',
                              '${(winProb * 100).toStringAsFixed(1)}%',
                              Colors.white70,
                            ),
                            SizedBox(width: 16.w),
                            if (fairOdds != null)
                              _buildRankStat(
                                'FAIR ODDS',
                                '${fairOdds.toStringAsFixed(1)}x',
                                Colors.white70,
                              ),
                            const Spacer(),
                            if (confidence.isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: confColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4.r),
                                  border: Border.all(
                                    color: confColor.withOpacity(0.5),
                                  ),
                                ),
                                child: Text(
                                  confidence,
                                  style: TextStyle(
                                    color: confColor,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (analysis.isNotEmpty) ...[
                          SizedBox(height: 10.h),
                          Text(
                            analysis,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11.sp,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildRankStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white24, fontSize: 9.sp),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showHorseDetails(
    BuildContext context,
    String horseName,
    num? currentHorsePower,
  ) {
    Get.bottomSheet(
      Obx(() {
        if (controller.isHorseLoading.value) {
          return Container(
            height: Get.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              border: Border.all(color: Colors.white12),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DB6AC)),
              ),
            ),
          );
        }

        final horse = controller.horseDetails.value;
        if (horse == null) {
          return Container(
            height: Get.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              border: Border.all(color: Colors.white12),
            ),
            child: const Center(
              child: Text(
                'Failed to load horse career profile',
                style: TextStyle(color: Colors.white38),
              ),
            ),
          );
        }

        // Stats calculations
        final wins = horse.wins ?? 0;
        final seconds = horse.seconds ?? 0;
        final thirds = horse.thirds ?? 0;
        final totalRaces = horse.totalRaces ?? 0;

        final winRate = totalRaces > 0
            ? ((wins / totalRaces) * 100).toStringAsFixed(0)
            : '0';
        final top3Rate = totalRaces > 0
            ? (((wins + seconds + thirds) / totalRaces) * 100).toStringAsFixed(
                0,
              )
            : '0';

        // Avg Position calculation
        final results = horse.results ?? [];
        double avgPosition = 0.0;
        if (results.isNotEmpty) {
          final sum = results.fold<int>(
            0,
            (previous, result) => previous + (result.position ?? 0),
          );
          avgPosition = sum / results.length;
        }
        final avgPosText = results.isNotEmpty
            ? avgPosition.toStringAsFixed(1)
            : '0.0';

        // HP Score from current race parameter or fallback
        final String hpScoreText = currentHorsePower != null
            ? (currentHorsePower is double
                  ? currentHorsePower.toStringAsFixed(1)
                  : '$currentHorsePower')
            : 'N/A';

        // Earnings format
        final totalEarnings = horse.totalEarnings ?? 0.0;
        final String earningsText = _formatCurrency(totalEarnings);

        // Best Time
        final bestTimeText =
            '${horse.bestTime ?? ''} ${horse.bestTimeLocation ?? ''}';

        // Last 6 form
        final last6Form = results
            .take(6)
            .map((r) => '${r.position ?? ''}')
            .join('');

        return Container(
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
                        horse.name ?? horseName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${horse.age ?? 0}yo ${horse.color ?? ''} · ${horse.country ?? ''}',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 14.sp,
                        ),
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
                    'Stats: $winRate% Win | $top3Rate% Top 3 | $avgPosText Avg',
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
                  Expanded(child: _buildInfoBox('HP Score', hpScoreText)),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildInfoBox('Earnings', earningsText)),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoBox(
                      'Best Time',
                      bestTimeText.trim().isEmpty ? 'N/A' : bestTimeText,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildInfoBox(
                      'Last 6',
                      last6Form.isEmpty ? 'N/A' : last6Form,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Details
              _buildPopupSection(
                'PEDIGREE',
                'Sire: ${horse.sireName ?? 'N/A'} · Dam: ${horse.damName ?? 'N/A'}',
              ),
              SizedBox(height: 16.h),
              _buildPopupSection(
                'TEAM',
                'Owner: ${horse.owner ?? 'N/A'} · Trainer: ${horse.trainer ?? 'N/A'}',
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
                child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, idx) {
                    final run = results[idx];
                    final pos = run.position ?? 0;

                    Color badgeColor = Colors.grey;
                    if (pos == 1) {
                      badgeColor = const Color(0xFF1B5E20);
                    } else if (pos == 2) {
                      badgeColor = const Color(0xFF2E7D32);
                    } else if (pos == 3) {
                      badgeColor = Colors.orange;
                    }

                    return _buildHistoryItem(
                      '$pos',
                      run.race?.name ?? 'Race ${idx + 1}',
                      '${run.race?.distance ?? ''} · ${run.race?.trackType ?? ''}',
                      badgeColor,
                    );
                  },
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
        );
      }),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  String _formatCurrency(double amount) {
    final s = amount.toInt().toString();
    if (s.length > 3) {
      final buffer = StringBuffer();
      int count = 0;
      for (int i = s.length - 1; i >= 0; i--) {
        buffer.write(s[i]);
        count++;
        if (count % 3 == 0 && i != 0) {
          buffer.write(',');
        }
      }
      return '₺${buffer.toString().split('').reversed.join('')}';
    }
    return '₺$s';
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

  // ─────────────────────────────────────────────────────────────────────────
  // PREMIUM LOCK — full tab overlay
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPremiumLock(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.25),
                    blurRadius: 20,
                    spreadRadius: 4,
                  )
                ],
              ),
              child: Icon(Icons.lock_outline, color: Colors.black87, size: 34.sp),
            ),
            SizedBox(height: 20.h),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),
            Text(
              description,
              style: TextStyle(color: Colors.white38, fontSize: 13.sp, height: 1.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28.h),
            GestureDetector(
              onTap: () => _showPremiumPrompt(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Text(
                  '✦  Upgrade to Premium',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOCKED CARD — overlay on individual horse cards for free users
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLockedCard(BuildContext context, Widget card) {
    return Stack(
      children: [
        // Blurred underlying card
        IgnorePointer(
          child: Opacity(opacity: 0.25, child: card),
        ),
        // Lock overlay
        Positioned.fill(
          child: GestureDetector(
            onTap: () => _showPremiumPrompt(context),
            child: Container(
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline,
                        color: const Color(0xFFFFD700), size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Premium Only',
                      style: TextStyle(
                        color: const Color(0xFFFFD700),
                        fontSize: 13.sp,
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

  // ─────────────────────────────────────────────────────────────────────────
  // LIVE BADGE — pulsing indicator shown while SSE stream is active
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLiveBadge() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      onEnd: () {},
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(6.r),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 1,
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6.w,
              height: 6.w,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
            SizedBox(width: 4.w),
            Text(
              'LIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PREMIUM UPGRADE PROMPT — bottom sheet
  // ─────────────────────────────────────────────────────────────────────────
  void _showPremiumPrompt(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 40.h),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0F14),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w, height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Icon(Icons.workspace_premium_rounded,
                color: const Color(0xFFFFD700), size: 48.sp),
            SizedBox(height: 16.h),
            Text(
              'Unlock Premium',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Get full access to AI rankings, win probabilities,\nrace statistics, and live score updates.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 13.sp, height: 1.6),
            ),
            SizedBox(height: 28.h),
            GestureDetector(
              onTap: () {
                Get.back();
                Get.toNamed('/subscription');
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'View Plans',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () => Get.back(),
              child: Text(
                'Maybe later',
                style: TextStyle(color: Colors.white38, fontSize: 13.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem {
  final String label;
  final double value;
  _StatItem(this.label, this.value);
}
