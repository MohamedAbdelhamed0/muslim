import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../domain/entities/zikr_entity.dart';
import 'azkar_provider.dart';
import 'azkar_settings_provider.dart';

class ActiveZikrAlert {
  final ZikrEntity zikr;
  final int currentTapCount;

  ActiveZikrAlert({
    required this.zikr,
    this.currentTapCount = 0,
  });

  bool get isCompleted => currentTapCount >= zikr.defaultTargetCount;

  ActiveZikrAlert copyWith({int? currentTapCount}) {
    return ActiveZikrAlert(
      zikr: zikr,
      currentTapCount: currentTapCount ?? this.currentTapCount,
    );
  }
}

class ActiveZikrAlertNotifier extends StateNotifier<ActiveZikrAlert?> {
  final Ref _ref;

  ActiveZikrAlertNotifier(this._ref) : super(null);

  Future<void> triggerAlert([ZikrEntity? customZikr]) async {
    final azkarAsync = _ref.read(azkarNotifierProvider);
    final list = azkarAsync.value;

    ZikrEntity? targetZikr = customZikr;
    if (targetZikr == null && list != null && list.isNotEmpty) {
      final random = Random();
      targetZikr = list[random.nextInt(list.length)];
    }

    targetZikr ??= const ZikrEntity(
      id: 'default',
      textAr: 'سبحان الله وبحمده ، سبحان الله العظيم',
      defaultTargetCount: 3,
    );

    // Windows window wake up & fullscreen setup
    if (kIsWeb == false && Platform.isWindows) {
      try {
        await windowManager.show();
        await windowManager.restore();
        await windowManager.focus();
        await windowManager.setFullScreen(true);
      } catch (e) {
        if (kDebugMode) debugPrint('Error restoring window for Zikr: $e');
      }
    }

    state = ActiveZikrAlert(zikr: targetZikr, currentTapCount: 0);
  }

  Future<void> incrementTap() async {
    if (state == null) return;
    final nextCount = state!.currentTapCount + 1;

    // Record tap in persistence & update stats
    await _ref
        .read(azkarNotifierProvider.notifier)
        .recordTap(state!.zikr.id, 1);
    await _ref.read(azkarSettingsNotifierProvider.notifier).loadSettings();

    if (nextCount >= state!.zikr.defaultTargetCount) {
      // Completed!
      await _ref.read(azkarSettingsNotifierProvider.notifier).incrementCompleted();
      await dismissAlert();
    } else {
      state = state!.copyWith(currentTapCount: nextCount);
    }
  }

  Future<void> dismissAlert() async {
    state = null;

    // Windows exit fullscreen and minimize
    if (kIsWeb == false && Platform.isWindows) {
      try {
        await windowManager.setFullScreen(false);
        await windowManager.minimize();
      } catch (e) {
        if (kDebugMode) debugPrint('Error minimizing window after Zikr: $e');
      }
    }
  }
}

final activeZikrAlertNotifierProvider =
    StateNotifierProvider<ActiveZikrAlertNotifier, ActiveZikrAlert?>((ref) {
  return ActiveZikrAlertNotifier(ref);
});

class AzkarTimerNotifier extends StateNotifier<DateTime?> {
  final Ref _ref;
  Timer? _intervalTimer;

  AzkarTimerNotifier(this._ref) : super(null) {
    _startTimer();
  }

  void _startTimer() {
    _intervalTimer?.cancel();
    // Check every minute if interval is reached
    _intervalTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _tick();
    });
  }

  void _tick() {
    final settingsAsync = _ref.read(azkarSettingsNotifierProvider);
    final settings = settingsAsync.value;

    if (settings == null || !settings.isEnabled) return;

    final now = DateTime.now();

    if (state == null) {
      state = now;
      return;
    }

    final diff = now.difference(state!).inMinutes;
    if (diff >= settings.intervalMinutes) {
      state = now;
      _ref.read(activeZikrAlertNotifierProvider.notifier).triggerAlert();
    }
  }

  @override
  void dispose() {
    _intervalTimer?.cancel();
    super.dispose();
  }
}

final azkarTimerNotifierProvider =
    StateNotifierProvider<AzkarTimerNotifier, DateTime?>((ref) {
  return AzkarTimerNotifier(ref);
});
