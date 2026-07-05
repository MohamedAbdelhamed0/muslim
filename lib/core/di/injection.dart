import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../../features/adhan/data/datasources/adhan_remote_data_source.dart';
import '../../features/adhan/data/repositories/adhan_repository_impl.dart';
import '../../features/adhan/domain/repositories/adhan_repository.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  // Core Network
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // Features - Adhan
  getIt.registerLazySingleton<AdhanRemoteDataSource>(
    () => AdhanRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<AdhanRepository>(
    () => AdhanRepositoryImpl(getIt<AdhanRemoteDataSource>()),
  );
}
