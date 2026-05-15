import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
        title: Row(
          children: [
            Text(
              'Race 2',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8.w),
            _buildHeaderTag('Condition', const Color(0xFF1E293B)),
            SizedBox(width: 4.w),
            _buildHeaderTag(
              'Sand',
              const Color(0xFF003D33),
              textColor: const Color(0xFF4DB6AC),
            ),
            SizedBox(width: 8.w),
            Text(
              '1600m · 14:20',
              style: TextStyle(color: Colors.white38, fontSize: 12.sp),
            ),
          ],
        ),
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
              if (controller.selectedTab.value == 0) {
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final horseNames = [
                      'AKSI SEDA',
                      'VENOM',
                      'GOLDEN ARROW',
                      'NIGHT STORM',
                      'SWIFT SULTAN',
                    ];
                    final scores = [95, 88, 76, 71, 65];
                    final colors = [
                      const Color(0xFF2E7D32),
                      const Color(0xFF2E7D32),
                      Colors.orange,
                      Colors.orange,
                      Colors.orange,
                    ];

                    return _buildHorseCard(
                      index,
                      horseNames[index],
                      scores[index],
                      colors[index],
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
                      'Track Bias: Turf',
                      const Color(0xFF1B5E20),
                      const Color(0xFF81C784),
                    ),
                    SizedBox(width: 8.w),
                    _buildAnalysisTag(
                      'Dist: 1200m',
                      const Color(0xFF0D47A1),
                      const Color(0xFF64B5F6),
                    ),
                    SizedBox(width: 8.w),
                    _buildAnalysisTag(
                      'Field: 6 runners',
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
          _buildAnalysisItem(
            '1',
            'AKSI SEDA',
            0.82,
            const Color(0xFFE53935),
            const Color(0xFF4DB6AC),
          ),
          _buildAnalysisItem(
            '2',
            'VENOM',
            0.71,
            const Color(0xFF1E88E5),
            const Color(0xFF4DB6AC),
          ),
          _buildAnalysisItem(
            '3',
            'GOLDEN ARROW',
            0.58,
            const Color(0xFF43A047),
            const Color(0xFFFFB74D),
          ),
          _buildAnalysisItem(
            '4',
            'NIGHT STORM',
            0.44,
            const Color(0xFF8E24AA),
            const Color(0xFFE57373),
          ),
          _buildAnalysisItem(
            '5',
            'SWIFT SULTAN',
            0.35,
            const Color(0xFFFB8C00),
            const Color(0xFFE57373),
          ),
          _buildAnalysisItem(
            '6',
            'CRIMSON TIDE',
            0.24,
            const Color(0xFF00897B),
            const Color(0xFFE57373),
          ),

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
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(16.w),
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 1.1,
      children: [
        _buildStatCard('EARNINGS', [
          _StatItem('₺500K', 0.9),
          _StatItem('₺420K', 0.7),
          _StatItem('₺285K', 0.5),
        ]),
        _buildStatCard('ORIGIN', [
          _StatItem('Turkey 60%', 0.6),
          _StatItem('UK 20%', 0.2),
          _StatItem('IE 20%', 0.2),
        ]),
        _buildStatCard('DISTANCE', [
          _StatItem('1200m: W3', 0.8),
          _StatItem('1600m: W2', 0.5),
          _StatItem('2000m: W1', 0.3),
        ]),
        _buildStatCard('TRACK', [
          _StatItem('Turf: W4 L2', 0.7),
          _StatItem('Sand: W1 L3', 0.4),
        ]),
        _buildStatCard('CITY', [
          _StatItem('Istanbul 58%', 0.58),
          _StatItem('Ankara 30%', 0.3),
        ]),
        _buildStatCard('JOCKEY', [
          _StatItem('A.Can: 68%', 0.68),
          _StatItem('M.Kaya: 45%', 0.45),
        ]),
        _buildStatCard('CO-RACES', [
          _StatItem('VENOM 3-2', 0.6),
          _StatItem('GOLDEN ARROW 3-1', 0.4),
        ]),
        _buildStatCard('BEST TIME', [
          _StatItem('AKSI SEDA 1:12.45', 0.7),
          _StatItem('VENOM 1:13.10', 0.5),
        ]),
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

  Widget _buildHorseCard(int index, String name, int score, Color scoreColor) {
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
                            name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '5yo • Chestnut | Jockey: AHMET CAN | 50kg',
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
                          '₺500,000',
                          style: TextStyle(
                            color: const Color(0xFF4DB6AC),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '323211',
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
                            'Sire: AMERICAN PHAROAH',
                            'Dam: THUNDER ROSE',
                          ]),
                        ),
                        Expanded(
                          child: _buildDetailSection('TEAM', [
                            'Owner: Star Stables',
                            'Trainer: Mike Johnson',
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
                                TextSpan(text: 'Best: 1:13.55 Kentucky'),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showHorseDetails(name),
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
