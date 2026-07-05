import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/zikr_entity.dart';
import '../../domain/repositories/azkar_repository.dart';

final azkarRepositoryProvider = Provider<AzkarRepository>((ref) {
  return getIt<AzkarRepository>();
});

class AzkarNotifier extends StateNotifier<AsyncValue<List<ZikrEntity>>> {
  final AzkarRepository _repository;

  AzkarNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadAzkar();
  }

  Future<void> loadAzkar() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.getAzkar();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addZikr({
    required String textAr,
    String textEn = '',
    required int defaultTargetCount,
  }) async {
    final newZikr = ZikrEntity(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      textAr: textAr,
      textEn: textEn,
      defaultTargetCount: defaultTargetCount,
      category: 'Custom',
      isCustom: true,
    );
    await _repository.saveZikr(newZikr);
    await loadAzkar();
  }

  Future<void> updateZikr(ZikrEntity updatedZikr) async {
    await _repository.saveZikr(updatedZikr);
    await loadAzkar();
  }

  Future<void> recordTap(String zikrId, int addedTaps) async {
    await _repository.recordZikrTap(zikrId, addedTaps);
    await loadAzkar();
  }

  Future<void> deleteZikr(String id) async {
    await _repository.deleteZikr(id);
    await loadAzkar();
  }
}

final azkarNotifierProvider =
    StateNotifierProvider<AzkarNotifier, AsyncValue<List<ZikrEntity>>>((ref) {
  return AzkarNotifier(ref.watch(azkarRepositoryProvider));
});
