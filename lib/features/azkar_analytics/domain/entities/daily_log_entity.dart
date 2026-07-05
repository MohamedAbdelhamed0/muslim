import 'package:flutter/foundation.dart';

@immutable
class DailyLogEntity {
  final String dateStr;
  final int taps;
  final int completedSessions;

  const DailyLogEntity({
    required this.dateStr,
    required this.taps,
    required this.completedSessions,
  });
}
