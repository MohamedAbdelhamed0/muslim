import '../../domain/entities/azkar_settings_entity.dart';
import '../../domain/entities/zikr_entity.dart';
import '../../domain/repositories/azkar_repository.dart';
import '../datasources/azkar_local_data_source.dart';
import '../models/azkar_settings_model.dart';
import '../models/zikr_model.dart';
import 'package:intl/intl.dart';

class AzkarRepositoryImpl implements AzkarRepository {
  final AzkarLocalDataSource _localDataSource;

  AzkarRepositoryImpl(this._localDataSource);

  @override
  Future<List<ZikrEntity>> getAzkar() async {
    final models = await _localDataSource.getAzkar();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveZikr(ZikrEntity zikr) async {
    await _localDataSource.saveZikr(ZikrModel.fromEntity(zikr));
  }

  @override
  Future<void> deleteZikr(String id) async {
    await _localDataSource.deleteZikr(id);
  }

  @override
  Future<AzkarSettingsEntity> getSettings() async {
    final model = await _localDataSource.getSettings();
    return model.toEntity();
  }

  @override
  Future<void> saveSettings(AzkarSettingsEntity settings) async {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _localDataSource.saveSettings(
      AzkarSettingsModel.fromEntity(settings, todayStr),
    );
  }

  @override
  Future<void> incrementCompletedCount() async {
    await _localDataSource.incrementCompletedCount();
  }

  @override
  Future<void> recordZikrTap(String zikrId, int addedTaps) async {
    await _localDataSource.recordZikrTap(zikrId, addedTaps);
  }
}
