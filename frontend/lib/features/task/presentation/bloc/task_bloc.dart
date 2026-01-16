import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/task/domain/entities/task.dart';
import 'package:frontend/features/task/domain/usecases/get_all_tasks.dart';
import 'package:frontend/features/task/domain/usecases/upload_task.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final UploadTask _uploadTask;
  final GetAllTasks _getAllTasks;

  TaskBloc({required UploadTask uploadTask, required GetAllTasks getAllTasks})
    : _uploadTask = uploadTask,
      _getAllTasks = getAllTasks,
      super(TaskInitial()) {
    //on<TaskEvent>((event, emit) => emit(TaskLoading()));
    on<TaskUpload>(_onTaskUpload);
    on<TaskFetchAllTasks>(_onFetchAllTasks);
  }

  void _onTaskUpload(TaskUpload event, Emitter<TaskState> emit) async {
    emit(TaskLoading());

    final res = await _uploadTask(
      UploadTaskParams(
        uid: event.uid,
        title: event.title,
        description: event.description,
        hexColor: event.hexColor,
        token: event.token,
      ),
    );
    res.fold(
      (failure) => emit(TaskFailure(failure.message)),
      (task) => emit(TaskSuccess(task)),
    );
  }

  void _onFetchAllTasks(
    TaskFetchAllTasks event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());

    print('🔍 Debug: Llamando al caso de uso GetAllTasks...');
    final res = await _getAllTasks(event.token);

    res.fold(
      (l) {
        print('❌ Debug Error: ${l.message}');
        emit(TaskFailure(l.message));
      },
      (r) {
        print('✅ Debug Éxito: ${r.length} tareas encontradas');
        emit(TasksDisplaySuccess(r));
      },
    );
  }
}
