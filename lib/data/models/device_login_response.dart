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
      id: json['id']?.toString(),
      deviceId: json['deviceId']?.toString(),
      role: json['role']?.toString(),
      language: json['language']?.toString(),
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
  final String? startDate;
  final String? endDate;

  SubscriptionDevice({
    this.id,
    this.plan,
    this.isActive,
    this.startDate,
    this.endDate,
  });

  factory SubscriptionDevice.fromJson(Map<String, dynamic> json) {
    return SubscriptionDevice(
      id: json['id']?.toString(),
      plan: json['plan']?.toString(),
      isActive: json['isActive'] as bool?,
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
    );
  }
}
