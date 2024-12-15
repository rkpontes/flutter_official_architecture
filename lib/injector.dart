// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_oficial_architecture/data/repositories/book/book_repository_local.dart';
import 'package:flutter_oficial_architecture/utils/config.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:flutter_oficial_architecture/data/repositories/book/book_repository.dart';
import 'package:flutter_oficial_architecture/data/repositories/book/book_repository_remote.dart';
import 'package:flutter_oficial_architecture/data/services/api_client/api_client.dart';
import 'package:flutter_oficial_architecture/data/services/api_client/api_client_impl.dart';
import 'package:flutter_oficial_architecture/data/services/local_storage/local_storage.dart';
import 'package:flutter_oficial_architecture/data/services/local_storage/local_storage_impl.dart';
import 'package:flutter_oficial_architecture/domain/use_cases/book/add_book_usecase.dart';
import 'package:flutter_oficial_architecture/domain/use_cases/book/delete_book_usecase.dart';
import 'package:flutter_oficial_architecture/domain/use_cases/book/edit_book_usecase.dart';
import 'package:flutter_oficial_architecture/domain/use_cases/book/get_book_usecase.dart';
import 'package:flutter_oficial_architecture/domain/use_cases/book/list_books_usecase.dart';
import 'package:flutter_oficial_architecture/ui/home/view_models/home_view_model.dart';

class Injector {
  static final GetIt getIt = GetIt.instance;

  static void configureDependencies({Flavor flavor = Flavor.development}) {
    // Utils
    getIt.registerLazySingleton<Config>(() => Config(flavor: flavor));

    // Services
    getIt.registerLazySingleton<String>(
      () {
        if (flavor == Flavor.development) {
          return const String.fromEnvironment('API_BASE_URL_LOCAL');
        }

        return const String.fromEnvironment('API_BASE_URL_REMOTE');
      },
      instanceName: 'baseUrl',
    );
    getIt.registerLazySingleton<Dio>(() =>
        Dio(BaseOptions(baseUrl: getIt.get<String>(instanceName: 'baseUrl'))));

    getIt.registerLazySingleton<ApiClient>(
        () => ApiClientImpl(getIt.get<Dio>()));

    getIt.registerLazySingletonAsync<SharedPreferences>(
        () async => SharedPreferences.getInstance());

    getIt.registerLazySingleton<LocalStorage>(
        () => LocalStorageImpl(getIt.get<SharedPreferences>()));

    // Repositories
    getIt.registerLazySingleton<BookRepository>(
      () {
        if (flavor == Flavor.development) {
          return BookRepositoryLocal(getIt.get<LocalStorage>());
        }
        return BookRepositoryRemote(getIt.get<ApiClient>());
      },
    );

    // Use cases
    getIt.registerLazySingleton<AddBookUsecase>(
        () => AddBookUsecase(getIt.get<BookRepository>()));
    getIt.registerLazySingleton<DeleteBookUsecase>(
        () => DeleteBookUsecase(getIt.get<BookRepository>()));
    getIt.registerLazySingleton<EditBookUsecase>(
        () => EditBookUsecase(getIt.get<BookRepository>()));
    getIt.registerLazySingleton<GetBookUsecase>(
        () => GetBookUsecase(getIt.get<BookRepository>()));
    getIt.registerLazySingleton<ListBooksUsecase>(
        () => ListBooksUsecase(getIt.get<BookRepository>()));

    // View models
    getIt.registerLazySingleton<HomeViewModel>(() => HomeViewModel(
          getIt.get<ListBooksUsecase>(),
          getIt.get<AddBookUsecase>(),
          getIt.get<EditBookUsecase>(),
          getIt.get<DeleteBookUsecase>(),
        ));
  }
}

enum Flavor { development, production }
