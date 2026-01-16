import 'package:fpdart/fpdart.dart' hide Task;
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/task/domain/entities/task.dart';
import 'package:frontend/features/task/domain/repository/task_repository.dart';

class GetAllTasks implements UseCase<List<Task>, String> {
  final TaskRepository taskRepository;

  GetAllTasks(this.taskRepository);

  @override
  Future<Either<Failure, List<Task>>> call(String token) async {
    return await taskRepository.getTasks(token: token);
  }
}
