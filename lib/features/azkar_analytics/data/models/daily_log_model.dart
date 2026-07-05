import '../../domain/entities/daily_log_entity.dart';

class DailyLogModel {
  final String dateStr;
  final int taps;
  final int completedSessions;

  DailyLogModel({
    required this.dateStr,
    required this.taps,
    required this.completedSessions,
  });

  factory DailyLogModel.fromJson(Map<String, dynamic> json) {
    return DailyLogModel(
      dateStr: json['dateStr'] as String,
      taps: json['taps'] as int? ?? 0,
      completedSessions: json['completedSessions'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateStr': dateStr,
      'taps': taps,
      'completedSessions': completedSessions,
    };
  }

  DailyLogEntity toEntity() {
    return DailyLogEntity(
      dateStr: dateStr,
      taps: taps,
      completedSessions: completedSessions,
    );
  }
}
