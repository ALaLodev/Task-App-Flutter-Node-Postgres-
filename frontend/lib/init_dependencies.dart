import 'package:frontend/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:frontend/features/auth/domain/usecases/current_user.dart';
import 'package:frontend/features/auth/domain/usecases/user_login.dart';
import 'package:frontend/features/auth/domain/usecases/user_logout.dart';
import 'package:frontend/features/task/domain/usecases/delete_task.dart';
import 'package:frontend/features/task/domain/usecases/get_all_tasks.dart';
import 'package:frontend/features/task/domain/usecases/sync_task_status.dart';
import 'package:frontend/features/task/presentation/bloc/task_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:frontend/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/auth/domain/repository/auth_repository.dart';
import 'package:frontend/features/auth/domain/usecases/user_sign_up.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/features/task/data/datasources/task_remote_data_source.dart';
import 'package:frontend/features/task/data/repositories/task_repository_impl.dart';
import 'package:frontend/features/task/domain/repository/task_repository.dart';
import 'package:frontend/features/task/domain/usecases/upload_task.dart';

// Creamos la instancia global del Service Locator
final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton(() => sharedPreferences);

  _initAuth();
  _initTask();
}

void _initAuth() {
  // 1. Data Source Remoto
  serviceLocator.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  //  Datasource Local
  serviceLocator.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(serviceLocator()),
  );

  // 2. Repository
  // Fíjate como inyectamos el Data Source buscando en el serviceLocator
  serviceLocator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(serviceLocator(), serviceLocator()),
  );

  // 3. Use Case
  serviceLocator.registerLazySingleton(() => UserSignUp(serviceLocator()));
  serviceLocator.registerLazySingleton(() => UserLogin(serviceLocator()));
  serviceLocator.registerLazySingleton(() => CurrentUser(serviceLocator()));
  serviceLocator.registerLazySingleton(() => UserLogout(serviceLocator()));

  // 4. BLoC
  // Usamos registerFactory: Se crea una INSTANCIA NUEVA cada vez que la UI lo pide.
  // IMPORTANTE: Los BLoCs suelen ser factories para evitar estados viejos al cerrar sesión.
  serviceLocator.registerFactory(
    () => AuthBloc(
      userSignUp: serviceLocator(),
      userLogin: serviceLocator(),
      currentUser: serviceLocator(),
      userLogout: serviceLocator(),
    ),
  );
}

void _initTask() {
  // Datasource
  serviceLocator.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(),
  );

  // Repository
  serviceLocator.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(serviceLocator()),
  );

  // Use Case
  serviceLocator.registerLazySingleton(() => UploadTask(serviceLocator()));
  serviceLocator.registerLazySingleton(() => GetAllTasks(serviceLocator()));
  serviceLocator.registerFactory(() => SyncTaskStatus(serviceLocator()));
  serviceLocator.registerLazySingleton(() => DeleteTask(serviceLocator()));

  // BLoC
  serviceLocator.registerLazySingleton(
    () => TaskBloc(
      uploadTask: serviceLocator(),
      getAllTasks: serviceLocator(),
      syncTaskStatus: serviceLocator(),
      deleteTask: serviceLocator(),
    ),
  );
}
