import 'package:flutter/foundation.dart';

@immutable
class AzkarSettingsEntity {
  final int intervalMinutes;
  final int dailyGoal;
  final int completedToday;
  final int totalTapsToday;
  final bool isEnabled;

  const AzkarSettingsEntity({
    this.intervalMinutes = 30,
    this.dailyGoal = 10,
    this.completedToday = 0,
    this.totalTapsToday = 0,
    this.isEnabled = true,
  });

  AzkarSettingsEntity copyWith({
    int? intervalMinutes,
    int? dailyGoal,
    int? completedToday,
    int? totalTapsToday,
    bool? isEnabled,
  }) {
    return AzkarSettingsEntity(
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      completedToday: completedToday ?? this.completedToday,
      totalTapsToday: totalTapsToday ?? this.totalTapsToday,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
