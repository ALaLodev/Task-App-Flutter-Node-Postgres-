import 'dart:convert';
import 'package:frontend/features/auth/data/models/user_model.dart';
import 'package:http/http.dart' as http;

abstract interface class AuthRemoteDataSource {
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<UserModel> getCurrentUserData(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final String baseUrl = 'http://127.0.0.1:8000';

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Construimos la llamada
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      //print('STATUS CODE: ${response.statusCode}');
      //print('BODY: ${response.body}');

      if (response.statusCode != 200) {
        final responseBody = jsonDecode(response.body);
        throw Exception(
          responseBody['msg'] ??
              responseBody['error'] ??
              'Error desconocido del servidor',
        );
      }

      return UserModel.fromJson(response.body);
    } catch (e) {
      //print('❌ ERROR REAL: $e');
      throw Exception(e.toString());
    }
  }

  @override
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['msg']);
      }

      return UserModel.fromJson(response.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<UserModel> getCurrentUserData(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token, //Añadimos el token a la cabecera
        },
      );

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['msg']);
      }

      return UserModel.fromJson(response.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
