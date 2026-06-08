class DeviceLoginResponse {
  final bool? success;
  final String? message;
  final DeviceLoginData? data;

  DeviceLoginResponse({this.success, this.message, this.data});

  factory DeviceLoginResponse.fromJson(Map<String, dynamic> json) {
    return DeviceLoginResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? DeviceLoginData.fromJson(json['data']) : null,
    );
  }
}

class DeviceLoginData {
  final String? token;
  final UserDevice? user;

  DeviceLoginData({this.token, this.user});

  factory DeviceLoginData.fromJson(Map<String, dynamic> json) {
    return DeviceLoginData(
      token: json['token'],
      user: json['user'] != null ? UserDevice.fromJson(json['user']) : null,
    );
  }
}

class UserDevice {
  final String? id;
  final String? deviceId;
  final String? role;
  final String? language;
  final SubscriptionDevice? subscription;

  UserDevice({
    this.id,
    this.deviceId,
    this.role,
    this.language,
    this.subscription,
  });

  factory UserDevice.fromJson(Map<String, dynamic> json) {
    return UserDevice(
      id: json['id'],
      deviceId: json['deviceId'],
      role: json['role'],
      language: json['language'],
      subscription: json['subscription'] != null
          ? SubscriptionDevice.fromJson(json['subscription'])
          : null,
    );
  }
}

class SubscriptionDevice {
  final String? id;
  final String? plan;
  final bool? isActive;
  final String? endDate;

  SubscriptionDevice({this.id, this.plan, this.isActive, this.endDate});

  factory SubscriptionDevice.fromJson(Map<String, dynamic> json) {
    return SubscriptionDevice(
      id: json['id'],
      plan: json['plan'],
      isActive: json['isActive'],
      endDate: json['endDate'],
    );
  }
}
