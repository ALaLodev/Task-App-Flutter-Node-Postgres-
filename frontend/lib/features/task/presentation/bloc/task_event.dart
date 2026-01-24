part of 'task_bloc.dart';

sealed class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

final class TaskUpload extends TaskEvent {
  final String uid;
  final String title;
  final String description;
  final String hexColor;
  final DateTime dueDate;
  final String token;

  const TaskUpload({
    required this.uid,
    required this.title,
    required this.description,
    required this.hexColor,
    required this.dueDate,
    required this.token,
  });

  @override
  List<Object> get props => [uid, title, description, hexColor, dueDate, token];
}

final class TaskFetchAllTasks extends TaskEvent {
  final String token;

  const TaskFetchAllTasks({required this.token});

  @override
  List<Object> get props => [token];
}

final class TaskUpdateStatus extends TaskEvent {
  final String taskId;
  final bool isCompleted;
  final String token;

  const TaskUpdateStatus({
    required this.taskId,
    required this.isCompleted,
    required this.token,
  });

  @override
  List<Object> get props => [taskId, isCompleted, token];
}

final class TaskDelete extends TaskEvent {
  final String taskId;
  final String token;

  const TaskDelete({required this.taskId, required this.token});

  @override
  List<Object> get props => [taskId, token];
}

final class TaskEdit extends TaskEvent {
  final Task task;
  final String token;

  const TaskEdit({required this.task, required this.token});

  @override
  List<Object> get props => [task, token];
}
