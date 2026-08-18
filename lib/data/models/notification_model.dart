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
