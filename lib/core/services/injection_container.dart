import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../../presentation/auth/data/datasource/auth_datasource.dart';
import '../../presentation/auth/data/repo_impl/auth_repo_impl.dart';
import '../../presentation/auth/domain/repo/auth_repo.dart';
import '../../presentation/auth/domain/usecases/register_device_use_case.dart';
import '../../presentation/auth/presentation/bloc/auth_bloc.dart';
import '../../presentation/hotels/data/datasources/hotel_datasource.dart';
import '../../presentation/hotels/data/repo_impl/hotel_repo_impl.dart';
import '../../presentation/hotels/domain/repo/hotel_repo.dart';
import '../../presentation/hotels/domain/usecases/get_property_list_use_case.dart';
import '../../presentation/hotels/domain/usecases/get_search_result_use_case.dart';
import '../../presentation/hotels/domain/usecases/search_auto_complete_use_case.dart';
import '../../presentation/hotels/presentation/bloc/home_bloc.dart';
import '../../presentation/hotels/presentation/bloc/search_bloc.dart';
import '../../presentation/hotels/presentation/bloc/search_result_bloc.dart';
import '../network/network_info.dart';
import '../utils/pref_utils.dart';
import '../utils/urls.dart';

final sl = GetIt.instance;

Future<void> init() async {
  /// Register as a factory if you need a fresh instance each time
  /// sl.registerFactory<AppMenuCubit>(() => AppMenuCubit(getAppMenu: sl()));

  /// Or as a singleton if you need to maintain state across the app
  /// sl.registerLazySingleton<AppMenuCubit>(() => AppMenuCubit(getAppMenu: sl()));
  sl
  // Core
    ..registerLazySingleton(() => NetworkInfo())
    ..registerLazySingleton(() => PrefUtils())
  // App Logic
    ..registerFactory(() => AuthBloc())
    ..registerFactory(() => HomeBloc(sl(), sl(),))
    ..registerFactory(() => SearchBloc(sl(),))
    ..registerFactory(() => HotelSearchBloc(sl(),))

  // define Use cases
    ..registerFactory(() => RegisterDeviceUseCase(sl()))
    ..registerFactory(() => SearchAutoCompleteUseCase(sl()))
    ..registerFactory(() => GetPropertyListUseCase(sl()))
    ..registerFactory(() => GetSearchResultUseCase(sl()))

  //define repositories sources
    ..registerFactory<AuthRepo>(() => AuthRepoImpl(sl()))
    ..registerFactory<HotelRepo>(() => HotelRepoImpl(sl()))


  //define data sources
    ..registerFactory<AuthDatasource>(
            () => AuthDatasourceImpl())
    ..registerFactory<HotelDatasource>(
            () => HotelDatasourceImpl())


  // External Dependencies
    ..registerFactory(http.Client.new)

  // Dio Configuration
    ..registerLazySingleton(() {
      final dio = Dio();
      dio.options
        ..baseUrl = URLManager.baseUrl
        ..connectTimeout = const Duration(seconds: 30)
        ..receiveTimeout = const Duration(seconds: 30)
        ..sendTimeout = const Duration(seconds: 30);

      // Add interceptors if needed
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));

      return dio;
    });


}
