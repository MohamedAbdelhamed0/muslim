import '../entities/azkar_settings_entity.dart';
import '../entities/zikr_entity.dart';

abstract class AzkarRepository {
  Future<List<ZikrEntity>> getAzkar();
  Future<void> saveZikr(ZikrEntity zikr);
  Future<void> deleteZikr(String id);
  Future<AzkarSettingsEntity> getSettings();
  Future<void> saveSettings(AzkarSettingsEntity settings);
  Future<void> incrementCompletedCount();
  Future<void> recordZikrTap(String zikrId, int addedTaps);
}
