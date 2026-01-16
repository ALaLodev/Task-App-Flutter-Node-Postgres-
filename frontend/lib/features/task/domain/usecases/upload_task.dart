import 'package:fpdart/fpdart.dart' hide Task;
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/task/domain/entities/task.dart';
import 'package:frontend/features/task/domain/repository/task_repository.dart';

class UploadTask implements UseCase<Task, UploadTaskParams> {
  final TaskRepository taskRepository;

  UploadTask(this.taskRepository);

  @override
  Future<Either<Failure, Task>> call(UploadTaskParams params) async {
    return await taskRepository.uploadTask(
      uid: params.uid,
      title: params.title,
      description: params.description,
      hexColor: params.hexColor,
      token: params.token,
    );
  }
}

class UploadTaskParams {
  final String uid;
  final String title;
  final String description;
  final String hexColor;
  final String token;

  UploadTaskParams({
    required this.uid,
    required this.title,
    required this.description,
    required this.hexColor,
    required this.token,
  });
}
