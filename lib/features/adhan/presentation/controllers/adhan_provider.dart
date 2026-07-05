import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/prayer_times.dart';
import '../../domain/repositories/adhan_repository.dart';

final adhanRepositoryProvider = Provider<AdhanRepository>((ref) {
  return getIt<AdhanRepository>();
});

class AdhanNotifier extends StateNotifier<AsyncValue<PrayerTimesEntity>> {
  final AdhanRepository _repository;

  AdhanNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchPrayerTimes();
  }

  Future<void> fetchPrayerTimes({
    String city = 'Cairo',
    String country = 'Egypt',
    int method = 5,
  }) async {
    state = const AsyncValue.loading();
    try {
      final prayerTimes = await _repository.getPrayerTimesByCity(
        city: city,
        country: country,
        method: method,
      );
      state = AsyncValue.data(prayerTimes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final adhanNotifierProvider =
    StateNotifierProvider<AdhanNotifier, AsyncValue<PrayerTimesEntity>>((ref) {
  return AdhanNotifier(ref.watch(adhanRepositoryProvider));
});
