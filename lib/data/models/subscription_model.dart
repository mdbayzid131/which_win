class SubscriptionPlanModel {
  final String? id;
  final String? name;
  final String? description;
  final double? price;
  final String? currency;
  final String? duration;
  final String? productId;

  SubscriptionPlanModel({
    this.id,
    this.name,
    this.description,
    this.price,
    this.currency,
    this.duration,
    this.productId,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'],
      duration: json['duration'],
      productId: json['productId'],
    );
  }
}

class SubscriptionPlansResponse {
  final bool? success;
  final String? message;
  final List<SubscriptionPlanModel>? data;

  SubscriptionPlansResponse({this.success, this.message, this.data});

  factory SubscriptionPlansResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlansResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? List<SubscriptionPlanModel>.from(
              json['data'].map((x) => SubscriptionPlanModel.fromJson(x)))
          : null,
    );
  }
}
