class MeetingModel {
  final String country;
  final String location;
  final int racesCount;
  final bool isLive;

  MeetingModel({
    required this.country,
    required this.location,
    required this.racesCount,
    required this.isLive,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      country: json['country']?.toString() ?? 'N/A',
      location: json['location']?.toString() ?? 'N/A',
      racesCount: (json['racesCount'] as num?)?.toInt() ?? (int.tryParse(json['racesCount']?.toString() ?? '') ?? 0),
      isLive: json['isLive'] as bool? ?? false,
    );
  }
}
