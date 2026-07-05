import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/adhan_audio_service.dart';
import '../../domain/entities/next_prayer.dart';
import 'adhan_provider.dart';

/// Active 5-minute Fullscreen Alert State
class ActiveAdhanAlert {
  final String prayerName;
  final DateTime time;
  final int remainingAlertSeconds;

  ActiveAdhanAlert({
    required this.prayerName,
    required this.time,
    required this.remainingAlertSeconds,
  });

  ActiveAdhanAlert copyWith({int? remainingAlertSeconds}) {
    return ActiveAdhanAlert(
      prayerName: prayerName,
      time: time,
      remainingAlertSeconds: remainingAlertSeconds ?? this.remainingAlertSeconds,
    );
  }
}

/// Riverpod StateNotifier managing the 5-minute active Adhan alert overlay state
class ActiveAdhanAlertNotifier extends StateNotifier<ActiveAdhanAlert?> {
  Timer? _alertTimer;
  final AdhanAudioService _audioService = getIt<AdhanAudioService>();

  ActiveAdhanAlertNotifier() : super(null);

  Future<void> triggerAlert(String prayerName, DateTime time) async {
    _alertTimer?.cancel();

    // 1. Play Adhan Sound
    await _audioService.playAdhan();

    // 2. Windows-specific window behavior: Wake up, focus, set fullscreen
    if (kIsWeb == false && Platform.isWindows) {
      try {
        await windowManager.show();
        await windowManager.restore();
        await windowManager.focus();
        await windowManager.setFullScreen(true);
      } catch (e) {
        if (kDebugMode) debugPrint('Error updating window state: $e');
      }
    }

    // 3. Set alert state with 300 seconds (5 minutes) countdown
    state = ActiveAdhanAlert(
      prayerName: prayerName,
      time: time,
      remainingAlertSeconds: 300,
    );

    // 4. Tick every second down from 5 minutes (300s)
    _alertTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state == null) {
        timer.cancel();
        return;
      }
      final currentRemaining = state!.remainingAlertSeconds - 1;
      if (currentRemaining <= 0) {
        dismissAlert();
      } else {
        state = state!.copyWith(remainingAlertSeconds: currentRemaining);
      }
    });
  }

  /// Dismisses active alert, stops audio playback, and minimizes window back on Windows
  Future<void> dismissAlert() async {
    _alertTimer?.cancel();
    state = null;

    // Stop Adhan sound
    await _audioService.stopAdhan();

    // Windows exit fullscreen and minimize
    if (kIsWeb == false && Platform.isWindows) {
      try {
        await windowManager.setFullScreen(false);
        await windowManager.minimize();
      } catch (e) {
        if (kDebugMode) debugPrint('Error restoring window state: $e');
      }
    }
  }

  @override
  void dispose() {
    _alertTimer?.cancel();
    super.dispose();
  }
}

final activeAdhanAlertNotifierProvider =
    StateNotifierProvider<ActiveAdhanAlertNotifier, ActiveAdhanAlert?>((ref) {
  return ActiveAdhanAlertNotifier();
});

/// Ticking clock state notifier holding current device time & next prayer countdown
class AdhanTimerNotifier extends StateNotifier<NextPrayer?> {
  final Ref _ref;
  Timer? _timer;
  final Set<String> _triggeredPrayersToday = {};

  AdhanTimerNotifier(this._ref) : super(null) {
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick();
    });
  }

  void _tick() {
    final asyncData = _ref.read(adhanNotifierProvider);
    asyncData.whenData((prayerTimes) {
      final now = DateTime.now();
      final nextPrayer = prayerTimes.getNextPrayer(now);
      state = nextPrayer;

      // Check if current time matches any prayer time today
      final prayers = prayerTimes.toMap();
      prayers.forEach((prayerName, prayerTime) {
        final diffInSeconds = now.difference(prayerTime).inSeconds;

        // Match window: between 0 and 2 seconds after prayer time
        if (diffInSeconds >= 0 && diffInSeconds <= 2) {
          final eventKey = '${prayerName}_${prayerTime.day}';
          if (!_triggeredPrayersToday.contains(eventKey)) {
            _triggeredPrayersToday.add(eventKey);
            _onPrayerTimeReached(prayerName, prayerTime);
          }
        }
      });
    });
  }

  void _onPrayerTimeReached(String prayerName, DateTime prayerTime) {
    if (kDebugMode) {
      debugPrint('🔔 [ADHAN TIMER RELEASING ALERT] $prayerName prayer reached!');
    }
    _ref
        .read(activeAdhanAlertNotifierProvider.notifier)
        .triggerAlert(prayerName, prayerTime);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final adhanTimerNotifierProvider =
    StateNotifierProvider<AdhanTimerNotifier, NextPrayer?>((ref) {
  return AdhanTimerNotifier(ref);
});

/// Stream provider for raw current time ticking
final currentTimeStreamProvider = StreamProvider<DateTime>((ref) async* {
  while (true) {
    yield DateTime.now();
    await Future.delayed(const Duration(seconds: 1));
  }
});
