import 'package:fpdart/fpdart.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/task/domain/repository/task_repository.dart';

final class DeleteTask implements UseCase<void, DeleteTaskParams> {
  final TaskRepository taskRepository;

  DeleteTask(this.taskRepository);

  @override
  Future<Either<Failure, void>> call(DeleteTaskParams params) async {
    return await taskRepository.deleteTask(
      taskId: params.taskId,
      token: params.token,
    );
  }
}

class DeleteTaskParams {
  final String taskId;
  final String token;

  DeleteTaskParams({required this.taskId, required this.token});
}
