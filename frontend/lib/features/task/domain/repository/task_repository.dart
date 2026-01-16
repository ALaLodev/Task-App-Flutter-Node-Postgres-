import 'package:fpdart/fpdart.dart' hide Task;
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/task/domain/entities/task.dart';

abstract interface class TaskRepository {
  Future<Either<Failure, Task>> uploadTask({
    required String uid,
    required String title,
    required String description,
    required String hexColor,
    required String token,
  });

  Future<Either<Failure, List<Task>>> getTasks({required String token});
}
