import 'dart:convert';
import 'package:frontend/core/error/exception.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/features/task/data/models/task_model.dart';

abstract interface class TaskRemoteDataSource {
  Future<TaskModel> uploadTask({
    required TaskModel task,
    required String token,
  });

  Future<List<TaskModel>> getTasks({required String token});

  Future<void> syncTaskStatus({
    required String token,
    required String taskId,
    required bool isCompleted,
  });

  Future<void> deleteTask({required String taskId, required String token});
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final String baseUrl = 'http://127.0.0.1:8000';

  @override
  Future<TaskModel> uploadTask({
    required TaskModel task,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: task.toJson(),
      );

      if (response.statusCode != 201) {
        throw ServerException(
          jsonDecode(response.body)['error'] ?? 'Error desconocido',
        );
      }

      return TaskModel.fromJson(response.body);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TaskModel>> getTasks({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      if (response.statusCode != 200) {
        throw ServerException(
          jsonDecode(response.body)['error'] ?? 'Error desconocido',
        );
      }

      final List<dynamic> resBody = jsonDecode(response.body);

      final tasks = resBody.map((task) => TaskModel.fromMap(task)).toList();

      return tasks;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> syncTaskStatus({
    required String token,
    required String taskId,
    required bool isCompleted,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks/sync'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({'id': taskId, 'isCompleted': isCompleted}),
      );
      if (response.statusCode != 200) {
        throw ServerException(jsonDecode(response.body)['error']);
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteTask({
    required String taskId,
    required String token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tasks/$taskId'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );
      if (response.statusCode != 200) {
        throw ServerException(jsonDecode(response.body)['error']);
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
