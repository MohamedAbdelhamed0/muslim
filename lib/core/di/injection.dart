import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../services/adhan_audio_service.dart';
import '../../features/adhan/data/datasources/adhan_remote_data_source.dart';
import '../../features/adhan/data/repositories/adhan_repository_impl.dart';
import '../../features/adhan/domain/repositories/adhan_repository.dart';

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
}
