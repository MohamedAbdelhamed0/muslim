import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../services/adhan_audio_service.dart';
import '../../features/adhan/data/datasources/adhan_remote_data_source.dart';
import '../../features/adhan/data/repositories/adhan_repository_impl.dart';
import '../../features/adhan/domain/repositories/adhan_repository.dart';
import '../../features/azkar/data/datasources/azkar_local_data_source.dart';
import '../../features/azkar/data/repositories/azkar_repository_impl.dart';
import '../../features/azkar/domain/repositories/azkar_repository.dart';
import '../../features/azkar_analytics/data/datasources/analytics_local_data_source.dart';
import '../../features/azkar_analytics/data/repositories/analytics_repository_impl.dart';
import '../../features/azkar_analytics/domain/repositories/analytics_repository.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  // Core Network & Services
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<AdhanAudioService>(() => AdhanAudioService());

  // Features - Adhan
  getIt.registerLazySingleton<AdhanRemoteDataSource>(
    () => AdhanRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<AdhanRepository>(
    () => AdhanRepositoryImpl(getIt<AdhanRemoteDataSource>()),
  );

  // Features - Azkar
  getIt.registerLazySingleton<AzkarLocalDataSource>(
    () => AzkarLocalDataSourceImpl(),
  );

  getIt.registerLazySingleton<AzkarRepository>(
    () => AzkarRepositoryImpl(getIt<AzkarLocalDataSource>()),
  );

  // Features - Azkar Analytics
  getIt.registerLazySingleton<AnalyticsLocalDataSource>(
    () => AnalyticsLocalDataSourceImpl(getIt<AzkarLocalDataSource>()),
  );

  getIt.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(getIt<AnalyticsLocalDataSource>()),
  );
}
