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
      country: json['country'] ?? 'Unknown',
      location: json['location'] ?? 'Unknown',
      racesCount: json['racesCount'] ?? 0,
      isLive: json['isLive'] ?? false,
    );
  }
}
