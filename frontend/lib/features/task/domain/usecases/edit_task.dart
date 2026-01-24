import 'package:fpdart/fpdart.dart' hide Task;
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/task/domain/entities/task.dart';
import 'package:frontend/features/task/domain/repository/task_repository.dart';

final class EditTask implements UseCase<Task, EditTaskParams> {
  final TaskRepository repository;

  EditTask(this.repository);

  @override
  Future<Either<Failure, Task>> call(EditTaskParams params) async {
    return repository.editTask(task: params.task, token: params.token);
  }
}

class EditTaskParams {
  final Task task;
  final String token;
  EditTaskParams({required this.task, required this.token});
}
