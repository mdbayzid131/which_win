class RaceStatisticsResponse {
  final bool? success;
  final String? message;
  final RaceStatsData? data;

  RaceStatisticsResponse({this.success, this.message, this.data});

  factory RaceStatisticsResponse.fromJson(Map<String, dynamic> json) {
    return RaceStatisticsResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? RaceStatsData.fromJson(json['data']) : null,
    );
  }
}

class RaceStatsData {
  final List<EarningStat>? earnings;
  final List<OriginStat>? origin;
  final List<DistanceStat>? distance;
  final List<TrackStat>? track;
  final List<CityStat>? city;
  final List<JockeyStat>? jockey;
  final List<CoRaceStat>? coRaces;
  final List<BestTimeStat>? bestTime;

  RaceStatsData({
    this.earnings,
    this.origin,
    this.distance,
    this.track,
    this.city,
    this.jockey,
    this.coRaces,
    this.bestTime,
  });

  factory RaceStatsData.fromJson(Map<String, dynamic> json) {
    return RaceStatsData(
      earnings: json['earnings'] != null
          ? List<EarningStat>.from(json['earnings'].map((x) => EarningStat.fromJson(x)))
          : null,
      origin: json['origin'] != null
          ? List<OriginStat>.from(json['origin'].map((x) => OriginStat.fromJson(x)))
          : null,
      distance: json['distance'] != null
          ? List<DistanceStat>.from(json['distance'].map((x) => DistanceStat.fromJson(x)))
          : null,
      track: json['track'] != null
          ? List<TrackStat>.from(json['track'].map((x) => TrackStat.fromJson(x)))
          : null,
      city: json['city'] != null
          ? List<CityStat>.from(json['city'].map((x) => CityStat.fromJson(x)))
          : null,
      jockey: json['jockey'] != null
          ? List<JockeyStat>.from(json['jockey'].map((x) => JockeyStat.fromJson(x)))
          : null,
      coRaces: json['coRaces'] != null
          ? List<CoRaceStat>.from(json['coRaces'].map((x) => CoRaceStat.fromJson(x)))
          : null,
      bestTime: json['bestTime'] != null
          ? List<BestTimeStat>.from(json['bestTime'].map((x) => BestTimeStat.fromJson(x)))
          : null,
    );
  }
}

class EarningStat {
  final String? horseName;
  final String? amount;
  final int? percentage;

  EarningStat({this.horseName, this.amount, this.percentage});

  factory EarningStat.fromJson(Map<String, dynamic> json) {
    return EarningStat(
      horseName: json['horseName'],
      amount: json['amount'],
      percentage: json['percentage'],
    );
  }
}

class OriginStat {
  final String? country;
  final int? percentage;

  OriginStat({this.country, this.percentage});

  factory OriginStat.fromJson(Map<String, dynamic> json) {
    return OriginStat(
      country: json['country'],
      percentage: json['percentage'],
    );
  }
}

class DistanceStat {
  final String? label;
  final String? detail;
  final int? percentage;

  DistanceStat({this.label, this.detail, this.percentage});

  factory DistanceStat.fromJson(Map<String, dynamic> json) {
    return DistanceStat(
      label: json['label'],
      detail: json['detail'],
      percentage: json['percentage'],
    );
  }
}

class TrackStat {
  final String? surface;
  final String? detail;
  final int? percentage;

  TrackStat({this.surface, this.detail, this.percentage});

  factory TrackStat.fromJson(Map<String, dynamic> json) {
    return TrackStat(
      surface: json['surface'],
      detail: json['detail'],
      percentage: json['percentage'],
    );
  }
}

class CityStat {
  final String? name;
  final int? percentage;

  CityStat({this.name, this.percentage});

  factory CityStat.fromJson(Map<String, dynamic> json) {
    return CityStat(
      name: json['name'],
      percentage: json['percentage'],
    );
  }
}

class JockeyStat {
  final String? name;
  final int? percentage;

  JockeyStat({this.name, this.percentage});

  factory JockeyStat.fromJson(Map<String, dynamic> json) {
    return JockeyStat(
      name: json['name'],
      percentage: json['percentage'],
    );
  }
}

class CoRaceStat {
  final String? horseName;
  final String? score;
  final int? percentage;

  CoRaceStat({this.horseName, this.score, this.percentage});

  factory CoRaceStat.fromJson(Map<String, dynamic> json) {
    return CoRaceStat(
      horseName: json['horseName'],
      score: json['score'],
      percentage: json['percentage'],
    );
  }
}

class BestTimeStat {
  final String? horseName;
  final String? time;
  final int? percentage;

  BestTimeStat({this.horseName, this.time, this.percentage});

  factory BestTimeStat.fromJson(Map<String, dynamic> json) {
    return BestTimeStat(
      horseName: json['horseName'],
      time: json['time'],
      percentage: json['percentage'],
    );
  }
}
