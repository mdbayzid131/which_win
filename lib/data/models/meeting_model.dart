import 'package:which_win/data/models/race_model.dart';

class MeetingModel {
  final String country;
  final String location;
  final List<RaceModel> races;

  MeetingModel({
    required this.country,
    required this.location,
    required this.races,
  });

  bool get isLive => races.any((r) => r.status?.toUpperCase() == 'LIVE');
  int get racesCount => races.length;
}
