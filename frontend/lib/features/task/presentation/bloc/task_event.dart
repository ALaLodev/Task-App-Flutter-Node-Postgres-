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
  final String token;

  const TaskUpload({
    required this.uid,
    required this.title,
    required this.description,
    required this.hexColor,
    required this.token,
  });

  @override
  List<Object> get props => [uid, title, description, hexColor, token];
}

final class TaskFetchAllTasks extends TaskEvent {
  final String token;

  const TaskFetchAllTasks({required this.token});

  @override
  List<Object> get props => [token];
}
