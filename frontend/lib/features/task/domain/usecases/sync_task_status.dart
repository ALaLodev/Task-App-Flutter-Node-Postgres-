import 'package:fpdart/fpdart.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/task/domain/repository/task_repository.dart';

final class SyncTaskStatus implements UseCase<void, SyncTaskStatusParams> {
  final TaskRepository taskRepository;

  SyncTaskStatus(this.taskRepository);

  @override
  Future<Either<Failure, void>> call(SyncTaskStatusParams params) async {
    return await taskRepository.syncTaskStatus(
      token: params.token,
      taskId: params.taskId,
      isCompleted: params.isCompleted,
    );
  }
}

class SyncTaskStatusParams {
  final String token;
  final String taskId;
  final bool isCompleted;

  SyncTaskStatusParams({
    required this.token,
    required this.taskId,
    required this.isCompleted,
  });
}
