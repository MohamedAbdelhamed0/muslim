import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/azkar_settings_model.dart';
import '../models/zikr_model.dart';

abstract class AzkarLocalDataSource {
  Future<void> init();
  Future<List<ZikrModel>> getAzkar();
  Future<void> saveZikr(ZikrModel zikr);
  Future<void> deleteZikr(String id);
  Future<AzkarSettingsModel> getSettings();
  Future<void> saveSettings(AzkarSettingsModel settings);
  Future<void> incrementCompletedCount();
  Future<void> recordZikrTap(String zikrId, int addedTaps);
  Future<Map<String, dynamic>> getDailyLogMap();
}

class AzkarLocalDataSourceImpl implements AzkarLocalDataSource {
  static const String _azkarBoxName = 'azkar_box';
  static const String _settingsBoxName = 'azkar_settings_box';
  static const String _logsBoxName = 'azkar_real_daily_logs_box';

  Box? _azkarBox;
  Box? _settingsBox;
  Box? _logsBox;

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    _azkarBox = await Hive.openBox(_azkarBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
    _logsBox = await Hive.openBox(_logsBoxName);

    // Seed defaults if empty
    if (_azkarBox!.isEmpty) {
      await _seedDefaultAzkar();
    }
  }

  Future<void> _seedDefaultAzkar() async {
    final defaultAzkar = [
      ZikrModel(
        id: 'default_1',
        textAr: 'سبحان الله وبحمده ، سبحان الله العظيم',
        textEn: 'Glory be to Allah and praise Him, Glory be to Allah the Supreme',
        defaultTargetCount: 3,
        category: 'Tasbeeh',
      ),
      ZikrModel(
        id: 'default_2',
        textAr: 'أستغفر الله وأتوب إليه',
        textEn: 'I seek forgiveness from Allah and repent to Him',
        defaultTargetCount: 3,
        category: 'Istighfar',
      ),
      ZikrModel(
        id: 'default_3',
        textAr: 'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير',
        textEn: 'There is no god but Allah alone, with no partner',
        defaultTargetCount: 1,
        category: 'Tawheed',
      ),
      ZikrModel(
        id: 'default_4',
        textAr: 'اللهم صلِّ وسلم على نبينا محمد',
        textEn: 'O Allah, send blessings and peace upon our Prophet Muhammad',
        defaultTargetCount: 10,
        category: 'Salawat',
      ),
      ZikrModel(
        id: 'default_5',
        textAr: 'لا حول ولا قوة إلا بالله العلي العظيم',
        textEn: 'There is no power nor strength except through Allah',
        defaultTargetCount: 3,
        category: 'Hawqala',
      ),
      ZikrModel(
        id: 'default_6',
        textAr: 'سُبْحَانَ اللهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا اللهُ، وَاللهُ أَكْبَرُ',
        textEn: 'Glory be to Allah, praise be to Allah, there is no god but Allah, and Allah is most great',
        defaultTargetCount: 4,
        category: 'Baqiyat',
      ),
    ];

    for (final zikr in defaultAzkar) {
      await _azkarBox!.put(zikr.id, zikr.toJson());
    }
  }

  @override
  Future<List<ZikrModel>> getAzkar() async {
    if (_azkarBox == null) await init();
    final list = <ZikrModel>[];
    for (final key in _azkarBox!.keys) {
      final data = _azkarBox!.get(key);
      if (data is Map) {
        list.add(ZikrModel.fromJson(Map<String, dynamic>.from(data)));
      }
    }
    return list;
  }

  @override
  Future<void> saveZikr(ZikrModel zikr) async {
    if (_azkarBox == null) await init();
    await _azkarBox!.put(zikr.id, zikr.toJson());
  }

  @override
  Future<void> deleteZikr(String id) async {
    if (_azkarBox == null) await init();
    await _azkarBox!.delete(id);
  }

  @override
  Future<AzkarSettingsModel> getSettings() async {
    if (_settingsBox == null) await init();
    final raw = _settingsBox!.get('settings');
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (raw is Map) {
      final model = AzkarSettingsModel.fromJson(Map<String, dynamic>.from(raw));
      if (model.lastDate != todayStr) {
        final newModel = AzkarSettingsModel(
          intervalMinutes: model.intervalMinutes,
          dailyGoal: model.dailyGoal,
          completedToday: 0,
          totalTapsToday: 0,
          isEnabled: model.isEnabled,
          lastDate: todayStr,
        );
        await saveSettings(newModel);
        return newModel;
      }
      return model;
    }

    final defaultSettings = AzkarSettingsModel(lastDate: todayStr);
    await saveSettings(defaultSettings);
    return defaultSettings;
  }

  @override
  Future<void> saveSettings(AzkarSettingsModel settings) async {
    if (_settingsBox == null) await init();
    await _settingsBox!.put('settings', settings.toJson());
  }

  @override
  Future<void> incrementCompletedCount() async {
    final current = await getSettings();
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final updated = AzkarSettingsModel(
      intervalMinutes: current.intervalMinutes,
      dailyGoal: current.dailyGoal,
      completedToday: current.completedToday + 1,
      totalTapsToday: current.totalTapsToday,
      isEnabled: current.isEnabled,
      lastDate: todayStr,
    );
    await saveSettings(updated);

    // Update real daily analytics log
    await _updateDailyLog(todayStr, addedTaps: 0, addedSessions: 1);
  }

  @override
  Future<void> recordZikrTap(String zikrId, int addedTaps) async {
    if (_azkarBox == null) await init();
    final raw = _azkarBox!.get(zikrId);
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (raw is Map) {
      final model = ZikrModel.fromJson(Map<String, dynamic>.from(raw));
      final updatedModel = ZikrModel(
        id: model.id,
        textAr: model.textAr,
        textEn: model.textEn,
        defaultTargetCount: model.defaultTargetCount,
        category: model.category,
        isCustom: model.isCustom,
        todayTapCount: model.todayTapCount + addedTaps,
        lastTapDate: todayStr,
      );
      await _azkarBox!.put(zikrId, updatedModel.toJson());
    }

    final currentSettings = await getSettings();
    final updatedSettings = AzkarSettingsModel(
      intervalMinutes: currentSettings.intervalMinutes,
      dailyGoal: currentSettings.dailyGoal,
      completedToday: currentSettings.completedToday,
      totalTapsToday: currentSettings.totalTapsToday + addedTaps,
      isEnabled: currentSettings.isEnabled,
      lastDate: todayStr,
    );
    await saveSettings(updatedSettings);

    // Update real daily analytics log
    await _updateDailyLog(todayStr, addedTaps: addedTaps, addedSessions: 0);
  }

  Future<void> _updateDailyLog(String dateStr, {required int addedTaps, required int addedSessions}) async {
    if (_logsBox == null) await init();
    final raw = _logsBox!.get(dateStr);
    int existingTaps = 0;
    int existingSessions = 0;

    if (raw is Map) {
      existingTaps = raw['taps'] as int? ?? 0;
      existingSessions = raw['completedSessions'] as int? ?? 0;
    }

    await _logsBox!.put(dateStr, {
      'dateStr': dateStr,
      'taps': existingTaps + addedTaps,
      'completedSessions': existingSessions + addedSessions,
    });
  }

  @override
  Future<Map<String, dynamic>> getDailyLogMap() async {
    if (_logsBox == null) await init();
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final currentSettings = await getSettings();

    // Ensure real entry exists for today
    if (!_logsBox!.containsKey(todayStr)) {
      await _logsBox!.put(todayStr, {
        'dateStr': todayStr,
        'taps': currentSettings.totalTapsToday,
        'completedSessions': currentSettings.completedToday,
      });
    } else {
      final raw = _logsBox!.get(todayStr);
      if (raw is Map) {
        final currentTaps = raw['taps'] as int? ?? 0;
        final currentSessions = raw['completedSessions'] as int? ?? 0;
        if (currentSettings.totalTapsToday > currentTaps || currentSettings.completedToday > currentSessions) {
          await _logsBox!.put(todayStr, {
            'dateStr': todayStr,
            'taps': currentSettings.totalTapsToday > currentTaps ? currentSettings.totalTapsToday : currentTaps,
            'completedSessions': currentSettings.completedToday > currentSessions ? currentSettings.completedToday : currentSessions,
          });
        }
      }
    }

    final map = <String, dynamic>{};
    for (final key in _logsBox!.keys) {
      final val = _logsBox!.get(key);
      if (val != null) {
        map[key.toString()] = val;
      }
    }
    return map;
  }
}
