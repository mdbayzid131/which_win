class RaceModel {
  final String? id;
  final String? externalId;
  final String? name;
  final String? date;
  final String? time;
  final String? location;
  final String? country;
  final String? trackType;
  final String? distance;
  final String? prize;
  final String? status;
  final String? tahmin1X;
  final String? predictionMessage;
  final int? riskRate;
  final int? entriesCount;

  RaceModel({
    this.id,
    this.externalId,
    this.name,
    this.date,
    this.time,
    this.location,
    this.country,
    this.trackType,
    this.distance,
    this.prize,
    this.status,
    this.tahmin1X,
    this.predictionMessage,
    this.riskRate,
    this.entriesCount,
  });

  factory RaceModel.fromJson(Map<String, dynamic> json) {
    return RaceModel(
      id: json['id'],
      externalId: json['externalId'],
      name: json['name'],
      date: json['date'],
      time: json['time'],
      location: json['location'],
      country: json['country'],
      trackType: json['trackType'],
      distance: json['distance'],
      prize: json['prize'],
      status: json['status'],
      tahmin1X: json['tahmin1X'],
      predictionMessage: json['predictionMessage'],
      riskRate: json['riskRate'],
      entriesCount: json['_count']?['entries'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'externalId': externalId,
      'name': name,
      'date': date,
      'time': time,
      'location': location,
      'country': country,
      'trackType': trackType,
      'distance': distance,
      'prize': prize,
      'status': status,
      'tahmin1X': tahmin1X,
      'predictionMessage': predictionMessage,
      'riskRate': riskRate,
      '_count': {'entries': entriesCount},
    };
  }
}

class RaceMeta {
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPage;

  RaceMeta({this.page, this.limit, this.total, this.totalPage});

  factory RaceMeta.fromJson(Map<String, dynamic> json) {
    return RaceMeta(
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      totalPage: json['totalPage'],
    );
  }
}

class RacesResponse {
  final bool? success;
  final String? message;
  final RaceMeta? meta;
  final List<RaceModel>? data;

  RacesResponse({this.success, this.message, this.meta, this.data});

  factory RacesResponse.fromJson(Map<String, dynamic> json) {
    return RacesResponse(
      success: json['success'],
      message: json['message'],
      meta: json['meta'] != null ? RaceMeta.fromJson(json['meta']) : null,
      data: json['data'] != null
          ? List<RaceModel>.from(json['data'].map((x) => RaceModel.fromJson(x)))
          : null,
    );
  }
}

class RaceDatesResponse {
  final bool? success;
  final String? message;
  final List<String>? data;

  RaceDatesResponse({this.success, this.message, this.data});

  factory RaceDatesResponse.fromJson(Map<String, dynamic> json) {
    return RaceDatesResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? List<String>.from(json['data']) : null,
    );
  }
}
