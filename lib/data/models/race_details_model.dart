class RaceDetailsResponse {
  final bool? success;
  final String? message;
  final RaceDetailsData? data;

  RaceDetailsResponse({this.success, this.message, this.data});

  factory RaceDetailsResponse.fromJson(Map<String, dynamic> json) {
    return RaceDetailsResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? RaceDetailsData.fromJson(json['data']) : null,
    );
  }
}

class RaceDetailsData {
  final String? id;
  final String? externalId;
  final String? name;
  final String? date;
  final String? time;
  final String? location;
  final String? country;
  final String? trackType;
  final String? surface;        // more reliable than trackType (Turf/Sand)
  final String? raceType;       // Flat/Jump
  final String? distance;
  final String? prize;
  final String? status;
  final String? tahmin1X;
  final String? predictionMessage;
  final int? riskRate;
  final int? fieldSize;
  final bool? hasPredictions;
  final List<RaceEntry>? entries;
  final List<RaceResult>? results;

  RaceDetailsData({
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
    this.fieldSize,
    this.hasPredictions,
    this.entries,
    this.results,
  });

  /// Returns the best available surface label: prefer trackType, fall back to surface.
  String get surfaceLabel => trackType ?? surface ?? 'N/A';

  factory RaceDetailsData.fromJson(Map<String, dynamic> json) {
    return RaceDetailsData(
      id: json['id'],
      externalId: json['externalId'],
      name: json['name'],
      date: json['date'],
      time: json['time'],
      location: json['location'],
      country: json['country'],
      trackType: json['trackType'],
      surface: json['surface'],
      raceType: json['raceType'],
      distance: json['distance'],
      prize: json['prize'],
      status: json['status'],
      tahmin1X: json['tahmin1X'],
      predictionMessage: json['predictionMessage'],
      riskRate: json['riskRate'],
      fieldSize: json['fieldSize'],
      hasPredictions: json['hasPredictions'],
      entries: json['entries'] != null
          ? List<RaceEntry>.from(json['entries'].map((x) => RaceEntry.fromJson(x)))
          : null,
      results: json['results'] != null
          ? List<RaceResult>.from(json['results'].map((x) => RaceResult.fromJson(x)))
          : null,
    );
  }
}

class RaceEntry {
  final String? id;
  final String? raceId;
  final String? horseId;
  final String? jockeyId;
  final String? jockeyName;
  final double? weight;
  final String? weightStr;
  final int? draw;
  final int? number;
  final int? horsePower;
  final int? jockeyPower;
  final double? normalizedScore;
  final int? rank;
  final String? category;
  // Core win probability fields
  final double? winProb;
  final double? winOddsFair;
  final double? placeProb;
  final double? eachWayProb;         // premium
  // Suitability scores
  final double? goingSuitabilityScore;
  final double? distanceSuitabilityScore;
  final double? courseSpecialistScore; // premium
  final double? drawBiasScore;         // premium
  final double? jockeyFormScore;
  final double? trainerFormScore;
  // AI fields
  final int? aiSelectionRank;
  final String? aiConfidence;
  final double? aiConfidenceScore;
  final String? aiAnalysis;
  // Value edge
  final bool? hasValueEdge;            // premium
  final double? valueEdgePercent;      // premium
  // Display helpers
  final String? form;
  final String? colour;
  final String? silkUrl;
  final String? ownerName;
  final String? trainerName;
  final HorseModel? horse;

  RaceEntry({
    this.id,
    this.raceId,
    this.horseId,
    this.jockeyId,
    this.jockeyName,
    this.weight,
    this.weightStr,
    this.draw,
    this.number,
    this.horsePower,
    this.jockeyPower,
    this.normalizedScore,
    this.rank,
    this.category,
    this.winProb,
    this.winOddsFair,
    this.placeProb,
    this.eachWayProb,
    this.goingSuitabilityScore,
    this.distanceSuitabilityScore,
    this.courseSpecialistScore,
    this.drawBiasScore,
    this.jockeyFormScore,
    this.trainerFormScore,
    this.aiSelectionRank,
    this.aiConfidence,
    this.aiConfidenceScore,
    this.aiAnalysis,
    this.hasValueEdge,
    this.valueEdgePercent,
    this.form,
    this.colour,
    this.silkUrl,
    this.ownerName,
    this.trainerName,
    this.horse,
  });

  factory RaceEntry.fromJson(Map<String, dynamic> json) {
    return RaceEntry(
      id: json['id'],
      raceId: json['raceId'],
      horseId: json['horseId'],
      jockeyId: json['jockeyId'],
      jockeyName: json['jockeyName'],
      weight: (json['weight'] as num?)?.toDouble(),
      weightStr: json['weightStr']?.toString(),
      draw: json['draw'],
      number: json['number'],
      horsePower: json['horsePower'],
      jockeyPower: json['jockeyPower'],
      normalizedScore: (json['normalizedScore'] as num?)?.toDouble(),
      rank: json['rank'],
      category: json['category'],
      winProb: (json['winProb'] as num?)?.toDouble(),
      winOddsFair: (json['winOddsFair'] as num?)?.toDouble(),
      placeProb: (json['placeProb'] as num?)?.toDouble(),
      eachWayProb: (json['eachWayProb'] as num?)?.toDouble(),
      goingSuitabilityScore: (json['goingSuitabilityScore'] as num?)?.toDouble(),
      distanceSuitabilityScore: (json['distanceSuitabilityScore'] as num?)?.toDouble(),
      courseSpecialistScore: (json['courseSpecialistScore'] as num?)?.toDouble(),
      drawBiasScore: (json['drawBiasScore'] as num?)?.toDouble(),
      jockeyFormScore: (json['jockeyFormScore'] as num?)?.toDouble(),
      trainerFormScore: (json['trainerFormScore'] as num?)?.toDouble(),
      aiSelectionRank: json['aiSelectionRank'],
      aiConfidence: json['aiConfidence'],
      aiConfidenceScore: (json['aiConfidenceScore'] as num?)?.toDouble(),
      aiAnalysis: json['aiAnalysis'],
      hasValueEdge: json['hasValueEdge'],
      valueEdgePercent: (json['valueEdgePercent'] as num?)?.toDouble(),
      form: json['form'],
      colour: json['colour'],
      silkUrl: json['silkUrl'],
      ownerName: json['ownerName'],
      trainerName: json['trainerName'],
      horse: json['horse'] != null ? HorseModel.fromJson(json['horse']) : null,
    );
  }
}

class RaceResult {
  final String? id;
  final int? position;
  final String? time;
  final double? earnings;
  final HorseModel? horse;
  final JockeyModel? jockey;

  RaceResult({
    this.id,
    this.position,
    this.time,
    this.earnings,
    this.horse,
    this.jockey,
  });

  factory RaceResult.fromJson(Map<String, dynamic> json) {
    return RaceResult(
      id: json['id'],
      position: json['position'],
      time: json['time'],
      earnings: (json['earnings'] as num?)?.toDouble(),
      horse: json['horse'] != null ? HorseModel.fromJson(json['horse']) : null,
      jockey: json['jockey'] != null ? JockeyModel.fromJson(json['jockey']) : null,
    );
  }
}

class HorseModel {
  final String? id;
  final String? externalId;
  final String? name;
  final int? age;
  final String? color;
  final String? sex;
  final String? sireName;
  final String? damName;
  final String? owner;
  final String? trainer;
  final String? country;
  final double? totalEarnings;
  final String? bestTime;
  final String? bestTimeLocation;
  final int? totalRaces;
  final int? wins;
  final int? seconds;
  final int? thirds;
  final int? fourths;
  final List<RaceResult>? results;

  HorseModel({
    this.id,
    this.externalId,
    this.name,
    this.age,
    this.color,
    this.sex,
    this.sireName,
    this.damName,
    this.owner,
    this.trainer,
    this.country,
    this.totalEarnings,
    this.bestTime,
    this.bestTimeLocation,
    this.totalRaces,
    this.wins,
    this.seconds,
    this.thirds,
    this.fourths,
    this.results,
  });

  factory HorseModel.fromJson(Map<String, dynamic> json) {
    return HorseModel(
      id: json['id'],
      externalId: json['externalId'],
      name: json['name'],
      age: json['age'],
      color: json['color'],
      sex: json['sex'],
      sireName: json['sireName'],
      damName: json['damName'],
      owner: json['owner'],
      trainer: json['trainer'],
      country: json['country'],
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble(),
      bestTime: json['bestTime'],
      bestTimeLocation: json['bestTimeLocation'],
      totalRaces: json['totalRaces'],
      wins: json['wins'],
      seconds: json['seconds'],
      thirds: json['thirds'],
      fourths: json['fourths'],
      results: json['results'] != null
          ? List<RaceResult>.from(json['results'].map((x) => RaceResult.fromJson(x)))
          : null,
    );
  }
}

class JockeyModel {
  final String? id;
  final String? name;

  JockeyModel({this.id, this.name});

  factory JockeyModel.fromJson(Map<String, dynamic> json) {
    return JockeyModel(
      id: json['id'],
      name: json['name'],
    );
  }
}

class HorseDetailsResponse {
  final bool? success;
  final String? message;
  final HorseModel? data;

  HorseDetailsResponse({this.success, this.message, this.data});

  factory HorseDetailsResponse.fromJson(Map<String, dynamic> json) {
    return HorseDetailsResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? HorseModel.fromJson(json['data']) : null,
    );
  }
}
