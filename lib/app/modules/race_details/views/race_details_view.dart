import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:which_win/data/models/race_details_model.dart';
import 'package:which_win/data/models/race_model.dart';
import 'package:which_win/app/routes/app_pages.dart';
import '../controllers/race_details_controller.dart';

class RaceDetailsView extends GetView<RaceDetailsController> {
  const RaceDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Obx(() {
          final details = controller.raceDetails.value;
          final currentRace = controller.race.value;
          final locationName =
              details?.location ?? currentRace?.location ?? 'Ankara';
          final dateVal = currentRace?.date ?? DateTime.now().toIso8601String();
          final dayStr = _getDayFromDate(dateVal);

          if (controller.isLoading.value && details == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00CC99)),
              ),
            );
          }

          return Column(
            children: [
              // ── Custom Header / App Bar ──────────────────────────────────────────
              _buildAppBar(context, locationName, dayStr),

              // ── Weather & Track Info Banner ──────────────────────────────────────
              _buildWeatherBanner(details),

              // ── Horizontal Race Selector Bar ─────────────────────────────────────
              _buildHorizontalRaceSelector(),

              // ── Selected Race Details Banner ─────────────────────────────────────
              _buildSelectedRaceDetailsBanner(details, currentRace),

              // ── Sub-Tab Bar (STATISTICS / ANALYSIS / PREDICTION / RESULT) ───────
              _buildSubTabBar(),

              // ── Tab Content Area ─────────────────────────────────────────────────
              Expanded(child: _buildTabContent(context, details)),
            ],
          );
        }),
      ),
    );
  }

  // ── APP BAR ──────────────────────────────────────────────────────────────
  Widget _buildAppBar(
    BuildContext context,
    String locationName,
    String dayStr,
  ) {
    return Container(
      color: const Color(0xFF121212),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
            onPressed: () => Get.back(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locationName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '$locationName Hipodromu',
                  style: TextStyle(color: Colors.white54, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          // Action icons row from the reference screen
          Row(
            children: [
              // Emblem/Logo decorative icon
              Container(
                width: 32.w,
                height: 32.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.lens_blur_sharp,
                  color: const Color(0xFF00CC99),
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 8.w),
              // L box
              _buildAppBarBadge('L'),
              SizedBox(width: 8.w),
              // Date day box
              _buildAppBarBadge(dayStr),
              SizedBox(width: 8.w),
              // TR box
              _buildAppBarBadge('TR'),
              SizedBox(width: 4.w),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarBadge(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ── WEATHER & TRACK INFO BANNER ──────────────────────────────────────────
  Widget _buildWeatherBanner(RaceDetailsData? details) {
    // Reference details: Sunny: 26°C | Humidity: 39% | Dirt: Normal | Turf: Normal
    final trackType = details?.trackType ?? 'Turf';
    final isTurf =
        trackType.toLowerCase().contains('turf') ||
        trackType.toLowerCase().contains('çim');

    return Container(
      width: double.infinity,
      color: const Color(0xFF1A1A1A),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Text(
        'Sunny: 26°C  Humidity: 39%  Dirt: Normal  Turf: ${isTurf ? "Normal" : "Good"}',
        style: TextStyle(
          color: const Color(0xFF00CC99),
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ── HORIZONTAL RACE SELECTOR BAR ─────────────────────────────────────────
  Widget _buildHorizontalRaceSelector() {
    final races = controller.siblingRaces;
    if (races.isEmpty) {
      // Fallback fallback list of demo races if sibling races not loaded
      return Container(
        height: 60.h,
        color: const Color(0xFF121212),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          itemCount: 8,
          itemBuilder: (context, index) {
            final isSelected = index == 0;
            return _buildRaceSelectorTab(
              isSelected: isSelected,
              title: 'RACE ${index + 1}',
              time:
                  '14:${(30 + index * 30) % 60 == 0 ? "00" : (30 + index * 30) % 60}',
              onTap: () {},
            );
          },
        ),
      );
    }

    return Container(
      height: 62.h,
      color: const Color(0xFF121212),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        itemCount: races.length,
        itemBuilder: (context, index) {
          final sibling = races[index];
          final isSelected = sibling.id == controller.race.value?.id;
          final timeStr = sibling.time ?? '14:30';

          return _buildRaceSelectorTab(
            isSelected: isSelected,
            title: 'RACE ${index + 1}',
            time: timeStr,
            onTap: () => controller.selectSiblingRace(sibling),
          );
        },
      ),
    );
  }

  Widget _buildRaceSelectorTab({
    required bool isSelected,
    required String title,
    required String time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75.w,
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00CC99) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF00CC99) : Colors.white12,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              time,
              style: TextStyle(
                color: isSelected ? Colors.black87 : Colors.white38,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SELECTED RACE DETAILS BANNER ──────────────────────────────────────────
  Widget _buildSelectedRaceDetailsBanner(
    RaceDetailsData? details,
    RaceModel? currentRace,
  ) {
    final timeVal = details?.time ?? currentRace?.time ?? '14:30';
    final distanceVal = details?.distance ?? currentRace?.distance ?? '1900m';
    final trackType = details?.trackType ?? currentRace?.trackType ?? 'Turf';
    final conditionsText =
        '3yo+ Thoroughbreds / CONDITION 3/Y1 / Track Record: 1.53.13';

    // Prize money format
    final prizeText = details?.prize ?? '800,000 ₺';
    // Format prize values
    final basePrize = 800000;
    final prizeBreakdown =
        '1.) 800,000 ₺   2.) 400,000 ₺   3.) 200,000 ₺   4.) 100,000 ₺   5.) 50,000 ₺';

    return Column(
      children: [
        // Sub-details line
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF0F1419),
            border: Border(
              top: BorderSide(color: Colors.white10),
              bottom: BorderSide(color: Colors.white10),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Text(
            '$timeVal  $distanceVal $trackType / $conditionsText',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Prize details line
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF0F1419),
            border: Border(bottom: BorderSide(color: Colors.white10)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          child: Text(
            prizeBreakdown,
            style: TextStyle(
              color: const Color(0xFF00CC99),
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  // ── SUB-TAB BAR ──────────────────────────────────────────────────────────
  Widget _buildSubTabBar() {
    return Container(
      color: const Color(0xFF121212),
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Obx(() {
        final currentTab = controller.selectedTab.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSubTabItem('STATISTICS', 0, currentTab),
            _buildSubTabItem('ANALYSIS', 1, currentTab),
            _buildSubTabItem('PREDICTIONS', 2, currentTab),
            _buildSubTabItem('RESULTS', 3, currentTab),
          ],
        );
      }),
    );
  }

  Widget _buildSubTabItem(String label, int index, int selectedIndex) {
    final isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: () => controller.setTab(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF00CC99) : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF00CC99) : Colors.white54,
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // ── TAB CONTENT ROUTER ───────────────────────────────────────────────────
  Widget _buildTabContent(BuildContext context, RaceDetailsData? details) {
    if (details == null) {
      return const Center(
        child: Text(
          'Failed to load details',
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    final isPremium = controller.isPremium.value;

    switch (controller.selectedTab.value) {
      case 0:
        // STATISTICS - Redesigned horse list sorted by prediction rank/score
        final entries = details.entries ?? [];
        if (entries.isEmpty) {
          return Center(
            child: Text(
              'No horses registered',
              style: const TextStyle(color: Colors.white38),
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final score = entry.normalizedScore?.toInt() ?? 0;

            Color scoreColor = Colors.orange;
            if (score >= 70) {
              scoreColor = const Color(0xFF2E7D32);
            } else if (score < 50) {
              scoreColor = Colors.red;
            }

            final card = _buildTurkeyStyleHorseCard(
              context,
              index,
              entry,
              scoreColor,
            );

            // Hide details from free users for index > 0
            if (!isPremium && index > 0) {
              return _buildLockedCard(context, card);
            }
            return card;
          },
        );

      case 1:
        // ANALYSIS - AI win analysis probability progress bars
        if (!isPremium) {
          return _buildPremiumLock(
            context,
            icon: Icons.auto_graph,
            label: 'AI Win Probability Analysis',
            description:
                'Algorithm-based predictions, win probabilities\nand confidence scores are premium features.',
          );
        }
        return _buildAnalysisTab();

      case 2:
        // PREDICTIONS - Stats breakdown grid (Earnings, Origin, Distance...)
        if (!isPremium) {
          return _buildPremiumLock(
            context,
            icon: Icons.bar_chart,
            label: 'Full Race Statistics',
            description:
                'Earnings, origin, distance & track stats\nare available for premium subscribers.',
          );
        }
        return _buildStatisticsTab();

      case 3:
        // RESULTS - Bulletin list ordered by starting post/draw
        return _buildBulletinTab(details);

      default:
        return const Center(
          child: Text('Coming Soon', style: TextStyle(color: Colors.white38)),
        );
    }
  }

  // ── TURKEY REFERENCE STYLE HORSE CARD (İSTATİSTİK LIST ITEM) ────────────
  Widget _buildTurkeyStyleHorseCard(
    BuildContext context,
    int index,
    RaceEntry entry,
    Color scoreColor,
  ) {
    final horse = entry.horse;
    final horseName = horse?.name ?? 'Unknown Horse';
    final jockeyName = entry.jockeyName ?? 'Unknown Jockey';
    final trainerName = entry.trainerName ?? 'N/A';
    final age = horse?.age != null ? '${horse!.age}y' : '4y';
    final color = horse?.color ?? 'd';
    final sex = horse?.sex ?? 'k';
    final weightText = entry.weight != null
        ? '${entry.weight!.toStringAsFixed(0)} kg'
        : '56 kg';

    // Demo saddle vs. gate numbers
    final gateNumber = entry.draw ?? (index + 1);
    final saddleNumbers = [75, 112, 98, 66, 54, 87, 43, 29, 12, 105];
    final saddleNumber = saddleNumbers[index % saddleNumbers.length];

    // Demo/API earnings representation
    final earnings = horse?.totalEarnings ?? (650000.0 - (index * 45000.0));
    final earningsText = 'Earnings: ${_formatCurrency(earnings)}';

    // ST: Gate, KGS: Days since last run, HP: Horse power rating
    final stVal = gateNumber;
    final kgsVal = [14, 23, 12, 257, 33, 52, 9, 18, 45, 60][index % 10];
    final hpVal =
        entry.horsePower?.toInt() ??
        entry.normalizedScore?.toInt() ??
        [95, 52, 88, 96, 72, 87, 68, 79][index % 8];

    // EİD: Expected time and ID
    final expectedTime = '1.55.${(20 + index * 4).toString().padLeft(2, '0')}';
    final horseIdStr = horse?.id?.substring(0, 6) ?? '304621';

    return Obx(() {
      final isExpanded = controller.expandedIndex.value == index;
      final isPremium = controller.isPremium.value;

      return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1419),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isExpanded
                ? const Color(0xFF00CC99).withOpacity(0.5)
                : Colors.white12,
            width: isExpanded ? 1.5 : 1.0,
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
            // Collapsed view: tap to toggle expand
            GestureDetector(
              onTap: () => controller.toggleExpand(index),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  children: [
                    // Column 1: Gate box (light) and Saddle box (dark theme green/teal)
                    Column(
                      children: [
                        // Gate Number Box
                        Container(
                          width: 38.w,
                          height: 28.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(color: Colors.white12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$gateNumber',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        // Saddle Number Box
                        Container(
                          width: 38.w,
                          height: 28.h,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF004D40,
                            ), // Dark green background
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: const Color(0xFF00CC99).withOpacity(0.4),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$saddleNumber',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 12.w),

                    // Column 2: Horse Info & Earnings
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            horseName.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '$weightText  $age $color $sex  ${index % 2 == 0 ? "KG DB SK" : "DB SK"}',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            earningsText,
                            style: TextStyle(
                              color: const Color(0xFF00CC99),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Column 3: Jockey, silk & stats info
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Jockey & Silk Row
                          Row(
                            children: [
                              Text(
                                'Ap ',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  jockeyName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              _buildJockeySilkIcon(index),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          // Stats row
                          Text(
                            'ST:$stVal  KGS:$kgsVal  HP:$hpVal',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          // EID and ID details
                          Text(
                            'EID: $expectedTime / $horseIdStr',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Navigation arrow
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_right,
                      color: Colors.white24,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ),

            // Expanded detail section (reused from original code)
            if (isExpanded) ...[
              const Divider(color: Colors.white12, height: 1),
              Padding(
                padding: EdgeInsets.all(14.w),
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
                            'Trainer: ${trainerName}',
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
                            final hId = horse?.id;
                            if (hId != null) {
                              controller.fetchHorseProfile(hId);
                              _showHorseDetails(context, horseName, hpVal);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'Profile History',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Show progress bars of suitability under expanded view for premium users
                    if (isPremium) ...[
                      SizedBox(height: 16.h),
                      const Divider(color: Colors.white12, height: 1),
                      SizedBox(height: 12.h),
                      _buildSuitabilityRow(
                        'Going Suitability',
                        entry.goingSuitabilityScore,
                      ),
                      SizedBox(height: 6.h),
                      _buildSuitabilityRow(
                        'Distance Suitability',
                        entry.distanceSuitabilityScore,
                      ),
                      SizedBox(height: 6.h),
                      _buildSuitabilityRow(
                        'Course Specialist',
                        entry.courseSpecialistScore,
                      ),
                      SizedBox(height: 6.h),
                      _buildSuitabilityRow('Draw Bias', entry.drawBiasScore),
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

  // ── JOCKEY SILK WIDGET (MINI SHIRT GRAPHIC USING CUSTOM PAINTER) ──────────
  Widget _buildJockeySilkIcon(int index) {
    final sets = [
      [Colors.red, Colors.white, Colors.blue],
      [Colors.yellow, Colors.black, Colors.red],
      [Colors.blue, Colors.yellow, Colors.white],
      [Colors.green, Colors.white, Colors.red],
      [Colors.orange, Colors.blue, Colors.yellow],
      [Colors.purple, Colors.white, Colors.green],
      [Colors.pink, Colors.black, Colors.cyan],
      [Colors.teal, Colors.white, Colors.orange],
    ];
    final colorSet = sets[index % sets.length];

    return CustomPaint(
      size: Size(22.w, 18.h),
      painter: JockeySilkPainter(
        bodyColor: colorSet[0],
        sleeveColor: colorSet[1],
        patternColor: colorSet[2],
      ),
    );
  }

  // ── BULLETIN TAB ─────────────────────────────────────────────────────────
  Widget _buildBulletinTab(RaceDetailsData details) {
    final entries = [...(details.entries ?? [])];
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No horses registered',
          style: const TextStyle(color: Colors.white38),
        ),
      );
    }

    // Sort by draw (starting gate) number ascending
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
    final age = horse?.age != null ? '${horse!.age}yo' : '4yo';
    final color = horse?.color ?? 'd';
    final sex = horse?.sex ?? 'k';
    final weightText = entry.weight != null
        ? '${entry.weight!.toStringAsFixed(0)} kg'
        : '56 kg';

    final horseNumber = entry.draw ?? (fallbackIndex + 1);

    final totalRaces = horse?.totalRaces ?? 0;
    final wins = horse?.wins ?? 0;
    final seconds = horse?.seconds ?? 0;
    final thirds = horse?.thirds ?? 0;
    final fourths = horse?.fourths ?? 0;

    final winRate = totalRaces > 0
        ? (wins / totalRaces * 100).toStringAsFixed(1)
        : '0';
    final placeRate = totalRaces > 0
        ? ((wins + seconds + thirds) / totalRaces * 100).toStringAsFixed(1)
        : '0';

    final rating = entry.normalizedScore?.toInt() ?? 75;

    return Obx(() {
      final isExpanded =
          controller.bulletinExpandedIndex.value == fallbackIndex;
      final isPremium = controller.isPremium.value;

      return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1419),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isExpanded
                ? const Color(0xFF00CC99).withOpacity(0.5)
                : Colors.white12,
            width: isExpanded ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => controller.toggleBulletinExpand(fallbackIndex),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.white12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$horseNumber',
                        style: TextStyle(
                          color: const Color(0xFF00CC99),
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            horseName.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '$age $color $sex · $weightText · Jockey: $jockeyName',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white24,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              const Divider(color: Colors.white12, height: 1),
              Padding(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection('PEDIGREE & TEAM', [
                      'Sire: ${horse?.sireName ?? "N/A"}',
                      'Dam: ${horse?.damName ?? "N/A"}',
                      'Trainer: $trainerName',
                      'Owner: ${horse?.owner ?? "N/A"}',
                    ]),
                    SizedBox(height: 12.h),
                    _buildDetailSection('CAREER HISTORY', [
                      'Starts: $totalRaces  Wins: $wins  Places: ${wins + seconds + thirds}',
                      'Win Rate: $winRate%  Place Rate: $placeRate%',
                      'Form: $wins-$seconds-$thirds-$fourths',
                    ]),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  // ── AI WIN PROBABILITY ANALYSIS TAB ──────────────────────────────────────
  Widget _buildAnalysisTab() {
    final details = controller.raceDetails.value;
    final entries = details?.entries ?? [];
    final trackType = details?.trackType ?? 'Turf';
    final distance = details?.distance ?? '';
    final runnersCount = entries.length;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      'Distance: $distance',
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
          ...List.generate(entries.length, (index) {
            final entry = entries[index];
            final rank = entry.rank ?? (index + 1);
            final name = entry.horse?.name ?? 'Unknown';
            final score = entry.normalizedScore?.toInt() ?? 75;

            final rankColors = [
              const Color(0xFFE53935),
              const Color(0xFF1E88E5),
              const Color(0xFF43A047),
              const Color(0xFF8E24AA),
              const Color(0xFFFB8C00),
            ];
            final rankColor = rankColors[(rank - 1) % rankColors.length];

            Color barColor = Colors.orange;
            if (score >= 70) {
              barColor = const Color(0xFF00CC99);
            } else if (score < 50) {
              barColor = Colors.redAccent;
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
              Expanded(
                child: Text(
                  name.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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

  // ── STATISTICS GRID TAB ──────────────────────────────────────────────────
  Widget _buildStatisticsTab() {
    final stats = controller.raceStats.value;
    if (controller.isStatsLoading.value && stats == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00CC99)),
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
      padding: EdgeInsets.all(12.w),
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 1.1,
      children: [
        _buildStatCard(
          'EARNINGS',
          (stats.earnings ?? [])
              .map(
                (e) => _StatItem(
                  '${e.horseName}: ${e.amount}',
                  (e.percentage ?? 0) / 100.0,
                ),
              )
              .toList(),
        ),
        _buildStatCard(
          'ORIGIN',
          (stats.origin ?? [])
              .map(
                (e) => _StatItem(
                  '${e.country} ${e.percentage}%',
                  (e.percentage ?? 0) / 100.0,
                ),
              )
              .toList(),
        ),
        _buildStatCard(
          'DISTANCE',
          (stats.distance ?? [])
              .map(
                (e) => _StatItem(
                  '${e.label}: ${e.detail}',
                  (e.percentage ?? 0) / 100.0,
                ),
              )
              .toList(),
        ),
        _buildStatCard(
          'TRACK',
          (stats.track ?? [])
              .map(
                (e) => _StatItem(
                  '${e.surface}: ${e.detail}',
                  (e.percentage ?? 0) / 100.0,
                ),
              )
              .toList(),
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
              color: const Color(0xFF00CC99),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2.r),
                      child: LinearProgressIndicator(
                        value: items[index].value,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF00796B),
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

  // ── INFO BOXES / PROGRESS BARS HELPERS ──────────────────────────────────
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
      barColor = const Color(0xFF00CC99);
    } else if (val < 50) {
      barColor = const Color(0xFFE57373);
    }
    return Row(
      children: [
        SizedBox(
          width: 120.w,
          child: Text(
            label,
            style: TextStyle(color: Colors.white38, fontSize: 11.sp),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(child: _buildProgressBar(val / 100, barColor)),
        SizedBox(width: 8.w),
        SizedBox(
          width: 28.w,
          child: Text(
            score != null ? '${score.toStringAsFixed(0)}' : 'N/A',
            style: TextStyle(
              color: score != null ? barColor : Colors.white24,
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  // ── HORSE DETAILS CAROUSEL SHEET ─────────────────────────────────────────
  void _showHorseDetails(BuildContext context, String horseName, int hpVal) {
    Get.bottomSheet(
      Obx(() {
        if (controller.isHorseLoading.value) {
          return Container(
            height: Get.height * 0.85,
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              border: Border.all(color: Colors.white12),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00CC99)),
              ),
            ),
          );
        }

        final horse = controller.horseDetails.value;
        if (horse == null) {
          return Container(
            height: Get.height * 0.85,
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              border: Border.all(color: Colors.white12),
            ),
            child: Center(
              child: Text(
                'Failed to load career profile',
                style: TextStyle(color: Colors.white38, fontSize: 14.sp),
              ),
            ),
          );
        }

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

        final results = horse.results ?? [];
        final totalEarnings = horse.totalEarnings ?? 0.0;
        final earningsText = _formatCurrency(totalEarnings);
        final last6Form = results
            .take(6)
            .map((r) => '${r.position ?? ""}')
            .join('');

        return Container(
          height: Get.height * 0.85,
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            border: Border.all(color: Colors.white12),
          ),
          padding: EdgeInsets.all(20.w),
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (horse.name ?? horseName).toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${horse.age ?? 4}yo ${horse.color ?? "d"} · ${horse.country ?? "TR"}',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white38,
                        size: 24.sp,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
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
                      'Stats: $winRate% Win | $top3Rate% Top 3 | Last 6: $last6Form',
                      style: TextStyle(
                        color: const Color(0xFF00CC99),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(child: _buildInfoBox('HP Score', '$hpVal')),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildInfoBox('Total Earnings', earningsText),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                _buildPopupSection(
                  'PEDIGREE',
                  'Sire: ${horse.sireName ?? "N/A"} · Dam: ${horse.damName ?? "N/A"}',
                ),
                SizedBox(height: 16.h),
                _buildPopupSection(
                  'TEAM',
                  'Owner: ${horse.owner ?? "N/A"} · Trainer: ${horse.trainer ?? "N/A"}',
                ),
                SizedBox(height: 20.h),
                Text(
                  'RACE HISTORY (LAST 6)',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Expanded(
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, idx) {
                      final run = results[idx];
                      final pos = run.position ?? 0;
                      Color badgeColor = Colors.grey;
                      if (pos == 1)
                        badgeColor = const Color(0xFF1B5E20);
                      else if (pos == 2)
                        badgeColor = const Color(0xFF2E7D32);
                      else if (pos == 3)
                        badgeColor = Colors.orange;

                      return _buildHistoryItem(
                        '$pos',
                        run.race?.name ?? 'Race ${idx + 1}',
                        '${run.race?.distance ?? ""} · ${run.race?.trackType ?? ""}',
                        badgeColor,
                      );
                    },
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
            style: TextStyle(color: Colors.white38, fontSize: 11.sp),
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
        SizedBox(height: 6.h),
        Text(
          content,
          style: TextStyle(color: Colors.white, fontSize: 13.sp),
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
                  style: TextStyle(color: Colors.white, fontSize: 13.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                subtitle,
                style: TextStyle(color: Colors.white38, fontSize: 11.sp),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          const Divider(color: Colors.white12, height: 1),
        ],
      ),
    );
  }

  // ── PREMIUM OVERLAYS & PROMPT HELPERS ────────────────────────────────────
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
              width: 64.w,
              height: 64.w,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
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
                color: Colors.white38,
                fontSize: 12.sp,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: () => _showPremiumPrompt(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '✦  Upgrade to Premium',
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

  Widget _buildLockedCard(BuildContext context, Widget card) {
    return Stack(
      children: [
        IgnorePointer(child: Opacity(opacity: 0.2, child: card)),
        Positioned.fill(
          child: GestureDetector(
            onTap: () => _showPremiumPrompt(context),
            child: Container(
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: const Color(0xFFFFD700),
                      size: 16.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'PREMIUM ONLY',
                      style: TextStyle(
                        color: const Color(0xFFFFD700),
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

  void _showPremiumPrompt(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1419),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
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
              SizedBox(height: 20.h),
              Icon(
                Icons.workspace_premium_rounded,
                color: const Color(0xFFFFD700),
                size: 44.sp,
              ),
              SizedBox(height: 12.h),
              Text(
                'Unlock Premium Access',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Unlock advanced AI analytics, win probabilities,\nfair odds, and daily horse ratings.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13.sp,
                  height: 1.5,
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
                      colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'View Plans',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15.sp,
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

  // ── HELPER UTILS ──────────────────────────────────────────────────────────
  String _formatCurrency(double amount) {
    final s = amount.toInt().toString();
    if (s.length > 3) {
      final buffer = StringBuffer();
      int count = 0;
      for (int i = s.length - 1; i >= 0; i--) {
        buffer.write(s[i]);
        count++;
        if (count % 3 == 0 && i != 0) buffer.write(',');
      }
      return '₺${buffer.toString().split('').reversed.join('')}';
    }
    return '₺$s';
  }

  String _getDayFromDate(String dateIso) {
    try {
      final parsed = DateTime.parse(dateIso);
      return '${parsed.day}';
    } catch (_) {
      return '23';
    }
  }
}

// ── CUSTOM JOCKEY SILK PAINTER ─────────────────────────────────────────────
class JockeySilkPainter extends CustomPainter {
  final Color bodyColor;
  final Color sleeveColor;
  final Color patternColor;

  JockeySilkPainter({
    required this.bodyColor,
    required this.sleeveColor,
    required this.patternColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.fill;
    final sleevePaint = Paint()
      ..color = sleeveColor
      ..style = PaintingStyle.fill;
    final patternPaint = Paint()
      ..color = patternColor
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.white30
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    // Draw body
    path.moveTo(size.width * 0.25, size.height * 0.1);
    path.lineTo(size.width * 0.75, size.height * 0.1);
    path.lineTo(size.width * 0.75, size.height * 0.9);
    path.lineTo(size.width * 0.25, size.height * 0.9);
    path.close();
    canvas.drawPath(path, bodyPaint);
    canvas.drawPath(path, borderPaint);

    // Left sleeve
    final leftSleeve = Path()
      ..moveTo(size.width * 0.25, size.height * 0.15)
      ..lineTo(0.0, size.height * 0.4)
      ..lineTo(size.width * 0.12, size.height * 0.5)
      ..lineTo(size.width * 0.25, size.height * 0.35)
      ..close();
    canvas.drawPath(leftSleeve, sleevePaint);
    canvas.drawPath(leftSleeve, borderPaint);

    // Right sleeve
    final rightSleeve = Path()
      ..moveTo(size.width * 0.75, size.height * 0.15)
      ..lineTo(size.width, size.height * 0.4)
      ..lineTo(size.width * 0.88, size.height * 0.5)
      ..lineTo(size.width * 0.75, size.height * 0.35)
      ..close();
    canvas.drawPath(rightSleeve, sleevePaint);
    canvas.drawPath(rightSleeve, borderPaint);

    // Draw central dot emblem
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.15,
      patternPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StatItem {
  final String label;
  final double value;
  _StatItem(this.label, this.value);
}
