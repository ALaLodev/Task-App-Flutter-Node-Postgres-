part of 'task_bloc.dart';

sealed class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object> get props => [];
}

final class TaskInitial extends TaskState {}

final class TaskLoading extends TaskState {}

final class TaskSuccess extends TaskState {
  final Task task;
  const TaskSuccess(this.task);

  @override
  List<Object> get props => [task];
}

final class TaskFailure extends TaskState {
  final String error;
  const TaskFailure(this.error);

  @override
  List<Object> get props => [error];
}

final class TasksDisplaySuccess extends TaskState {
  final List<Task> tasks;

  const TasksDisplaySuccess(this.tasks);

  @override
  List<Object> get props => [tasks];
}
