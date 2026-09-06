import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:which_win/data/models/race_details_model.dart';
import '../controllers/race_details_controller.dart';
import 'widgets/race_details_app_bar.dart';
import 'widgets/race_details_sub_tab_bar.dart';
import 'widgets/race_selector_bar.dart';
import 'widgets/tabs/analysis_tab_content.dart';
import 'widgets/tabs/prediction_tab_content.dart';
import 'widgets/tabs/atlar_jokeyler_tab_content.dart';
import 'widgets/tabs/bulletin_tab_content.dart';
import 'widgets/tabs/kosu_analizi_tab_content.dart';

class RaceDetailsView extends GetView<RaceDetailsController> {
  const RaceDetailsView({super.key});

  String _getDayFromDate(String dateIso) {
    try {
      final parsed = DateTime.parse(dateIso);
      return '${parsed.day}';
    } catch (_) {
      return '23';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121418),
      body: SafeArea(
        child: Obx(() {
          final details = controller.raceDetails.value;
          final currentRace = controller.race.value;
          final locationName =
              details?.location ?? currentRace?.location ?? '';
          final dateVal =
              currentRace?.date ?? DateTime.now().toIso8601String();
          final dayStr = _getDayFromDate(dateVal);

          if (controller.isLoading.value && details == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
            );
          }

          return Column(
            children: [
              // ── Custom Header / App Bar ─────────────────────────────────
              RaceDetailsAppBar(
                locationName: locationName,
                dayStr: dayStr,
              ),

              // ── Horizontal Race Selector Bar ────────────────────────────
              const RaceSelectorBar(),

              // ── Selected Race Details Banner ────────────────────────────
              SelectedRaceDetailsBanner(
                details: details,
                currentRace: currentRace,
              ),

              // ── Sub-Tab Bar (STATISTICS / ANALYSIS / PREDICTION / RESULT) ──
              const RaceDetailsSubTabBar(),

              // ── Tab Content Area ────────────────────────────────────────
              Expanded(child: _buildTabContent(context, details)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, RaceDetailsData? details) {
    if (details == null) {
      return Center(
        child: Text(
          'failed_load_details'.tr,
          style: const TextStyle(color: Colors.white60),
        ),
      );
    }

    switch (controller.selectedTab.value) {
      case 0:
        return _buildStatisticsMainView(context, details);
      case 1:
        return const AnalysisTabContent();
      case 2:
        return const PredictionTabContent();
      case 3:
        return BulletinTabContent(details: details);
      default:
        return Center(
          child: Text('coming_soon'.tr, style: const TextStyle(color: Colors.white60)),
        );
    }
  }

  Widget _buildStatisticsMainView(
    BuildContext context,
    RaceDetailsData details,
  ) {
    return Column(
      children: [
        const InnerMainTabBar(),
        Obx(() {
          final mainTab = controller.selectedMainTab.value;
          switch (mainTab) {
            case 0:
              return const KosuAnaliziInnerSubTabBar();
            case 1:
              return const AtlarInnerSubTabBar();
            case 2:
              return const JokeylerInnerSubTabBar();
            default:
              return const SizedBox.shrink();
          }
        }),
        Expanded(
          child: Obx(() {
            final mainTab = controller.selectedMainTab.value;
            switch (mainTab) {
              case 0:
                return KosuAnaliziTabContent(details: details);
              case 1:
                return AtlarContent(details: details);
              case 2:
                return JokeylerContent(details: details);
              default:
                return const SizedBox.shrink();
            }
          }),
        ),
      ],
    );
  }
}
