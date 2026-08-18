class RaceModel {
  final String? id;
  final String? externalId;
  final String? name;
  final String? date;
  final String? time;
  final String? location;
  final String? country;
  final String? trackType;
  final String? surface;
  final String? raceType;
  final String? distance;
  final String? prize;
  final String? status;
  final String? tahmin1X;
  final String? predictionMessage;
  final int? riskRate;
  final int? entriesCount;
  final int? fieldSize;
  final bool? hasPredictions;

  RaceModel({
    this.id,
    this.externalId,
    this.name,
    this.date,
    this.time,
    this.location,
    this.country,
    this.trackType,
    this.surface,
    this.raceType,
    this.distance,
    this.prize,
    this.status,
    this.tahmin1X,
    this.predictionMessage,
    this.riskRate,
    this.entriesCount,
    this.fieldSize,
    this.hasPredictions,
  });

  factory RaceModel.fromJson(Map<String, dynamic> json) {
    return RaceModel(
      id: json['id']?.toString(),
      externalId: json['externalId']?.toString(),
      name: json['name']?.toString() ?? 'N/A',
      date: json['date']?.toString(),
      time: json['time']?.toString() ?? 'N/A',
      location: json['location']?.toString() ?? 'N/A',
      country: json['country']?.toString() ?? 'N/A',
      trackType: json['trackType']?.toString() ?? json['surface']?.toString() ?? 'N/A',
      surface: json['surface']?.toString() ?? json['trackType']?.toString() ?? 'N/A',
      raceType: json['raceType']?.toString() ?? 'N/A',
      distance: json['distance']?.toString() ?? 'N/A',
      prize: json['prize']?.toString() ?? 'N/A',
      status: json['status']?.toString() ?? 'N/A',
      tahmin1X: json['tahmin1X']?.toString() ?? 'N/A',
      predictionMessage: json['predictionMessage']?.toString(),
      riskRate: json['riskRate'] != null
          ? int.tryParse(json['riskRate'].toString())
          : null,
      entriesCount: json['entriesCount'] != null
          ? int.tryParse(json['entriesCount'].toString())
          : (json['_count'] != null && json['_count']['entries'] != null
              ? int.tryParse(json['_count']['entries'].toString())
              : (json['fieldSize'] != null
                  ? int.tryParse(json['fieldSize'].toString())
                  : null)),
      fieldSize: json['fieldSize'] != null
          ? int.tryParse(json['fieldSize'].toString())
          : (json['_count'] != null && json['_count']['entries'] != null
              ? int.tryParse(json['_count']['entries'].toString())
              : null),
      hasPredictions: json['hasPredictions'] as bool?,
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
      'surface': surface,
      'raceType': raceType,
      'distance': distance,
      'prize': prize,
      'status': status,
      'tahmin1X': tahmin1X,
      'predictionMessage': predictionMessage,
      'riskRate': riskRate,
      '_count': {'entries': entriesCount},
      'fieldSize': fieldSize,
      'hasPredictions': hasPredictions,
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
