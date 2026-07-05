import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/next_prayer.dart';
import 'adhan_provider.dart';

/// Event model fired when a prayer time is reached
class PrayerReachedEvent {
  final String prayerName;
  final DateTime time;
  final DateTime triggeredAt;

  PrayerReachedEvent({
    required this.prayerName,
    required this.time,
    required this.triggeredAt,
  });
}

/// Optional callback type for playing audio / sound logic
typedef OnPrayerReachedCallback = void Function(PrayerReachedEvent event);

/// Riverpod provider for the audio callback function slot.
/// Users can override this provider or assign a callback to hook in `audioplayers` package.
final adhanAudioCallbackProvider = StateProvider<OnPrayerReachedCallback?>((ref) {
  return (event) {
    if (kDebugMode) {
      debugPrint('🔔 [ADHAN TIMER CALLBACK TRIGGERED] It is time for ${event.prayerName} prayer! (Triggered at ${event.triggeredAt})');
    }
  };
});

/// Ticking clock state notifier that holds current device time & next prayer countdown
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
            _onPrayerTimeReached(prayerName, prayerTime, now);
          }
        }
      });
    });
  }

  void _onPrayerTimeReached(String prayerName, DateTime prayerTime, DateTime now) {
    final event = PrayerReachedEvent(
      prayerName: prayerName,
      time: prayerTime,
      triggeredAt: now,
    );

    // Call registered callback slot (where audioplayers logic will go)
    final callback = _ref.read(adhanAudioCallbackProvider);
    callback?.call(event);
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
