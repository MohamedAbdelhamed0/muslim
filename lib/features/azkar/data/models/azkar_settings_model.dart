import '../../domain/entities/azkar_settings_entity.dart';

class AzkarSettingsModel {
  final int intervalMinutes;
  final int dailyGoal;
  final int completedToday;
  final int totalTapsToday;
  final bool isEnabled;
  final String lastDate;

  AzkarSettingsModel({
    this.intervalMinutes = 30,
    this.dailyGoal = 10,
    this.completedToday = 0,
    this.totalTapsToday = 0,
    this.isEnabled = true,
    this.lastDate = '',
  });

  factory AzkarSettingsModel.fromJson(Map<String, dynamic> json) {
    return AzkarSettingsModel(
      intervalMinutes: json['intervalMinutes'] as int? ?? 30,
      dailyGoal: json['dailyGoal'] as int? ?? 10,
      completedToday: json['completedToday'] as int? ?? 0,
      totalTapsToday: json['totalTapsToday'] as int? ?? 0,
      isEnabled: json['isEnabled'] as bool? ?? true,
      lastDate: json['lastDate'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intervalMinutes': intervalMinutes,
      'dailyGoal': dailyGoal,
      'completedToday': completedToday,
      'totalTapsToday': totalTapsToday,
      'isEnabled': isEnabled,
      'lastDate': lastDate,
    };
  }

  AzkarSettingsEntity toEntity() {
    return AzkarSettingsEntity(
      intervalMinutes: intervalMinutes,
      dailyGoal: dailyGoal,
      completedToday: completedToday,
      totalTapsToday: totalTapsToday,
      isEnabled: isEnabled,
    );
  }

  factory AzkarSettingsModel.fromEntity(AzkarSettingsEntity entity, String dateStr) {
    return AzkarSettingsModel(
      intervalMinutes: entity.intervalMinutes,
      dailyGoal: entity.dailyGoal,
      completedToday: entity.completedToday,
      totalTapsToday: entity.totalTapsToday,
      isEnabled: entity.isEnabled,
      lastDate: dateStr,
    );
  }
}
