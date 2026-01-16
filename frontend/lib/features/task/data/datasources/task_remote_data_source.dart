import 'dart:convert';
import 'package:frontend/core/error/exception.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/features/task/data/models/task_model.dart';

abstract interface class TaskRemoteDataSource {
  Future<TaskModel> uploadTask({
    required TaskModel task,
    required String token, // <--- Necesitamos el token para entrar
  });

  Future<List<TaskModel>> getTasks({required String token});
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
        body: task.toJson(), // Enviamos la tarea convertida a texto
      );

      if (response.statusCode != 200) {
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
      // 1. VERIFICAMOS LA IP
      print('📡 DATA SOURCE: URL usada -> $baseUrl/tasks');

      // 2. VERIFICAMOS EL TOKEN (IMPORTANTE)
      print('🔑 TOKEN RECIBIDO: $token');

      final response = await http
          .get(
            Uri.parse('$baseUrl/tasks'),
            headers: {
              'Content-Type': 'application/json',
              'x-auth-token': token,
            },
          )
          .timeout(const Duration(seconds: 5));

      print(
        '📡 DATA SOURCE: Respuesta recibida. Código: ${response.statusCode}',
      ); // 2
      print('📡 DATA SOURCE: Body: ${response.body}'); // 3

      if (response.statusCode != 200) {
        throw ServerException(
          jsonDecode(response.body)['error'] ?? 'Error desconocido',
        );
      }

      print('📡 DATA SOURCE: Intentando decodificar JSON...'); // 4
      final List<dynamic> resBody = jsonDecode(response.body);

      print('📡 DATA SOURCE: Mapeando a TaskModel...'); // 5
      final tasks = resBody.map((task) => TaskModel.fromMap(task)).toList();

      print(
        '📡 DATA SOURCE: Mapeo completado. Retornando ${tasks.length} tareas.',
      ); // 6
      return tasks;
    } catch (e) {
      print('🔥 DATA SOURCE ERROR CRÍTICO: $e'); // 7
      throw ServerException(e.toString());
    }
  }
}
