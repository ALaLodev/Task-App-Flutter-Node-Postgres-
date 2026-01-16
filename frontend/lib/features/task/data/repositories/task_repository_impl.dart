import 'package:fpdart/fpdart.dart' hide Task;
import 'package:frontend/core/error/exception.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/task/data/datasources/task_remote_data_source.dart';
import 'package:frontend/features/task/data/models/task_model.dart';
import 'package:frontend/features/task/domain/entities/task.dart';
import 'package:frontend/features/task/domain/repository/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Task>> uploadTask({
    required String uid,
    required String title,
    required String description,
    required String hexColor,
    required String token,
  }) async {
    try {
      // 1. Creamos el modelo
      final taskModel = TaskModel(
        id: '', // El servidor generará el ID, enviamos vacío por ahora
        uid: uid,
        title: title,
        description: description,
        hexColor: hexColor,
        updatedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // 2. Intentamos enviarlo (Esto puede lanzar ServerException)
      final remoteTask = await remoteDataSource.uploadTask(
        task: taskModel,
        token: token,
      );

      // 3. Si todo va bien, devolvemos la Entidad (Right)
      return right(remoteTask);
    } on ServerException catch (e) {
      // 4. Si explota por culpa del servidor (nuestra excepción personalizada)
      // Convertimos la Exception en un Failure
      return left(Failure(e.message));
    } catch (e) {
      // 5. Si explota por otra cosa (ej. error de código local)
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasks({required String token}) async {
    try {
      final tasks = await remoteDataSource.getTasks(token: token);
      return right(tasks);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
