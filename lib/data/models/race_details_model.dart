import 'package:which_win/data/models/race_model.dart';

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
  final String? surface;
  final String? raceType;
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

  factory RaceDetailsData.fromJson(Map<String, dynamic> json) {
    return RaceDetailsData(
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
      riskRate: json['riskRate'] != null ? int.tryParse(json['riskRate'].toString()) : null,
      fieldSize: json['fieldSize'] != null ? int.tryParse(json['fieldSize'].toString()) : null,
      hasPredictions: json['hasPredictions'] as bool?,
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
  final String? trainerName;
  final String? ownerName;
  final double? weight;
  final int? draw;
  final int? number;
  final String? form;
  final String? lastRun;
  final String? comment;
  final String? spotlight;
  final String? silkUrl;
  final String? headgear;
  final double? horsePower;
  final double? jockeyPower;
  final double? sirePower;
  final double? damPower;
  final double? damSirePower;
  final double? pedigreePower;
  final double? earningScore;
  final double? weightScore;
  final double? rawScore;
  final double? normalizedScore;
  final int? rank;
  final String? category;
  final double? winProb;
  final double? winOddsFair;
  final double? placeProb;
  final double? eachWayProb;
  final double? goingSuitabilityScore;
  final double? distanceSuitabilityScore;
  final double? courseSpecialistScore;
  final double? drawBiasScore;
  final double? jockeyFormScore;
  final double? trainerFormScore;
  final int? aiSelectionRank;
  final String? aiConfidence;
  final double? aiConfidenceScore;
  final String? aiAnalysis;
  final bool? hasValueEdge;
  final double? valueEdgePercent;
  final HorseModel? horse;
  final JockeyModel? jockey;

  RaceEntry({
    this.id,
    this.raceId,
    this.horseId,
    this.jockeyId,
    this.jockeyName,
    this.trainerName,
    this.ownerName,
    this.weight,
    this.draw,
    this.number,
    this.form,
    this.lastRun,
    this.comment,
    this.spotlight,
    this.silkUrl,
    this.headgear,
    this.horsePower,
    this.jockeyPower,
    this.sirePower,
    this.damPower,
    this.damSirePower,
    this.pedigreePower,
    this.earningScore,
    this.weightScore,
    this.rawScore,
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
    this.horse,
    this.jockey,
  });

  factory RaceEntry.fromJson(Map<String, dynamic> json) {
    return RaceEntry(
      id: json['id']?.toString(),
      raceId: json['raceId']?.toString(),
      horseId: json['horseId']?.toString(),
      jockeyId: json['jockeyId']?.toString(),
      jockeyName: json['jockeyName']?.toString() ?? (json['jockey'] != null ? json['jockey']['name']?.toString() : null) ?? 'N/A',
      trainerName: json['trainerName']?.toString() ?? (json['trainer'] != null ? json['trainer']['name']?.toString() : null) ?? 'N/A',
      ownerName: json['ownerName']?.toString() ?? 'N/A',
      weight: (json['weight'] as num?)?.toDouble() ?? (json['weightStr'] != null ? double.tryParse(json['weightStr'].toString()) : null),
      draw: json['draw'] != null ? int.tryParse(json['draw'].toString()) : (json['number'] != null ? int.tryParse(json['number'].toString()) : null),
      number: json['number'] != null ? int.tryParse(json['number'].toString()) : null,
      form: json['form']?.toString() ?? 'N/A',
      lastRun: json['lastRun']?.toString() ?? 'N/A',
      comment: json['comment']?.toString(),
      spotlight: json['spotlight']?.toString(),
      silkUrl: json['silkUrl']?.toString(),
      headgear: json['headgear']?.toString(),
      horsePower: (json['horsePower'] as num?)?.toDouble(),
      jockeyPower: (json['jockeyPower'] as num?)?.toDouble(),
      sirePower: (json['sirePower'] as num?)?.toDouble(),
      damPower: (json['damPower'] as num?)?.toDouble(),
      damSirePower: (json['damSirePower'] as num?)?.toDouble(),
      pedigreePower: (json['pedigreePower'] as num?)?.toDouble(),
      earningScore: (json['earningScore'] as num?)?.toDouble(),
      weightScore: (json['weightScore'] as num?)?.toDouble(),
      rawScore: (json['rawScore'] as num?)?.toDouble(),
      normalizedScore: (json['normalizedScore'] as num?)?.toDouble(),
      rank: json['rank'] != null ? int.tryParse(json['rank'].toString()) : null,
      category: json['category']?.toString() ?? 'N/A',
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
      aiSelectionRank: json['aiSelectionRank'] != null ? int.tryParse(json['aiSelectionRank'].toString()) : null,
      aiConfidence: json['aiConfidence']?.toString() ?? 'N/A',
      aiConfidenceScore: (json['aiConfidenceScore'] as num?)?.toDouble(),
      aiAnalysis: json['aiAnalysis']?.toString(),
      hasValueEdge: json['hasValueEdge'] as bool?,
      valueEdgePercent: (json['valueEdgePercent'] as num?)?.toDouble(),
      horse: json['horse'] != null ? HorseModel.fromJson(json['horse']) : null,
      jockey: json['jockey'] != null ? JockeyModel.fromJson(json['jockey']) : null,
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
  final RaceModel? race;

  RaceResult({
    this.id,
    this.position,
    this.time,
    this.earnings,
    this.horse,
    this.jockey,
    this.race,
  });

  factory RaceResult.fromJson(Map<String, dynamic> json) {
    return RaceResult(
      id: json['id']?.toString(),
      position: json['position'] != null ? int.tryParse(json['position'].toString()) : null,
      time: json['time']?.toString() ?? 'N/A',
      earnings: (json['earnings'] as num?)?.toDouble(),
      horse: json['horse'] != null ? HorseModel.fromJson(json['horse']) : null,
      jockey: json['jockey'] != null ? JockeyModel.fromJson(json['jockey']) : null,
      race: json['race'] != null ? RaceModel.fromJson(json['race']) : null,
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
  final String? damSireName;
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
    this.damSireName,
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
      id: json['id']?.toString(),
      externalId: json['externalId']?.toString(),
      name: json['name']?.toString() ?? 'N/A',
      age: json['age'] != null ? int.tryParse(json['age'].toString()) : null,
      color: json['colour']?.toString() ?? json['color']?.toString() ?? 'N/A',
      sex: json['sex']?.toString() ?? 'N/A',
      sireName: json['sireName']?.toString() ?? 'N/A',
      damName: json['damName']?.toString() ?? 'N/A',
      damSireName: json['damSireName']?.toString() ?? 'N/A',
      owner: json['owner']?.toString() ?? json['ownerName']?.toString() ?? 'N/A',
      trainer: json['trainer']?.toString() ?? json['trainerName']?.toString() ?? 'N/A',
      country: json['country']?.toString() ?? 'N/A',
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      bestTime: json['bestTime']?.toString() ?? 'N/A',
      bestTimeLocation: json['bestTimeLocation']?.toString() ?? 'N/A',
      totalRaces: json['totalRaces'] != null ? int.tryParse(json['totalRaces'].toString()) : 0,
      wins: json['wins'] != null ? int.tryParse(json['wins'].toString()) : 0,
      seconds: json['seconds'] != null ? int.tryParse(json['seconds'].toString()) : 0,
      thirds: json['thirds'] != null ? int.tryParse(json['thirds'].toString()) : 0,
      fourths: json['fourths'] != null ? int.tryParse(json['fourths'].toString()) : 0,
      results: json['results'] != null
          ? List<RaceResult>.from(json['results'].map((x) => RaceResult.fromJson(x)))
          : null,
    );
  }
}

class JockeyModel {
  final String? id;
  final String? name;
  final int? totalRides;
  final int? wins;
  final int? seconds;
  final int? thirds;
  final int? fourths;
  final int? ridesLast30d;
  final int? winsLast30d;

  JockeyModel({
    this.id,
    this.name,
    this.totalRides,
    this.wins,
    this.seconds,
    this.thirds,
    this.fourths,
    this.ridesLast30d,
    this.winsLast30d,
  });

  factory JockeyModel.fromJson(Map<String, dynamic> json) {
    return JockeyModel(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? 'N/A',
      totalRides: json['totalRides'] != null ? int.tryParse(json['totalRides'].toString()) : 0,
      wins: json['wins'] != null ? int.tryParse(json['wins'].toString()) : 0,
      seconds: json['seconds'] != null ? int.tryParse(json['seconds'].toString()) : 0,
      thirds: json['thirds'] != null ? int.tryParse(json['thirds'].toString()) : 0,
      fourths: json['fourths'] != null ? int.tryParse(json['fourths'].toString()) : 0,
      ridesLast30d: json['ridesLast30d'] != null ? int.tryParse(json['ridesLast30d'].toString()) : 0,
      winsLast30d: json['winsLast30d'] != null ? int.tryParse(json['winsLast30d'].toString()) : 0,
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
