import 'package:get/get.dart';

class NotificationModel {
  final String? id;
  final String? title;
  final String? message;
  final String? type;
  final bool? isRead;
  final String? createdAt;

  NotificationModel({
    this.id,
    this.title,
    this.message,
    this.type,
    this.isRead,
    this.createdAt,
  });

  String get displayTitle {
    final lang = Get.locale?.languageCode ?? 'en';
    if (lang.toLowerCase().startsWith('tr')) {
      if (title != null) {
        if (title!.contains('Welcome') || title!.contains('Free Trial')) {
          return '🎉 Hoş Geldiniz! 7 Günlük Ücretsiz Denemeniz Başladı';
        }
        if (title!.toLowerCase().contains('activated')) {
          return 'Abonelik Aktif Edildi';
        }
        if (title!.toLowerCase().contains('expiring')) {
          return 'Aboneliğiniz Yakında Sona Eriyor';
        }
        if (title!.toLowerCase().contains('expired')) {
          return 'Abonelik Süresi Doldu';
        }
        if (title!.toLowerCase().contains('race starting')) {
          return 'Yarış Başlıyor';
        }
        if (title!.toLowerCase().contains('race finished')) {
          return 'Yarış Tamamlandı';
        }
        if (title!.toLowerCase().contains('predictions ready')) {
          return 'Tahminler Hazır';
        }
      }
    } else {
      if (title != null) {
        if (title!.contains('Hoş Geldiniz') || title!.contains('Ücretsiz Deneme')) {
          return '🎉 Welcome! Your 7-Day Free Trial Has Started';
        }
        if (title!.contains('Aktif Edildi')) {
          return 'Subscription Activated';
        }
        if (title!.contains('Sona Eriyor')) {
          return 'Subscription Expiring Soon';
        }
        if (title!.contains('Süresi Doldu')) {
          return 'Subscription Expired';
        }
        if (title!.contains('Yarış Başlıyor')) {
          return 'Race Starting Soon';
        }
        if (title!.contains('Yarış Tamamlandı')) {
          return 'Race Finished';
        }
        if (title!.contains('Tahminler Hazır')) {
          return 'Predictions Ready';
        }
      }
    }
    return title ?? 'N/A';
  }

  String get displayMessage {
    final lang = Get.locale?.languageCode ?? 'en';
    if (lang.toLowerCase().startsWith('tr')) {
      if (message != null) {
        if (message!.contains('Welcome') || message!.contains('free trial') || message!.contains('free until')) {
          final dateMatch = RegExp(r'\d{1,2}/\d{1,2}/\d{4}').firstMatch(message!);
          final dateStr = dateMatch != null ? dateMatch.group(0) : 'deneme süreniz boyunca';
          return '$dateStr tarihine kadar tüm premium yapay zeka tahminlerine ücretsiz erişiminiz var. Deneme süreniz sona erdikten sonra devam etmek için abone olun!';
        }
      }
    } else {
      if (message != null) {
        if (message!.contains('ücretsiz erişiminiz var') || message!.contains('Hoş Geldiniz')) {
          final dateMatch = RegExp(r'\d{1,2}/\d{1,2}/\d{4}').firstMatch(message!);
          final dateStr = dateMatch != null ? dateMatch.group(0) : 'your trial period';
          return 'You now have full access to all premium AI predictions for free until $dateStr. Enjoy the full experience — subscribe to continue after your trial ends!';
        }
      }
    }
    return message ?? 'N/A';
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString(),
      title: json['title']?.toString() ?? 'N/A',
      message: json['message']?.toString() ?? 'N/A',
      type: json['type']?.toString(),
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class NotificationsResponse {
  final bool? success;
  final String? message;
  final List<NotificationModel>? data;

  NotificationsResponse({this.success, this.message, this.data});

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? List<NotificationModel>.from(
              json['data'].map((x) => NotificationModel.fromJson(x)))
          : null,
    );
  }
}
