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
      id: json['id']?.toString() ?? json['_id']?.toString(),
      name: json['name']?.toString() ?? json['title']?.toString() ?? 'N/A',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ??
          (json['amount'] as num?)?.toDouble() ??
          0.0,
      currency: json['currency']?.toString() ?? 'USD',
      duration: json['duration']?.toString() ?? json['interval']?.toString() ?? 'N/A',
      productId: json['productId']?.toString() ??
          json['product_id']?.toString() ??
          json['id']?.toString() ??
          'N/A',
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
