import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/task/data/models/task_model.dart';
import 'package:frontend/features/task/domain/entities/task.dart';
import 'package:frontend/features/task/domain/usecases/delete_task.dart';
import 'package:frontend/features/task/domain/usecases/get_all_tasks.dart';
import 'package:frontend/features/task/domain/usecases/sync_task_status.dart';
import 'package:frontend/features/task/domain/usecases/edit_task.dart';
import 'package:frontend/features/task/domain/usecases/upload_task.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final UploadTask _uploadTask;
  final GetAllTasks _getAllTasks;
  final SyncTaskStatus _syncTaskStatus;
  final DeleteTask _deleteTask;
  final EditTask _editTask;

  TaskBloc({
    required UploadTask uploadTask,
    required GetAllTasks getAllTasks,
    required SyncTaskStatus syncTaskStatus,
    required DeleteTask deleteTask,
    required EditTask editTask,
  }) : _uploadTask = uploadTask,
       _getAllTasks = getAllTasks,
       _syncTaskStatus = syncTaskStatus,
       _deleteTask = deleteTask,
       _editTask = editTask,
       super(TaskInitial()) {
    on<TaskUpload>(_onTaskUpload);
    on<TaskFetchAllTasks>(_onFetchAllTasks);
    on<TaskUpdateStatus>(_onUpdateTaskStatus);
    on<TaskDelete>(_onDeleteTask);
    on<TaskEdit>(_onTaskEdit);
  }

  // ---------------------------------------------------------------------------
  // 1. SUBIR TAREA
  // ---------------------------------------------------------------------------
  void _onTaskUpload(TaskUpload event, Emitter<TaskState> emit) async {
    // Solo emitimos Loading aquí porque es una operación "bloqueante" para la UI de Crear Tarea
    emit(TaskLoading());

    final res = await _uploadTask(
      UploadTaskParams(
        uid: event.uid,
        title: event.title,
        description: event.description,
        dueDate: event.dueDate,
        hexColor: event.hexColor,
        token: event.token,
      ),
    );

    res.fold(
      (failure) => emit(TaskFailure(failure.message)),
      // Al tener éxito, emitimos TaskSuccess para que la UI sepa que debe cerrar la pantalla
      (task) => emit(TaskSuccess(task)),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. OBTENER TODAS LAS TAREAS
  // ---------------------------------------------------------------------------
  void _onFetchAllTasks(
    TaskFetchAllTasks event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());

    final res = await _getAllTasks(event.token);

    res.fold(
      (l) => emit(TaskFailure(l.message)),
      (r) => emit(TasksDisplaySuccess(r)),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. ACTUALIZAR ESTADO (OPTIMISTA)
  // ---------------------------------------------------------------------------
  void _onUpdateTaskStatus(
    TaskUpdateStatus event,
    Emitter<TaskState> emit,
  ) async {
    // Verificamos si tenemos una lista cargada para hacer la magia visual
    if (state is TasksDisplaySuccess) {
      final stateData = state as TasksDisplaySuccess;

      final updatedTasks = stateData.tasks.map((task) {
        if (task.id == event.taskId) {
          // Reconstruimos usando TaskModel para mantener la compatibilidad
          if (task is TaskModel) {
            return task.copyWith(isCompleted: event.isCompleted);
          }
        }
        return task;
      }).toList();

      emit(TasksDisplaySuccess(updatedTasks));
    }

    // Llamada silenciosa al servidor
    final res = await _syncTaskStatus(
      SyncTaskStatusParams(
        token: event.token,
        taskId: event.taskId,
        isCompleted: event.isCompleted,
      ),
    );

    // Si falla, avisamos (pero no revertimos la UI)
    res.fold((l) => emit(TaskFailure(l.message)), (_) => null);
  }

  // ---------------------------------------------------------------------------
  // 4. BORRAR TAREA (OPTIMISTA)
  // ---------------------------------------------------------------------------
  void _onDeleteTask(TaskDelete event, Emitter<TaskState> emit) async {
    if (state is TasksDisplaySuccess) {
      final stateData = state as TasksDisplaySuccess;

      final updatedTasks = stateData.tasks
          .where((task) => task.id != event.taskId)
          .toList();

      emit(TasksDisplaySuccess(updatedTasks));
    }

    final res = await _deleteTask(
      DeleteTaskParams(taskId: event.taskId, token: event.token),
    );

    res.fold((l) => emit(TaskFailure(l.message)), (_) => null);
  }

  // ---------------------------------------------------------------------------
  // 5. MODIFICAR TAREA
  // ---------------------------------------------------------------------------
  void _onTaskEdit(TaskEdit event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final res = await _editTask(
      EditTaskParams(task: event.task, token: event.token),
    );

    res.fold((l) => emit(TaskFailure(l.message)), (r) => emit(TaskSuccess(r)));
  }
}
