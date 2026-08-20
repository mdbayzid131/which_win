// ignore_for_file: unused_element, unused_local_variable
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/data/models/race_details_model.dart';
import 'package:which_win/data/models/race_model.dart';
import '../controllers/race_details_controller.dart';

class RaceDetailsView extends GetView<RaceDetailsController> {
  const RaceDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1F1F),
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
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE6A817)),
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

  // ── APP BAR ─────────────────────────────────────────────────────────────
  Widget _buildAppBar(
    BuildContext context,
    String locationName,
    String dayStr,
  ) {
    return Container(
      color: const Color(0xFF0C1F1F),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back arrow
          GestureDetector(
            onTap: () => Get.back(),
            child: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 16.w),

          // Location name
          Expanded(
            child: Text(
              locationName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Day number badge (right side)
          if (dayStr.isNotEmpty) _buildAppBarBadge(dayStr),
        ],
      ),
    );
  }


  Widget _buildAppBarBadge(String label, {bool isLive = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isLive
            ? Colors.red.withValues(alpha: 0.15)
            : const Color(0xFF0C1F1F),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(
          color: isLive ? Colors.red.withValues(alpha: 0.7) : Colors.white24,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive) ...[
            Container(
              width: 5.w,
              height: 5.w,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: TextStyle(
              color: isLive ? Colors.red : Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ── WEATHER & TRACK INFO BANNER ────────────────────────────────────
  Widget _buildWeatherBanner(RaceDetailsData? details) {
    final locationName = details?.location ?? 'Ankara';
    final trackType = details?.trackType ?? 'Turf';
    final isTurf =
        trackType.toLowerCase().contains('turf') ||
        trackType.toLowerCase().contains('çim');

    return Container(
      width: double.infinity,
      color: const Color(0xFF132E2E),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$locationName Racecourse',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Track: ${isTurf ? "Turf (Good)" : "Dirt (Normal)"}',
            style: TextStyle(
              color: const Color(0xFF2D9B83),
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ── HORIZONTAL RACE SELECTOR BAR ─────────────────────────────────────────
  Widget _buildHorizontalRaceSelector() {
    final races = controller.siblingRaces;
    if (races.isEmpty) {
      return Container(
        height: 60.h,
        color: const Color(0xFF0C1F1F),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          itemCount: 8,
          itemBuilder: (context, index) {
            final isSelected = index == 0;
            return _buildRaceSelectorTab(
              isSelected: isSelected,
              title: '${index + 1}.\nKOŞU',
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
      color: const Color(0xFF0C1F1F),
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
            title: '${index + 1}.\nKOŞU',
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
        width: 70.w,
        margin: EdgeInsets.symmetric(horizontal: 3.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D9B83) : const Color(0xFF132E2E),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF2D9B83) : Colors.white12,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
      ),
    );
  }

  // ── SELECTED RACE DETAILS BANNER ──────────────────────────────────────────
  Widget _buildSelectedRaceDetailsBanner(
    RaceDetailsData? details,
    RaceModel? currentRace,
  ) {
    final timeVal = details?.time ?? currentRace?.time ?? '';
    final distanceVal = details?.distance ?? currentRace?.distance ?? '';
    final trackType = details?.trackType ?? currentRace?.trackType ?? 'Turf';
    final isTurf =
        trackType.toLowerCase().contains('turf') ||
        trackType.toLowerCase().contains('çim');
    final surfaceStr = isTurf ? 'Turf' : 'Dirt';
    final raceName = details?.name ?? currentRace?.name ?? 'Race';
    final prize = details?.prize ?? currentRace?.prize;

    final String prizeText = (prize != null && prize.isNotEmpty && prize != 'N/A')
        ? 'Prize: $prize'
        : '';

    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF112828),
            border: Border(
              top: BorderSide(color: Colors.white10),
              bottom: BorderSide(color: Colors.white10),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Text(
            [
              if (timeVal.isNotEmpty) timeVal,
              if (distanceVal.isNotEmpty) distanceVal,
              surfaceStr,
              raceName,
            ].join('  ·  '),
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
        if (prizeText.isNotEmpty)
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF112828),
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            child: Text(
              prizeText,
              style: TextStyle(
                color: const Color(0xFFE6A817),
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  // ── SUB-TAB BAR (OUTER) ───────────────────────────────────────────────────
  Widget _buildSubTabBar() {
    return Container(
      color: const Color(0xFF0C1F1F),
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Obx(() {
        final currentTab = controller.selectedTab.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSubTabItem('İSTATİSTİK', 0, currentTab),
            _buildSubTabItem('ANALYSIS', 1, currentTab),
            _buildSubTabItem('PREDICTION', 2, currentTab),
            _buildSubTabItem('RESULT', 3, currentTab),
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
              color: isSelected ? const Color(0xFFE6A817) : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFE6A817) : Colors.white54,
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // ── OUTER TAB CONTENT ROUTER ──────────────────────────────────────────────
  Widget _buildTabContent(BuildContext context, RaceDetailsData? details) {
    if (details == null) {
      return const Center(
        child: Text(
          'Failed to load details',
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    switch (controller.selectedTab.value) {
      case 0:
        return _buildStatisticsTabContent(context, details);
      case 1:
        // ANALYSIS - AI win analysis probability progress bars
        final isPremium = controller.isPremium.value;
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
        final isPremium = controller.isPremium.value;
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

  // ── NESTED STATISTICS TAB VIEW ────────────────────────────────────────────
  Widget _buildStatisticsTabContent(
    BuildContext context,
    RaceDetailsData details,
  ) {
    return _buildOriginalHorseListView(context, details);
  }

  Widget _buildInnerMainTabBar() {
    return Container(
      color: const Color(0xFF0A2626),
      child: Obx(() {
        final currentMainTab = controller.selectedMainTab.value;
        return Row(
          children: [
            _buildInnerMainTabItem('Koşu Analizi', 0, currentMainTab),
            _buildInnerMainTabItem('Atlar', 1, currentMainTab),
            _buildInnerMainTabItem('Jokeyler', 2, currentMainTab),
          ],
        );
      }),
    );
  }

  Widget _buildInnerMainTabItem(String label, int index, int selectedIndex) {
    final isSelected = index == selectedIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          controller.selectedMainTab.value = index;
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFFE6A817)
                    : Colors.transparent,
                width: 3.w,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFE6A817) : Colors.white60,
              fontSize: 13.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKosuAnaliziInnerSubTabBar() {
    final subTabs = [
      'Atlar Listesi',
      'Galoplar & Sprintler',
      'En İyi Derece',
      'Son Koşular',
      'Birincilikler',
      'Kim Kiminle Koştu',
      'Kim Kimi Geçti',
    ];
    return Container(
      height: 38.h,
      color: const Color(0xFF0A2626),
      child: Obx(() {
        final currentSubTab = controller.selectedKosuAnaliziSubTab.value;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          itemCount: subTabs.length,
          itemBuilder: (context, index) {
            final isSelected = index == currentSubTab;
            return GestureDetector(
              onTap: () => controller.selectedKosuAnaliziSubTab.value = index,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? const Color(0xFFE6A817)
                          : Colors.transparent,
                      width: 2.w,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  subTabs[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontSize: 11.sp,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildAtlarInnerSubTabBar() {
    final subTabs = ['Atlar', 'Kısraklar', 'Aygırlar', 'Kısrak Babaları'];
    return Container(
      height: 38.h,
      color: const Color(0xFF0A2626),
      child: Obx(() {
        final currentSubTab = controller.selectedAtlarSubTab.value;
        return Row(
          children: List.generate(subTabs.length, (index) {
            final isSelected = index == currentSubTab;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedAtlarSubTab.value = index,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected
                            ? const Color(0xFFE6A817)
                            : Colors.transparent,
                        width: 2.w,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    subTabs[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontSize: 11.sp,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildJokeylerInnerSubTabBar() {
    final subTabs = ['Jokeyler', 'Aprantiler'];
    return Container(
      height: 38.h,
      color: const Color(0xFF0A2626),
      child: Obx(() {
        final currentSubTab = controller.selectedJokeylerSubTab.value;
        return Row(
          children: List.generate(subTabs.length, (index) {
            final isSelected = index == currentSubTab;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedJokeylerSubTab.value = index,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected
                            ? const Color(0xFFE6A817)
                            : Colors.transparent,
                        width: 2.w,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    subTabs[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontSize: 11.sp,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildOriginalHorseListView(
    BuildContext context,
    RaceDetailsData details,
  ) {
    final entries = details.entries ?? [];
    if (entries.isEmpty) {
      return const Center(
        child: Text(
          'No horses registered',
          style: TextStyle(color: Colors.white38),
        ),
      );
    }
    final isPremium = controller.isPremium.value;
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final score = entry.normalizedScore?.toInt() ?? 0;

        Color scoreColor = Colors.orange;
        if (score >= 70) {
          scoreColor = const Color(0xFF268060);
        } else if (score < 50) {
          scoreColor = Colors.red;
        }

        final card = _buildTurkeyStyleHorseCard(
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
  }

  // ── TAB CONTENT ROUTERS & SUB-VIEWS ───────────────────────────────────────
  Widget _buildMainContentArea(BuildContext context, RaceDetailsData? details) {
    final mainTab = controller.selectedMainTab.value;
    switch (mainTab) {
      case 0:
        return _buildKosuAnaliziContent(context, details);
      case 1:
        return _buildAtlarContent(context, details);
      case 2:
        return _buildJokeylerContent(context, details);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildKosuAnaliziContent(
    BuildContext context,
    RaceDetailsData? details,
  ) {
    final subTab = controller.selectedTab.value;
    switch (subTab) {
      case 0: // Galoplar & Sprintler
      case 1: // En İyi Derece
        return _buildEnIyiDereceTab();
      case 2: // Son Koşular
        return _buildSonKosularTab();
      case 3: // Birincilikler
        return _buildBirinciliklerTab();
      case 4: // Kim Kiminle Koştu
        return _buildKimKiminleKostuTab();
      case 5: // Kim Kimi Geçti
        return _buildKimKimiGectiTab();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── 1. EN İYİ DERECE & GALOPLAR VIEW ──────────────────────────────────────
  Widget _buildEnIyiDereceTab() {
    final list = [
      {
        'horse': 'QUEEN OF HAPPINESS',
        'date': '14.07.2024 / İzmir',
        'condition': '3i Handikap-15 / Kum:Normal',
        'jockey': 'N. AVCİ',
        'weight': '56 kg',
        'hp': '46',
        'duration': '1.17.71',
        'position': '11 / 15',
        'odds': 'G:7.60',
      },
      {
        'horse': 'HELLBOY',
        'date': '18.03.2024 / Bursa',
        'condition': '3i Maiden / Kum:Normal',
        'jockey': 'S. İPEK',
        'weight': '58 kg',
        'hp': '33',
        'duration': '1.15.17',
        'position': '4 / 12',
        'odds': 'G:3.00',
      },
      {
        'horse': 'ESİN GÜZELİ',
        'date': '03.07.2025 / Kocaeli',
        'condition': '3i Handikap-14 / Kum:Normal',
        'jockey': 'O. ATMACA',
        'weight': '53.5 kg',
        'hp': '47',
        'duration': '1.14.93',
        'position': '3 / 10',
        'odds': 'G:3.85',
      },
      {
        'horse': 'VICENTE CALDERON',
        'date': '18.11.2025 / Adana',
        'condition': '3+i Handikap-14 / Kum:Normal',
        'jockey': 'M.G.ARSLAN',
        'weight': '55.5 kg',
        'hp': '38',
        'duration': '1.16.03',
        'position': '3 / 16',
        'odds': 'G:11.35',
      },
      {
        'horse': 'TILO GIRL',
        'date': '27.08.2024 / Kocaeli',
        'condition': '3i Maiden / Kum:Normal',
        'jockey': 'O. ÖZTÜRK',
        'weight': '57 kg',
        'hp': '20',
        'duration': '1.16.64',
        'position': '2 / 11',
        'odds': 'G:41.50',
      },
      {
        'horse': 'KUMRALIM',
        'date': '07.03.2024 / Bursa',
        'condition': '3i Maiden / Kum:Normal',
        'jockey': 'T. YILDIZ',
        'weight': '57 kg',
        'hp': '20',
        'duration': '1.15.37',
        'position': '2 / 16',
        'odds': 'G:7.10',
      },
      {
        'horse': 'TRUE ANGEL',
        'date': '26.09.2025 / İzmir',
        'condition': '2i Maiden / Çim:Normal',
        'jockey': 'Y. GÖKÇE',
        'weight': '57.5 kg',
        'hp': '22',
        'duration': '1.16.39',
        'position': '2 / 16',
        'odds': 'G:14.05',
      },
    ];

    return Column(
      children: [
        Container(
          color: const Color(0xFF132E2E),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  'AT / TARİH / ŞART / PİST',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'JOKEY',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'SÜRE / SIRA / G',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            itemCount: list.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.white12, height: 1),
            itemBuilder: (context, index) {
              final item = list[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['horse']!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            item['date']!,
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 10.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            item['condition']!,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['jockey']!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${item['weight']!} / HP: ${item['hp']!}',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.play_circle_fill,
                                color: const Color(0xFFE6A817),
                                size: 14.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                item['duration']!,
                                style: TextStyle(
                                  color: const Color(0xFFE6A817),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            item['position']!,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            item['odds']!,
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── 2. SON KOŞULAR VIEW ────────────────────────────────────────────────────
  Widget _buildSonKosularTab() {
    final list = [
      {
        'num': '1',
        'horse': 'QUEEN OF HAPPINESS',
        'jockeyLabel': 'E. AKDUMAN AP',
        'st': '10',
        'equipment': 'DB DS SK SKG',
        'weight': '60 kg',
        'lastRunDate': '14.07.2024 / İzmir',
        'lastRunInfo': '3i Handikap-15 DB SK SKG / 1200m Kum: Normal',
        'lastRunJockey': 'N. AVCİ / 56 kg / HP: 46',
        'duration': '1.17.71',
        'pos': '11/15',
        'gny': 'GNY: 7.60',
        'rate': '5-%10.44',
      },
      {
        'num': '2',
        'horse': 'HELLBOY',
        'jockeyLabel': 'Y. T.AKKAYA AP',
        'st': '9',
        'equipment': 'KG SK',
        'weight': '59.5 kg',
        'lastRunDate': '18.03.2024 / Bursa',
        'lastRunInfo': '3i Maiden KG SK / 1200m Kum: Normal',
        'lastRunJockey': 'S. İPEK / 58 kg / HP: 33',
        'duration': '1.15.17',
        'pos': '4/12',
        'gny': 'GNY: 3.00',
        'rate': '2-%20.60',
      },
      {
        'num': '3',
        'horse': 'ESİN GÜZELİ',
        'jockeyLabel': 'Y. T.AKKAYA AP',
        'st': '7',
        'equipment': 'DB K KG',
        'weight': '57.5 kg',
        'lastRunDate': '17.12.2023 / İzmir',
        'lastRunInfo': '2i Maiden KG SK / 1200m Kum: Nemli',
        'lastRunJockey': 'GÖKH. GÖKÇE / 57 kg / HP: 0',
        'duration': '1.15.64',
        'pos': '5/9',
        'gny': 'GNY: 19.95',
        'rate': '6-%5.07',
      },
    ];

    return Column(
      children: [
        Container(
          color: const Color(0xFF0A2626),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            children: [
              _buildFilterDropdown('Tüm Atlar'),
              SizedBox(width: 8.w),
              _buildFilterDropdown('Tüm Atlar'),
              const Spacer(),
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF132E2E),
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: Colors.white12),
                ),
                child: Icon(
                  Icons.filter_list,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(12.w),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2626),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF132E2E),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              item['num']!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
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
                                  '${item['horse']!} ${item['jockeyLabel']!}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'St: ${item['st']!} | ${item['equipment']!} | ${item['weight']!}',
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.white30,
                            size: 20.sp,
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    Container(
                      color: Colors.black.withValues(alpha: 0.15),
                      padding: EdgeInsets.all(12.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['lastRunDate']!,
                                  style: TextStyle(
                                    color: const Color(0xFFE6A817),
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  item['lastRunInfo']!,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10.sp,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Jokey: ${item['lastRunJockey']!}',
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  item['duration']!,
                                  style: TextStyle(
                                    color: const Color(0xFFE6A817),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  item['pos']!,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11.sp,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  '${item['gny']!} / ${item['rate']!}',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFF132E2E),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 12.sp),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 14.sp),
        ],
      ),
    );
  }

  // ── 3. BİRİNCİLİKLER VIEW ──────────────────────────────────────────────────
  Widget _buildBirinciliklerTab() {
    final list = [
      {
        'num': '1',
        'horse': 'QUEEN OF HAPPINESS',
        'info': 'St: 10 DB DS SK SKG / 60 kg',
        'jockey': 'E. AKDUMAN AP / 59.5 kg',
        'races': '39 Koşu',
        'wins': '1 Birincilik',
      },
      {
        'num': '2',
        'horse': 'HELLBOY',
        'info': 'St: 9 KG SK / 59.5 kg',
        'jockey': 'Y. T.AKKAYA AP / 59.5 kg',
        'races': '22 Koşu',
        'wins': '1 Birincilik',
      },
      {
        'num': '3',
        'horse': 'ESİN GÜZELİ',
        'info': 'St: 7 DB K KG / 57.5 kg',
        'jockey': 'T. YILDIZ / 62.5 kg',
        'races': '19 Koşu',
        'wins': '1 Birincilik',
      },
      {
        'num': '4',
        'horse': 'VICENTE CALDERON',
        'info': 'St: 2 DB K KG ÖG / 57 kg',
        'jockey': 'ER. CANKILIÇ AP / 59.5 kg',
        'races': '17 Koşu',
        'wins': '2 Birincilik',
      },
      {
        'num': '5',
        'horse': 'TILO GIRL',
        'info': 'St: 8 K KG / 59 kg',
        'jockey': 'A. MEH.ALTIN AP / 59 kg',
        'races': '22 Koşu',
        'wins': '3 Birincilik',
      },
      {
        'num': '6',
        'horse': 'KUMRALIM',
        'info': 'St: 4 DB SKG SK / 56.5 kg',
        'jockey': 'E. AKDUMAN AP / 59.5 kg',
        'races': '18 Koşu',
        'wins': '1 Birincilik',
      },
    ];

    return Column(
      children: [
        Container(
          color: const Color(0xFF132E2E),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            children: [
              Expanded(
                flex: 6,
                child: Text(
                  'AT',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'SIRA NO / BİRİNCİLİK',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            itemCount: list.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.white12, height: 1),
            itemBuilder: (context, index) {
              final item = list[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item['num']!}- ${item['horse']!}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            item['info']!,
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 10.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Jokey: ${item['jockey']!}',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item['races']!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            item['wins']!,
                            style: TextStyle(
                              color: const Color(0xFFE6A817),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── 4. KİM KİMİNLE KOŞTU VIEW ──────────────────────────────────────────────
  Widget _buildKimKiminleKostuTab() {
    final list = [
      {
        'date': '18.06.2026 / Kocaeli',
        'dist': '1200m Kum: Normal',
        'horses': '2- ESİN GÜZELİ (3), 4- KATANA BOY (12)',
        'meta': '21:30 / 1200 Kum / 3 ve Yukarı İngilizler / HAND-14',
        'runners': [
          {
            'sira': '1',
            'name': '5- EL QUIMICO',
            'age': '3y de',
            'st': 'St: 8 129716 HP: 42',
            'jockey': 'N. AVCİ',
            'weight': '53 kg (+1,80)',
            'subjockey': '2.5B',
            'gny': 'G: 4.30',
            'agf': '3. %13.61',
            'drc': 'Drc: 1.16.02',
          },
          {
            'sira': '2',
            'name': '3- ESİN GÜZELİ',
            'age': '4y ak DB K KG',
            'st': 'St: 9 252472 HP: 46',
            'jockey': 'T. YILDIZ',
            'weight': '61 kg',
            'subjockey': 'YB',
            'gny': 'G: 14.05',
            'agf': '11. %2.53',
            'drc': 'Drc: 1.16.39',
          },
          {
            'sira': '3',
            'name': '13- FEMALE WARRIOR',
            'age': '3y ad DB SK',
            'st': 'St: 6 180073 HP: 35',
            'jockey': 'M. A.SOLMAZ',
            'weight': '52 kg',
            'subjockey': '1B',
            'gny': 'G: 13.30',
            'agf': '5. %6.53',
            'drc': 'Drc: 1.16.47',
          },
          {
            'sira': '4',
            'name': '12- KATANA BOY',
            'age': '4y ae DB KG SK',
            'st': 'St: 3 765774 HP: 34',
            'jockey': 'O. ATMACA',
            'weight': '55 kg',
            'subjockey': 'BR',
            'gny': 'G: 11.50',
            'agf': '7. %5.11',
            'drc': 'Drc: 1.16.59',
          },
          {
            'sira': '5',
            'name': '2- KUPA AVICISI',
            'age': '4y de BB DB K KG',
            'st': 'St: 5 002245 HP: 48',
            'jockey': 'F. R.BEBEK',
            'weight': '62 kg',
            'subjockey': '-',
            'gny': 'G: 4.50',
            'agf': '2. %17.12',
            'drc': 'Drc: 1.16.60',
          },
        ],
      },
    ];

    return Column(
      children: [
        Container(
          color: const Color(0xFF0A2626),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            children: [
              _buildFilterDropdown('Tüm Atlar'),
              SizedBox(width: 8.w),
              _buildFilterDropdown('Tüm Atlar'),
              const Spacer(),
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF132E2E),
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: Colors.white12),
                ),
                child: Icon(
                  Icons.filter_list,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(12.w),
            itemCount: list.length,
            itemBuilder: (context, idx) {
              final group = list[idx];
              final runners = group['runners'] as List<Map<String, String>>;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFFFF3D6).withValues(alpha: 0.95),
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              group['date'] as String,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.black54,
                              size: 18.sp,
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          group['dist'] as String,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 11.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          group['horses'] as String,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: Colors.black54,
                              size: 14.sp,
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.play_arrow,
                              color: Colors.black54,
                              size: 16.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              group['meta'] as String,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: const Color(0xFF132E2E),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20.w,
                          child: Text(
                            'SIRA',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          flex: 4,
                          child: Text(
                            'NO / AT',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'JOKEY',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'GNY / AGF / DRC',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...runners.map((runner) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF0A2626),
                        border: Border(
                          bottom: BorderSide(color: Colors.white10),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20.w,
                            child: Text(
                              runner['sira']!,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  runner['name']!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  runner['age']!,
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10.sp,
                                  ),
                                ),
                                Text(
                                  runner['st']!,
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  runner['jockey']!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  runner['weight']!,
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10.sp,
                                  ),
                                ),
                                Text(
                                  runner['subjockey']!,
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  runner['gny']!,
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  runner['agf']!,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10.sp,
                                  ),
                                ),
                                Text(
                                  runner['drc']!,
                                  style: TextStyle(
                                    color: const Color(0xFFE6A817),
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: 20.h),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ── 5. KİM KİMİ GEÇTİ VIEW ─────────────────────────────────────────────────
  Widget _buildKimKimiGectiTab() {
    final list = [
      {'horse': '1- ALMUTANABİY', 'raced': 'GENÇYÜREK', 'beat': '1 (1)'},
      {'horse': '2- GENÇYÜREK', 'raced': 'İLKUTHAN', 'beat': '1 (1)'},
      {'horse': '3- İLKUTHAN', 'raced': 'HIZLI BERATIM', 'beat': '1 (1)'},
      {'horse': '4- TARLABAŞI', 'raced': 'ALPAYMAN', 'beat': '2 (2)'},
      {'horse': '5- YETİM AMCA', 'raced': 'CABİRE SULTAN', 'beat': '1 (2)'},
      {'horse': '6- HIZLI BERATIM', 'raced': 'BABA TUNA', 'beat': '1 (1)'},
      {'horse': '7- TUNA ADAM', 'raced': 'ZAMAN HARİKA', 'beat': '0 (1)'},
      {'horse': '8- ALPAYMAN', 'raced': 'THOTH', 'beat': '0 (1)'},
    ];

    return Column(
      children: [
        Container(
          color: const Color(0xFF132E2E),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  'AT',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'YARIŞTIĞI AT',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'GEÇTİ (KOŞU)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            itemCount: list.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.white12, height: 1),
            itemBuilder: (context, index) {
              final item = list[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        item['horse']!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        item['raced']!,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        item['beat']!,
                        style: TextStyle(
                          color: const Color(0xFFE6A817),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── 6. ATLAR TAB VIEW ──────────────────────────────────────────────────────
  Widget _buildAtlarContent(BuildContext context, RaceDetailsData? details) {
    final list = [
      {
        'rank': '1',
        'name': 'LOCO SUGAR',
        'info': 'İngiliz HP: 94 / 4 Birincilik',
        'owner': 'KEMAL KURT',
        'earnings': '₺36.900.000',
      },
      {
        'rank': '2',
        'name': 'UPAMECANO',
        'info': 'İngiliz HP: 45 / 2 Birincilik',
        'owner': 'MURAT YILDIRIM, TALİP ÖZTÜRK, UMUT HEPSAĞ',
        'earnings': '₺11.220.000',
      },
      {
        'rank': '3',
        'name': 'SPECIAL MAN',
        'info': 'İngiliz HP: 0 / 3 Birincilik',
        'owner': 'MELİH TEMEL',
        'earnings': '₺10.663.200',
      },
      {
        'rank': '4',
        'name': 'NEURO MATH',
        'info': 'İngiliz HP: 0 / 2 Birincilik',
        'owner': 'YENER GİRİŞKEN, AREK GÖVER',
        'earnings': '₺9.898.200',
      },
      {
        'rank': '5',
        'name': 'THE PROTECTER',
        'info': 'İngiliz HP: 0 / 4 Birincilik',
        'owner': 'NİMET ARİF KURTEL',
        'earnings': '₺9.642.000',
      },
      {
        'rank': '6',
        'name': 'BAY NALÇAKAN',
        'info': 'İngiliz HP: 0 / 4 Birincilik',
        'owner': 'EMRAH NALÇAKAN',
        'earnings': '₺9.444.000',
      },
      {
        'rank': '7',
        'name': 'WARDENCLYFFE',
        'info': 'İngiliz HP: 73 / 5 Birincilik',
        'owner': 'ÖZGÜR DEMİR',
        'earnings': '₺9.380.400',
      },
    ];

    return Column(
      children: [
        Container(
          color: const Color(0xFF132E2E),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            children: [
              SizedBox(
                width: 24.w,
                child: Text(
                  '#',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'AT',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'SAHİP',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'SEZON KAZANCI',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            itemCount: list.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.white12, height: 1),
            itemBuilder: (context, index) {
              final item = list[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24.w,
                      child: Text(
                        item['rank']!,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name']!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            item['info']!,
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        item['owner']!,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.sp,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        item['earnings']!,
                        style: TextStyle(
                          color: const Color(0xFFE6A817),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── 7. JOKEYLER TAB VIEW ───────────────────────────────────────────────────
  Widget _buildJokeylerContent(BuildContext context, RaceDetailsData? details) {
    final list = [
      {
        'rank': '1',
        'name': 'N. AVCİ',
        'info': 'HP Score: 92 / 45 Wins',
        'rides': '320 biniş',
        'earnings': '₺12.400.000',
      },
      {
        'rank': '2',
        'name': 'T. YILDIZ',
        'info': 'HP Score: 88 / 38 Wins',
        'rides': '280 biniş',
        'earnings': '₺9.800.000',
      },
      {
        'rank': '3',
        'name': 'O. ATMACA',
        'info': 'HP Score: 81 / 29 Wins',
        'rides': '240 biniş',
        'earnings': '₺7.500.000',
      },
      {
        'rank': '4',
        'name': 'E. AKDUMAN',
        'info': 'HP Score: 79 / 25 Wins',
        'rides': '210 biniş',
        'earnings': '₺6.900.000',
      },
      {
        'rank': '5',
        'name': 'M.G.ARSLAN',
        'info': 'HP Score: 75 / 22 Wins',
        'rides': '190 biniş',
        'earnings': '₺5.400.000',
      },
      {
        'rank': '6',
        'name': 'Y. GÖKÇE',
        'info': 'HP Score: 72 / 18 Wins',
        'rides': '170 biniş',
        'earnings': '₺4.800.000',
      },
    ];

    return Column(
      children: [
        Container(
          color: const Color(0xFF132E2E),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            children: [
              SizedBox(
                width: 24.w,
                child: Text(
                  '#',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'JOKEY',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'TOPLAM BİNİŞ',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'SEZON KAZANCI',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            itemCount: list.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.white12, height: 1),
            itemBuilder: (context, index) {
              final item = list[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24.w,
                      child: Text(
                        item['rank']!,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name']!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            item['info']!,
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        item['rides']!,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        item['earnings']!,
                        style: TextStyle(
                          color: const Color(0xFFE6A817),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
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

    // Gate vs Saddle number
    final gateNumber = entry.draw ?? entry.number ?? (index + 1);
    final saddleNumber = entry.number;

    // Earnings representation
    final earnings = horse?.totalEarnings;
    final earningsText = (earnings != null && earnings > 0)
        ? 'Earnings: ${_formatCurrency(earnings)}'
        : 'Earnings: N/A';

    // ST: Gate, KGS: Days since last run, HP: Horse power rating
    final stVal = gateNumber;
    final kgsVal = entry.lastRun ?? '-';
    final hpVal = entry.horsePower?.toInt() ?? entry.normalizedScore?.toInt() ?? 0;

    final equipmentText = entry.headgear ?? '';
    final bool isApprentice = jockeyName.toLowerCase().startsWith('ap ');
    final displayJockeyName = isApprentice
        ? jockeyName.substring(3).trim()
        : jockeyName;

    return Obx(() {
      final isExpanded = controller.expandedIndex.value == index;
      final isPremium = controller.isPremium.value;

      return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF112828),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isExpanded
                ? const Color(0xFFE6A817).withValues(alpha: 0.5)
                : Colors.white12,
            width: isExpanded ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
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
                    // Column 1: Gate box (light) and optional Saddle box (dark theme green/teal)
                    Column(
                      children: [
                        // Gate Number Box
                        Container(
                          width: 38.w,
                          height: 28.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
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
                        if (saddleNumber != null && saddleNumber != gateNumber) ...[
                          SizedBox(height: 6.h),
                          // Saddle Number Box
                          Container(
                            width: 38.w,
                            height: 28.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF004D40),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
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
                            [
                              if (weightText.isNotEmpty) weightText,
                              if (age.isNotEmpty) age,
                              if (color.isNotEmpty) color,
                              if (sex.isNotEmpty) sex,
                              if (equipmentText.isNotEmpty) equipmentText,
                            ].join('  '),
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            earningsText,
                            style: TextStyle(
                              color: const Color(0xFF2D9B83),
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
                              if (isApprentice)
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
                                  displayJockeyName,
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
                            'ST:$stVal  KGS:$kgsVal  HP:${hpVal > 0 ? hpVal : "-"}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          // Trainer info
                          Text(
                            'Trainer: $trainerName',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Navigation arrow
                    GestureDetector(
                      onTap: () {
                        final hId = horse?.id ?? entry.horseId;
                        if (hId != null && hId.isNotEmpty) {
                          controller.fetchHorseProfile(hId);
                          _showHorseDetails(context, horseName, hpVal);
                        } else {
                          controller.selectedKosuAnaliziSubTab.value = 1;
                          if (Get.currentRoute != '/HorseAnalysisView') {
                            Get.to(() => const HorseAnalysisView());
                          }
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 16.h,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.white10),
                          ),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_right,
                          color: const Color(0xFFE6A817),
                          size: 24.sp,
                        ),
                      ),
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
                            final hId = horse?.id ?? entry.horseId;
                            if (hId != null && hId.isNotEmpty) {
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
                              color: const Color(0xFF132E2E),
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

  // ── BULLETIN TAB (Redesigned Results) ────────────────────────────────────
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

    return Obx(() {
      final isExpanded =
          controller.bulletinExpandedIndex.value == fallbackIndex;

      return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF132E2E),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isExpanded ? const Color(0xFFE6A817) : Colors.white10,
            width: isExpanded ? 1.2 : 1.0,
          ),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => controller.toggleBulletinExpand(fallbackIndex),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A2626),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: const Color(0xFF2D9B83).withValues(alpha: 0.3),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$horseNumber',
                        style: TextStyle(
                          color: const Color(0xFFE6A817),
                          fontSize: 16.sp,
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
                              color: Colors.white60,
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
                      color: Colors.white60,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              const Divider(color: Colors.white10, height: 1),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: const Color(0xFF2D9B83),
                          size: 14.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'SOYSOY & EKİP',
                          style: TextStyle(
                            color: const Color(0xFFE6A817),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.only(left: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Baba: ${horse?.sireName ?? "N/A"} · Anne: ${horse?.damName ?? "N/A"}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Antrenör: $trainerName · Sahip: ${horse?.owner ?? "N/A"}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Icon(
                          Icons.history,
                          color: const Color(0xFF2D9B83),
                          size: 14.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'KARİYER GEÇMİŞİ',
                          style: TextStyle(
                            color: const Color(0xFFE6A817),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.only(left: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Koşu: $totalRaces  · Birincilik: $wins  · Dereceler: ${wins + seconds + thirds}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Kazanma Oranı: $winRate% · Tabela Oranı: $placeRate%',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Form Durumu: $wins-$seconds-$thirds-$fourths',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
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

  // ── AI WIN PROBABILITY ANALYSIS TAB (Redesigned Analysis) ───────────────
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
              gradient: const LinearGradient(
                colors: [Color(0xFF132E2E), Color(0xFF0A2626)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFF2D9B83).withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.insights,
                      color: const Color(0xFFE6A817),
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Yapay Zeka Kazanma Olasılıkları',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _buildAnalysisTag(
                      'Pist Eğilimi: $trackType',
                      const Color(0xFF1A4D40),
                      const Color(0xFF5FBFAA),
                    ),
                    _buildAnalysisTag(
                      'Mesafe: $distance',
                      const Color(0xFF1A5276),
                      const Color(0xFF7FBFCF),
                    ),
                    _buildAnalysisTag(
                      'Koşan: $runnersCount at',
                      const Color(0xFF3D2066),
                      const Color(0xFFA070B0),
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

            // Premium rank badges
            Color rankBgColor;
            Color rankTextColor = Colors.white;
            bool isCustomBadge = true;

            if (rank == 1) {
              rankBgColor = const Color(0xFFE6A817); // Gold
              rankTextColor = const Color(0xFF0C1F1F);
            } else if (rank == 2) {
              rankBgColor = const Color(0xFF94A3B8); // Silver
              rankTextColor = const Color(0xFF0C1F1F);
            } else if (rank == 3) {
              rankBgColor = const Color(0xFFCD7F32); // Bronze
            } else {
              rankBgColor = Colors.transparent;
              isCustomBadge = false;
            }

            // Probability-based bar gradients
            List<Color> barColors;
            if (score >= 70) {
              barColors = [
                const Color(0xFF2D9B83),
                const Color(0xFF20C997),
              ]; // Teal to Emerald
            } else if (score >= 50) {
              barColors = [
                const Color(0xFFE6A817),
                const Color(0xFFFFC107),
              ]; // Amber to Yellow
            } else {
              barColors = [
                const Color(0xFFD94E4E),
                const Color(0xFFFF6B6B),
              ]; // Soft Coral
            }

            return _buildAnalysisItem(
              '$rank',
              name,
              score / 100.0,
              rankBgColor,
              rankTextColor,
              isCustomBadge,
              barColors,
            );
          }),
          SizedBox(height: 16.h),
          Text(
            '* Olasılıklar; HP, kazanç, pist uyumu, jokey geçmişi ve ortak koşu geçmişinden hesaplanmıştır.',
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
        color: bgColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: bgColor.withValues(alpha: 0.4)),
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
    Color rankBgColor,
    Color rankTextColor,
    bool isCustomBadge,
    List<Color> barColors,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF132E2E),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 26.w,
                height: 26.w,
                decoration: BoxDecoration(
                  color: rankBgColor,
                  shape: BoxShape.circle,
                  border: isCustomBadge
                      ? null
                      : Border.all(color: Colors.white30),
                ),
                alignment: Alignment.center,
                child: Text(
                  rank,
                  style: TextStyle(
                    color: rankTextColor,
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
                  color: barColors.last,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Custom Gradient Progress Bar
          Stack(
            children: [
              Container(
                height: 6.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 6.h,
                    width: constraints.maxWidth * probability,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: barColors),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── STATISTICS GRID TAB (Redesigned Predictions) ─────────────────────────
  Widget _buildStatisticsTab() {
    final stats = controller.raceStats.value;
    if (controller.isStatsLoading.value && stats == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE6A817)),
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
      childAspectRatio: 1.05,
      children: [
        _buildStatCard(
          'KAZANÇLAR',
          Icons.payments_outlined,
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
          'KÖKEN',
          Icons.public_outlined,
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
          'MESAFE',
          Icons.straighten_outlined,
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
          'PİST',
          Icons.layers_outlined,
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

  Widget _buildStatCard(String title, IconData icon, List<_StatItem> items) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF132E2E),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFE6A817), size: 14.sp),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final item = items[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${(item.value * 100).toInt()}%',
                          style: TextStyle(
                            color: const Color(0xFF2D9B83),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2.r),
                      child: LinearProgressIndicator(
                        value: item.value,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF2D9B83),
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
      barColor = const Color(0xFFE6A817);
    } else if (val < 50) {
      barColor = const Color(0xFFE08080);
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
            score != null ? score.toStringAsFixed(0) : 'N/A',
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
              color: const Color(0xFF0C1F1F),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              border: Border.all(color: Colors.white12),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE6A817)),
              ),
            ),
          );
        }

        final horse = controller.horseDetails.value;
        if (horse == null) {
          return Container(
            height: Get.height * 0.85,
            decoration: BoxDecoration(
              color: const Color(0xFF0C1F1F),
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
            color: const Color(0xFF0C1F1F),
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
                    color: const Color(0xFF0A2626),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: const Color(0xFF132E2E)),
                  ),
                  child: Center(
                    child: Text(
                      'Stats: $winRate% Win | $top3Rate% Top 3 | Last 6: $last6Form',
                      style: TextStyle(
                        color: const Color(0xFFE6A817),
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
                      if (pos == 1) {
                        badgeColor = const Color(0xFF1A4D40);
                      } else if (pos == 2) {
                        badgeColor = const Color(0xFF268060);
                      } else if (pos == 3) {
                        badgeColor = Colors.orange;
                      }

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
        color: const Color(0xFF112828),
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
                    colors: [Color(0xFFE6A817), Color(0xFFCC8800)],
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
                      'PREMIUM ONLY',
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

  void _showPremiumPrompt(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: const Color(0xFF112828),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          border: Border.all(
            color: const Color(0xFFE6A817).withValues(alpha: 0.2),
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
              SizedBox(height: 20.h),
              Icon(
                Icons.workspace_premium_rounded,
                color: const Color(0xFFE6A817),
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
                      colors: [Color(0xFFE6A817), Color(0xFFCC8800)],
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

// ── HORSE ANALYSIS VIEW (atyarisi.com style screen) ─────────────────────────
class HorseAnalysisView extends GetView<RaceDetailsController> {
  const HorseAnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    const mainView = RaceDetailsView();

    return Scaffold(
      backgroundColor: const Color(0xFF0C1F1F),
      body: SafeArea(
        child: Obx(() {
          final details = controller.raceDetails.value;
          final currentRace = controller.race.value;
          final locationName =
              details?.location ?? currentRace?.location ?? 'Ankara';
          final mainTab = controller.selectedMainTab.value;

          return Column(
            children: [
              // Clean Integrated Header
              _buildHeader(context, locationName),

              // Segmented Tab Bar for Main Tabs
              _buildSegmentedTabBar(),

              // Race Selector pills
              _buildRaceSelectorPills(),

              // Selected Race Details Info Banner
              _buildSelectedRaceDetailsInfo(details, currentRace),

              SizedBox(height: 8.h),

              // Sub-Tabs Section depending on active Main Tab (styled as clean pills)
              if (mainTab == 0) _buildSubTabPills(),
              if (mainTab == 1) mainView._buildAtlarInnerSubTabBar(),
              if (mainTab == 2) mainView._buildJokeylerInnerSubTabBar(),

              // Content Area depending on active Main Tab
              Expanded(
                child: _buildAnalysisContentArea(context, details, mainView),
              ),
            ],
          );
        }),
      ),
    );
  }

  // Unified clean header
  Widget _buildHeader(BuildContext context, String locationName) {
    return Container(
      color: const Color(0xFF0A2626),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Detaylı Analiz',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF132E2E),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: const Color(0xFF2D9B83).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  locationName.toUpperCase(),
                  style: TextStyle(
                    color: const Color(0xFFE6A817),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                color: Colors.white60,
                size: 12.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                'Bugün',
                style: TextStyle(color: Colors.white60, fontSize: 12.sp),
              ),
              SizedBox(width: 12.w),
              Icon(
                Icons.thermostat_outlined,
                color: const Color(0xFF2D9B83),
                size: 12.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                'Nem: %39 · Açık',
                style: TextStyle(color: Colors.white60, fontSize: 12.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Segmented Main Tab Bar
  Widget _buildSegmentedTabBar() {
    final currentMainTab = controller.selectedMainTab.value;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2626),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          _buildSegmentItem('Koşu Analizi', 0, currentMainTab == 0),
          _buildSegmentItem('Atlar', 1, currentMainTab == 1),
          _buildSegmentItem('Jokeyler', 2, currentMainTab == 2),
        ],
      ),
    );
  }

  Widget _buildSegmentItem(String label, int index, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedMainTab.value = index,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2D9B83) : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Race Selector pills
  Widget _buildRaceSelectorPills() {
    final races = controller.siblingRaces;
    return Container(
      height: 38.h,
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: races.isEmpty ? 8 : races.length,
        itemBuilder: (context, index) {
          final isSelected = races.isEmpty
              ? (index == 0)
              : (races[index].id == controller.race.value?.id);
          final title = '${index + 1}. Koşu';

          return GestureDetector(
            onTap: () {
              if (races.isNotEmpty) {
                controller.selectSiblingRace(races[index]);
              }
            },
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2D9B83)
                    : const Color(0xFF132E2E),
                borderRadius: BorderRadius.circular(19.r),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white10,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Slim selected race details banner
  Widget _buildSelectedRaceDetailsInfo(
    RaceDetailsData? details,
    RaceModel? currentRace,
  ) {
    final timeVal = details?.time ?? currentRace?.time ?? '13:30';
    final distanceVal = details?.distance ?? currentRace?.distance ?? '1200m';
    final trackType = details?.trackType ?? currentRace?.trackType ?? 'Kum';
    final isTurf =
        trackType.toLowerCase().contains('turf') ||
        trackType.toLowerCase().contains('çim');
    final surfaceStr = isTurf ? 'Çim' : 'Kum';
    final conditionStr = '3 ve Yukarı İngilizler / Handikap-14';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFF132E2E),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.sports_score_outlined,
            color: const Color(0xFFE6A817),
            size: 14.sp,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              '$timeVal · $distanceVal $surfaceStr · $conditionStr',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Scrollable sub-tab pills
  Widget _buildSubTabPills() {
    final subTabs = [
      'Atlar Listesi',
      'Galoplar & Sprintler',
      'En İyi Derece',
      'Son Koşular',
      'Birincilikler',
      'Kim Kiminle Koştu',
      'Kim Kimi Geçti',
    ];
    final currentSubTab = controller.selectedKosuAnaliziSubTab.value;
    return Container(
      height: 34.h,
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: subTabs.length,
        itemBuilder: (context, index) {
          final isSelected = index == currentSubTab;
          return GestureDetector(
            onTap: () => controller.selectedKosuAnaliziSubTab.value = index,
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE6A817).withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isSelected ? const Color(0xFFE6A817) : Colors.white10,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                subTabs[index],
                style: TextStyle(
                  color: isSelected ? const Color(0xFFE6A817) : Colors.white60,
                  fontSize: 11.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnalysisContentArea(
    BuildContext context,
    RaceDetailsData? details,
    RaceDetailsView mainView,
  ) {
    final mainTab = controller.selectedMainTab.value;
    switch (mainTab) {
      case 0:
        return _buildKosuAnaliziContent(context, details, mainView);
      case 1:
        return mainView._buildAtlarContent(context, details);
      case 2:
        return mainView._buildJokeylerContent(context, details);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildKosuAnaliziContent(
    BuildContext context,
    RaceDetailsData? details,
    RaceDetailsView mainView,
  ) {
    final subTab = controller.selectedKosuAnaliziSubTab.value;
    switch (subTab) {
      case 0:
        return mainView._buildOriginalHorseListView(context, details!);
      case 1:
      case 2:
        return mainView._buildEnIyiDereceTab();
      case 3:
        return mainView._buildSonKosularTab();
      case 4:
        return mainView._buildBirinciliklerTab();
      case 5:
        return mainView._buildKimKiminleKostuTab();
      case 6:
        return mainView._buildKimKimiGectiTab();
      default:
        return const SizedBox.shrink();
    }
  }
}
