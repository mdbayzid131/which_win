import 'package:get/get.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum SnackBarType { success, error, info, warning, secondary }

/// ===================== HELPERS =====================
/// Common utility functions used across the app.
class Helpers {
  /// Parse time string (e.g. "1:53", "13:53", "3:36", "5:51") into minutes from midnight
  static int parseRaceMinutes(String? t) {
    if (t == null || t.isEmpty) return 0;
    final clean = t.trim().replaceAll(RegExp(r'[^\d:]'), '');
    final parts = clean.split(':');
    if (parts.isEmpty) return 0;
    int h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    // In horse racing, afternoon times like 1:53, 2:28, 3:36, 4:11, 5:51 are 13:53, 14:28, etc.
    if (h > 0 && h < 8) h += 12;
    return h * 60 + m;
  }

  /// Sorts a list of RaceModel items chronologically by race time
  static List<dynamic> sortRacesChronologically(List<dynamic> list) {
    final sorted = List<dynamic>.from(list);
    sorted.sort((a, b) {
      final aTime = a.time as String?;
      final bTime = b.time as String?;
      final aMin = parseRaceMinutes(aTime);
      final bMin = parseRaceMinutes(bTime);
      if (aMin != bMin) return aMin.compareTo(bMin);
      final aName = (a.name as String?) ?? '';
      final bName = (b.name as String?) ?? '';
      return aName.compareTo(bName);
    });
    return sorted;
  }

  Helpers._();

  // ──────────────────── TIME FORMATTING ────────────────────

  /// Format seconds to "mm:ss" (e.g., 125 → "02:05")
  static String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  /// Format DateTime to "time ago" string (e.g., "5m ago")
  static String timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays >= 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  /// Format seconds to "HH:mm:ss" (e.g., 3661 → "01:01:01")
  static String formatDuration(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final mins = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$mins:$secs';
  }

  // ──────────────────── CURRENCY FORMATTING ────────────────────

  /// Format number as currency (e.g. 125000 → "$125,000" or "$125,000.00")
  static String formatCurrency(num amount, {String symbol = '\$', int decimals = 0}) {
    final formatted = amount.toStringAsFixed(decimals).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$symbol$formatted';
  }

  // ──────────────────── WEIGHT FORMATTING ────────────────────

  /// Format weight supporting both kg and lbs (e.g. 130 lbs → "59 kg (130 lbs)" or "59 kg")
  static String formatWeight(num? weight, {bool showBoth = false}) {
    if (weight == null || weight <= 0) return 'N/A';
    final double raw = weight.toDouble();
    final double kg = raw > 90 ? (raw / 2.20462) : raw;
    final int lbs = raw > 90 ? raw.round() : (raw * 2.20462).round();

    if (showBoth) {
      return '${kg.toStringAsFixed(0)} kg ($lbs lbs)';
    }
    return '${kg.toStringAsFixed(0)} kg';
  }

  /// Get weight in KG
  static String formatWeightKg(num? weight) {
    return formatWeight(weight, showBoth: false);
  }

  /// Get weight in LBS
  static String formatWeightLbs(num? weight) {
    if (weight == null || weight <= 0) return 'N/A';
    final double raw = weight.toDouble();
    final int lbs = raw > 90 ? raw.round() : (raw * 2.20462).round();
    return '$lbs lbs';
  }

  // ──────────────────── LOGGING ────────────────────
  

  /// General debug log (only in debug mode)
  static void debug(String message) {
    if (!kDebugMode) return;
    debugPrint('');
    debugPrint('🔍🔍🔍 DEBUG: $message');
    debugPrint('');
  }

  /// Info-level log
  static void info(String message) {
    if (!kDebugMode) return;
    debugPrint('');
    debugPrint('ℹ️ℹ️ℹ️ℹ INFO: $message');
    debugPrint('');
  }

  /// Warning-level log
  static void warning(String message) {
    if (!kDebugMode) return;
    debugPrint('');
    debugPrint('⚠️⚠️⚠️ WARNING: $message');
    debugPrint('');
  }

  /// Error-level log
  static void error(String message) {
    if (!kDebugMode) return;
    debugPrint('');
    debugPrint('❌❌❌❌ ERROR: $message');
    debugPrint('');
  }

  // ──────────────────── LOADING DIALOG ────────────────────

  /// Show a centered loading spinner dialog
  static void showLoadingDialog({String? message}) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                SizedBox(height: 16.h),
                Material(
                  color: Colors.transparent,
                  child: Text(
                    message,
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black54,
    );
  }

  /// Dismiss loading dialog if open
  static void hideLoadingDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  // ──────────────────── SNACKBAR (DUAL MODE) ────────────────────

  /// Show a snackbar.
  /// [useGetxSnackbar] = true (default) → uses Get.snackbar with type-specific colors.
  /// [useGetxSnackbar] = false → uses the premium blurred iPhone-style snackbar.
  static void showCustomSnackBar(
    String message, {
    String? title,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    bool useGetxSnackbar = true,
  }) {
    final Map<String, dynamic> config = _getSnackBarConfig(type);

    if (useGetxSnackbar) {
      // ── GetX Snackbar (default) ──────────────────────────────
      Get.snackbar(
        title ?? config['defaultTitle'] as String,
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: (config['bg'] as Color).withValues(alpha: 0.92),
        colorText: Colors.white,
        icon: Icon(
          config['icon'] as IconData,
          color: Colors.white,
          size: 26.sp,
        ),
        duration: duration,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.easeOutCubic,
        reverseAnimationCurve: Curves.easeInCubic,
        animationDuration: const Duration(milliseconds: 450),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        borderRadius: 14.r,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        titleText: Text(
          title ?? config['defaultTitle'] as String,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        messageText: Text(
          message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      );
    } else {
      // ── Custom Blur / Glassmorphism Snackbar ─────────────────
      Get.rawSnackbar(
        messageText: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 64.h,
              decoration: BoxDecoration(
                color: (config['bg'] as Color).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Left Icon Area
                  Container(
                    width: 56.w,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: (config['iconBg'] as Color).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.r),
                        bottomLeft: Radius.circular(16.r),
                      ),
                    ),
                    child: Icon(
                      config['icon'],
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  // Text Content
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title ?? config['defaultTitle'],
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Close Button
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        duration: duration,
        isDismissible: true,
        animationDuration: const Duration(milliseconds: 500),
        snackStyle: SnackStyle.FLOATING,
      );
    }
  }

  static Map<String, dynamic> _getSnackBarConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return {
          'bg': const Color(0xFF10B981),
          'iconBg': const Color(0xFF059669),
          'icon': Icons.check_rounded,
          'defaultTitle': 'Success',
        };
      case SnackBarType.error:
        return {
          'bg': const Color(0xFFEF4444),
          'iconBg': const Color(0xFFDC2626),
          'icon': Icons.block_rounded,
          'defaultTitle': 'Error',
        };
      case SnackBarType.warning:
        return {
          'bg': const Color(0xFFF59E0B),
          'iconBg': const Color(0xFFD97706),
          'icon': Icons.warning_rounded,
          'defaultTitle': 'Warning',
        };
      case SnackBarType.secondary:
        return {
          'bg': const Color(0xFF3B82F6),
          'iconBg': const Color(0xFF2563EB),
          'icon': Icons.notifications_none_rounded,
          'defaultTitle': 'Secondary',
        };
      case SnackBarType.info:
        return {
          'bg': const Color(0xFF9CA3AF),
          'iconBg': const Color(0xFF6B7280),
          'icon': Icons.info_outline_rounded,
          'defaultTitle': 'Info',
        };
    }
  }

  /// Shortcut for Success
  static void showSuccess(String message, {String? title}) {
    showCustomSnackBar(message, title: title, type: SnackBarType.success);
  }

  /// Shortcut for Error
  static void showError(String message, {String? title}) {
    showCustomSnackBar(message, title: title, type: SnackBarType.error);
  }

  /// Shortcut for Warning
  static void showWarning(String message, {String? title}) {
    showCustomSnackBar(message, title: title, type: SnackBarType.warning);
  }

  // ──────────────────── KEYBOARD ────────────────────

  /// Dismiss keyboard
  static void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // ──────────────────── DEBOUNCE ────────────────────

  static final Map<String, bool> _debounceTimers = {};

  /// Debounce a function call (useful for search inputs)
  static void debounce(
    String tag,
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    if (GetUtils.isNull(tag)) return;

    // If already waiting, skip
    if (_debounceTimers[tag] == true) return;

    _debounceTimers[tag] = true;
    Future.delayed(duration, () {
      _debounceTimers.remove(tag);
      callback();
    });
  }
}
