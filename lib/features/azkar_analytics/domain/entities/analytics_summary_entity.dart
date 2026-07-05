import 'package:flutter/foundation.dart';
import 'daily_log_entity.dart';

@immutable
class AnalyticsSummaryEntity {
  final int totalTapsAllTime;
  final int totalSessionsAllTime;
  final int currentStreakDays;
  final String topZikrName;
  final List<DailyLogEntity> logs;

  const AnalyticsSummaryEntity({
    required this.totalTapsAllTime,
    required this.totalSessionsAllTime,
    required this.currentStreakDays,
    required this.topZikrName,
    required this.logs,
  });
}
