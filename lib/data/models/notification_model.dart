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
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      isRead: json['isRead'],
      createdAt: json['createdAt'],
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
