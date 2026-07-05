import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/azkar_settings_entity.dart';
import '../../domain/repositories/azkar_repository.dart';

class AzkarSettingsNotifier extends StateNotifier<AsyncValue<AzkarSettingsEntity>> {
  final AzkarRepository _repository = getIt<AzkarRepository>();

  AzkarSettingsNotifier() : super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final settings = await _repository.getSettings();
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSettings({
    int? intervalMinutes,
    int? dailyGoal,
    bool? isEnabled,
  }) async {
    final current = state.value ?? const AzkarSettingsEntity();
    final updated = current.copyWith(
      intervalMinutes: intervalMinutes,
      dailyGoal: dailyGoal,
      isEnabled: isEnabled,
    );
    await _repository.saveSettings(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> incrementCompleted() async {
    await _repository.incrementCompletedCount();
    await loadSettings();
  }
}

final azkarSettingsNotifierProvider = StateNotifierProvider<
    AzkarSettingsNotifier, AsyncValue<AzkarSettingsEntity>>((ref) {
  return AzkarSettingsNotifier();
});
