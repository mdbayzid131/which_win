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
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
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
                    'back'.tr,
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                raceName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildHeaderTag(
                      details?.status ??
                          controller.race.value?.status ??
                          'UPCOMING',
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
                      style: TextStyle(color: Colors.white38, fontSize: 11.sp),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Column(
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
                    SizedBox(width: 8.w),
                    _buildTab('Bulletin', 3),
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
                                ? [
                                    const Color(0xFF004D40),
                                    const Color(0xFF00695C),
                                  ]
                                : [
                                    const Color(0xFF1E1E1E),
                                    const Color(0xFF2A2A2A),
                                  ],
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
                              color: isPremium
                                  ? const Color(0xFF4DB6AC)
                                  : Colors.white38,
                              size: 16.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'rankings'.tr,
                              style: TextStyle(
                                color: isPremium
                                    ? const Color(0xFF4DB6AC)
                                    : Colors.white38,
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
              // ignore: unused_local_variable
              final isPremium = controller.isPremium.value;
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
                return Center(
                  child: Text(
                    'failed_load_details'.tr,
                    style: const TextStyle(color: Colors.white38),
                  ),
                );
              }

              if (controller.selectedTab.value == 0) {
                final entries = details.entries ?? [];
                if (entries.isEmpty) {
                  return Center(
                    child: Text(
                      'no_horses_registered'.tr,
                      style: const TextStyle(color: Colors.white38),
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
                        : (index == 0
                              ? (entry.normalizedScore?.toInt() ?? 0)
                              : 0);

                    Color scoreColor = Colors.orange;
                    if (score >= 70) {
                      scoreColor = const Color(0xFF2E7D32);
                    } else if (score < 50) {
                      scoreColor = Colors.red;
                    }

                    // Wrap cards after index 0 in a lock overlay for free users
                    final card = _buildHorseCard(
                      context,
                      index,
                      entry,
                      scoreColor,
                    );
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
              } else if (controller.selectedTab.value == 3) {
                // Bulletin — shows horses in API order by actual draw/horse number
                return _buildBulletinTab(details);
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
    ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BULLETIN TAB
  // Shows horses in their original API order (NO rank/score sorting).
  // The horse number is the actual draw number from the API.
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildBulletinTab(RaceDetailsData details) {
    final entries = [...(details.entries ?? [])];
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'no_horses_registered'.tr,
          style: const TextStyle(color: Colors.white38),
        ),
      );
    }

    // Sort by draw (stall/gate) number ascending
    entries.sort((a, b) {
      final aDraw = a.draw ?? 999;
      final bDraw = b.draw ?? 999;
      return aDraw.compareTo(bDraw);
    });

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildBulletinHorseCard(context, entry, index);
      },
    );
  }

  Widget _buildBulletinHorseCard(
    BuildContext context,
    RaceEntry entry,
    int fallbackIndex,
  ) {
    final horse = entry.horse;
    final horseName = horse?.name ?? 'Unknown Horse';
    final jockeyName = entry.jockeyName ?? 'Unknown Jockey';
    final trainerName = entry.trainerName ?? 'N/A';
    final age = horse?.age != null ? '${horse!.age}yo' : 'N/A';
    final color = horse?.color ?? 'N/A';
    final sex = horse?.sex ?? '';
    final weightText = entry.weight != null ? '${entry.weight!.toStringAsFixed(0)} kg' : 'N/A';
    final earnings = horse?.totalEarnings;
    final earningsText = earnings != null
        ? earnings >= 1000000
            ? '₺${(earnings / 1000000).toStringAsFixed(1)}M'
            : earnings >= 1000
            ? '₺${(earnings / 1000).toStringAsFixed(0)}K'
            : '₺${earnings.toStringAsFixed(0)}'
        : 'N/A';

    // Actual horse number from draw field (not rank, not index)
    final horseNumber = entry.draw ?? (fallbackIndex + 1);

    // Sire / Dam
    final sireName = horse?.sireName ?? 'N/A';
    final damName = horse?.damName ?? 'N/A';

    // Color palette cycling for horse number badge
    final numberColors = [
      const Color(0xFFE53935), // Red
      const Color(0xFF1E88E5), // Blue
      const Color(0xFF43A047), // Green
      const Color(0xFF8E24AA), // Purple
      const Color(0xFFFB8C00), // Orange
      const Color(0xFF00897B), // Teal
      const Color(0xFFD81B60), // Pink
      const Color(0xFF6D4C41), // Brown
      const Color(0xFF546E7A), // Blue-grey
      const Color(0xFFC0CA33), // Lime
    ];
    final badgeColor = numberColors[(horseNumber - 1).abs() % numberColors.length];

    // Career details
    final totalRaces = horse?.totalRaces ?? 0;
    final wins = horse?.wins ?? 0;
    final seconds = horse?.seconds ?? 0;
    final thirds = horse?.thirds ?? 0;
    final fourths = horse?.fourths ?? 0;
    final winRate = totalRaces > 0 ? (wins / totalRaces * 100).toStringAsFixed(1) : '0';
    final placeRate = totalRaces > 0 ? ((wins + seconds + thirds) / totalRaces * 100).toStringAsFixed(1) : '0';
    final owner = horse?.owner ?? 'N/A';
    final country = horse?.country ?? 'N/A';
    final bestTime = horse?.bestTime ?? 'N/A';
    final bestTimeLocation = horse?.bestTimeLocation ?? '';

    // Jockey Model career stats
    final jModel = entry.jockey;
    final jTotalRides = jModel?.totalRides ?? 0;
    final jWins = jModel?.wins ?? 0;
    final jSeconds = jModel?.seconds ?? 0;
    final jThirds = jModel?.thirds ?? 0;
    final jWinRate = jTotalRides > 0 ? (jWins / jTotalRides * 100).toStringAsFixed(1) : '0';
    final jPlaceRate = jTotalRides > 0 ? ((jWins + jSeconds + jThirds) / jTotalRides * 100).toStringAsFixed(1) : '0';
    final jRidesLast30 = jModel?.ridesLast30d ?? 0;
    final jWinsLast30 = jModel?.winsLast30d ?? 0;
    final jWinRateLast30 = jRidesLast30 > 0 ? (jWinsLast30 / jRidesLast30 * 100).toStringAsFixed(1) : '0';

    // Jockey & Trainer Form/Power details (Premium fields)
    final jockeyPower = entry.jockeyPower;
    final jockeyForm = entry.jockeyFormScore;
    final trainerForm = entry.trainerFormScore;

    // AI details (Premium fields)
    final winProbVal = entry.winProb;
    final winProbText = winProbVal != null ? '${(winProbVal * 100).toStringAsFixed(1)}%' : 'N/A';
    final placeProbVal = entry.placeProb;
    final placeProbText = placeProbVal != null ? '${(placeProbVal * 100).toStringAsFixed(1)}%' : 'N/A';
    final eachWayProbVal = entry.eachWayProb;
    final eachWayProbText = eachWayProbVal != null ? '${(eachWayProbVal * 100).toStringAsFixed(1)}%' : 'N/A';
    final fairOdds = entry.winOddsFair;
    final rating = entry.normalizedScore?.toInt();
    final confidence = entry.aiConfidence?.toUpperCase() ?? '';
    final category = entry.category?.toUpperCase() ?? 'N/A';
    final valueEdge = entry.valueEdgePercent;

    return Obx(() {
      final isExpanded = controller.bulletinExpandedIndex.value == fallbackIndex;
      final isPremium = controller.isPremium.value;

      return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1419),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isExpanded ? badgeColor.withOpacity(0.5) : Colors.white12,
            width: isExpanded ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Card Header (Tap to Expand/Collapse)
            GestureDetector(
              onTap: () => controller.toggleBulletinExpand(fallbackIndex),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.all(14.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Horse Number Badge
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: badgeColor.withOpacity(0.6),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$horseNumber',
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            'NO',
                            style: TextStyle(
                              color: badgeColor.withOpacity(0.7),
                              fontSize: 8.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 14.w),

                    // Horse details summary
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            [age, color, if (sex.isNotEmpty) sex].join(' · '),
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${'jockey'.tr}$jockeyName',
                            style: TextStyle(
                              color: const Color(0xFF4DB6AC),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Earnings + Weight + Expand Icon Column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B5E20).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: const Color(0xFF4CAF50).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            earningsText,
                            style: TextStyle(
                              color: const Color(0xFF81C784),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Text(
                            weightText,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Icon(
                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: badgeColor,
                          size: 18.sp,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Expanded content details
            if (isExpanded) ...[
              const Divider(color: Colors.white12, height: 1),
              Padding(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Pedigree & Team
                    _buildSubSectionTitle(Icons.account_tree_outlined, 'Pedigree & Team', badgeColor),
                    SizedBox(height: 8.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildInfoText('Sire', sireName),
                        ),
                        Expanded(
                          child: _buildInfoText('Dam', damName),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildInfoText('Trainer', trainerName),
                        ),
                        Expanded(
                          child: _buildInfoText('Owner', owner),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    _buildInfoText('Origin / Country', country),
                    
                    SizedBox(height: 16.h),

                    // Section 2: Career History
                    _buildSubSectionTitle(Icons.emoji_events_outlined, 'Career Performance', badgeColor),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(child: _buildInfoText('Total Starts', '$totalRaces')),
                        Expanded(child: _buildInfoText('Wins (1st)', '$wins')),
                        Expanded(child: _buildInfoText('Places (1-3)', '${wins + seconds + thirds}')),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Expanded(child: _buildInfoText('Win Rate', '$winRate%')),
                        Expanded(child: _buildInfoText('Place Rate', '$placeRate%')),
                        Expanded(child: _buildInfoText('Career Form', '$wins-$seconds-$thirds-$fourths')),
                      ],
                    ),
                    if (bestTime != 'N/A') ...[
                      SizedBox(height: 6.h),
                      _buildInfoText('Best Time', '$bestTime ${bestTimeLocation.isNotEmpty ? "@ $bestTimeLocation" : ""}'),
                    ],

                    SizedBox(height: 16.h),

                    // Section 3: Jockey & Trainer Performance
                    _buildSubSectionTitle(Icons.person_outline, 'Jockey & Trainer Info', badgeColor),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(child: _buildInfoText('Jockey', jockeyName)),
                        Expanded(child: _buildInfoText('Trainer', trainerName)),
                      ],
                    ),
                    if (jTotalRides > 0) ...[
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Expanded(child: _buildInfoText('Jockey Starts', '$jTotalRides')),
                          Expanded(child: _buildInfoText('Jockey Wins', '$jWins')),
                          Expanded(child: _buildInfoText('Jockey Win Rate', '$jWinRate%')),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Expanded(child: _buildInfoText('Jockey Places (1-3)', '${jWins + jSeconds + jThirds}')),
                          Expanded(child: _buildInfoText('Jockey Place Rate', '$jPlaceRate%')),
                          Expanded(child: _buildInfoText('Last 30 Days', '$jWinsLast30 / $jRidesLast30 ($jWinRateLast30%)')),
                        ],
                      ),
                    ],
                    if (isPremium && (jockeyPower != null || jockeyForm != null)) ...[
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          if (jockeyPower != null)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildProgressBarLabel('Jockey Power', '${jockeyPower.toStringAsFixed(0)}%'),
                                  SizedBox(height: 4.h),
                                  _buildProgressBar(jockeyPower / 100, const Color(0xFF4DB6AC)),
                                ],
                              ),
                            ),
                          if (jockeyPower != null && jockeyForm != null) SizedBox(width: 16.w),
                          if (jockeyForm != null)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildProgressBarLabel('Jockey Form', '${jockeyForm.toStringAsFixed(0)}%'),
                                  SizedBox(height: 4.h),
                                  _buildProgressBar(jockeyForm / 100, const Color(0xFF81C784)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (isPremium && trainerForm != null) ...[
                      SizedBox(height: 10.h),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProgressBarLabel('Trainer Form', '${trainerForm.toStringAsFixed(0)}%'),
                          SizedBox(height: 4.h),
                          _buildProgressBar(trainerForm / 100, const Color(0xFF64B5F6)),
                        ],
                      ),
                    ],

                    SizedBox(height: 16.h),

                    // Section 4: AI Analysis & Suitability (Premium)
                    _buildSubSectionTitle(Icons.auto_awesome, 'AI Prediction & Suitability', badgeColor),
                    SizedBox(height: 8.h),
                    if (!isPremium) ...[
                      // Locked content overlay
                      GestureDetector(
                        onTap: () => _showPremiumPrompt(context),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.lock_outline, color: const Color(0xFF4DB6AC), size: 24.sp),
                              SizedBox(height: 8.h),
                              Text(
                                'AI Predictions & Suitability Analysis',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Tap to unlock Win Probability, Fair Odds, and track/distance suitability scores.',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      // Premium AI Details
                      Row(
                        children: [
                          Expanded(child: _buildInfoText('AI Selection Rating', rating != null ? '$rating' : 'N/A')),
                          Expanded(child: _buildInfoText('Win Probability', winProbText)),
                          Expanded(child: _buildInfoText('Fair Odds', fairOdds != null ? '${fairOdds.toStringAsFixed(1)}x' : 'N/A')),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Expanded(child: _buildInfoText('Place Probability', placeProbText)),
                          Expanded(child: _buildInfoText('Each-Way Prob', eachWayProbText)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Confidence',
                                  style: TextStyle(color: Colors.white38, fontSize: 10.sp),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  confidence.isEmpty ? 'N/A' : confidence,
                                  style: TextStyle(
                                    color: confidence == 'HIGH'
                                        ? const Color(0xFF81C784)
                                        : confidence == 'MEDIUM'
                                            ? const Color(0xFFFFB74D)
                                            : Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (category != 'N/A' || valueEdge != null) ...[
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Expanded(child: _buildInfoText('Horse Category', category)),
                            Expanded(child: _buildInfoText('Value Edge', valueEdge != null ? '${(valueEdge * 100).toStringAsFixed(1)}%' : 'N/A')),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ],

                      // Suitability Progress Bars
                      SizedBox(height: 12.h),
                      Text(
                        'AI Suitability Scores',
                        style: TextStyle(color: Colors.white54, fontSize: 11.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.h),
                      _buildSuitabilityRow('Going Suitability', entry.goingSuitabilityScore),
                      SizedBox(height: 6.h),
                      _buildSuitabilityRow('Distance Suitability', entry.distanceSuitabilityScore),
                      SizedBox(height: 6.h),
                      _buildSuitabilityRow('Course Specialist', entry.courseSpecialistScore),
                      SizedBox(height: 6.h),
                      _buildSuitabilityRow('Draw Bias', entry.drawBiasScore),

                      // AI Analysis text
                      if (entry.aiAnalysis != null && entry.aiAnalysis!.isNotEmpty) ...[
                        SizedBox(height: 12.h),
                        Text(
                          'AI Analysis Summary',
                          style: TextStyle(color: Colors.white54, fontSize: 11.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          entry.aiAnalysis!,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11.sp,
                            fontStyle: FontStyle.italic,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildSubSectionTitle(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14.sp),
        SizedBox(width: 6.w),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white38,
            fontSize: 10.sp,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value.isEmpty ? 'N/A' : value,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildProgressBarLabel(String label, String valText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white38, fontSize: 10.sp),
        ),
        Text(
          valText,
          style: TextStyle(color: Colors.white70, fontSize: 10.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double value, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2.r),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        backgroundColor: Colors.white12,
        valueColor: AlwaysStoppedAnimation<Color>(color),
        minHeight: 4.h,
      ),
    );
  }

  Widget _buildSuitabilityRow(String label, double? score) {
    final val = score ?? 0.0;
    Color barColor = Colors.orange;
    if (val >= 70) {
      barColor = const Color(0xFF4DB6AC);
    } else if (val < 50) {
      barColor = const Color(0xFFE57373);
    }
    return Row(
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            style: TextStyle(color: Colors.white38, fontSize: 10.sp),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildProgressBar(val / 100, barColor),
        ),
        SizedBox(width: 8.w),
        SizedBox(
          width: 28.w,
          child: Text(
            score != null ? '${score.toStringAsFixed(0)}' : 'N/A',
            style: TextStyle(
              color: score != null ? barColor : Colors.white24,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
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
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _buildAnalysisTag(
                      'Track Bias: $trackType',
                      const Color(0xFF1B5E20),
                      const Color(0xFF81C784),
                    ),
                    _buildAnalysisTag(
                      'Dist: $distance',
                      const Color(0xFF0D47A1),
                      const Color(0xFF64B5F6),
                    ),
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
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 12.w),
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
            '${title.toLowerCase().replaceAll('-', '_')}_stat'.tr,
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
            text.toLowerCase().tr,
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
                          mainAxisSize: MainAxisSize.min,
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
        child: SafeArea(
          top: false,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ai_race_rankings'.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${entries.length} ${'runners'.tr} · ${details.location ?? ''}',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
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
                                      '${'jockey'.tr}$jockeyName',
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
                                  'rating'.tr,
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
                              'win_prob_upper'.tr,
                              '${(winProb * 100).toStringAsFixed(1)}%',
                              Colors.white70,
                            ),
                            SizedBox(width: 16.w),
                            if (fairOdds != null)
                              _buildRankStat(
                                'fair_odds_upper'.tr,
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
                                  confidence == 'HIGH'
                                      ? 'high'.tr.toUpperCase()
                                      : (confidence == 'MEDIUM'
                                          ? 'medium'.tr.toUpperCase()
                                          : (confidence == 'LOW'
                                              ? 'low'.tr.toUpperCase()
                                              : confidence)),
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
          child: SafeArea(
            top: false,
            bottom: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          horse.name ?? horseName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${horse.age ?? 0}yo ${horse.color ?? ''} · ${horse.country ?? ''}',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 14.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
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
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
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
                  ),
                ],
              ),
              child: Icon(
                Icons.lock_outline,
                color: Colors.black87,
                size: 34.sp,
              ),
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
              style: TextStyle(
                color: Colors.white38,
                fontSize: 13.sp,
                height: 1.5,
              ),
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
                    ),
                  ],
                ),
                child: Text(
                  '✦  ${'upgrade_to_premium'.tr}',
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
        IgnorePointer(child: Opacity(opacity: 0.25, child: card)),
        // Lock overlay
        Positioned.fill(
          child: GestureDetector(
            onTap: () => _showPremiumPrompt(context),
            child: Container(
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: const Color(0xFFFFD700),
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'premium_only'.tr,
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
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6.w,
              height: 6.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
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
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0F14),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
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
            Icon(
              Icons.workspace_premium_rounded,
              color: const Color(0xFFFFD700),
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'unlock_premium'.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'premium_unlock_desc'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13.sp,
                height: 1.6,
              ),
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
                  'view_plans'.tr,
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
    ),
    );
  }
}

class _StatItem {
  final String label;
  final double value;
  _StatItem(this.label, this.value);
}
