import 'package:fpdart/fpdart.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:frontend/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend/features/auth/data/models/user_model.dart';
import 'package:frontend/features/auth/domain/entities/user.dart';
import 'package:frontend/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  // Inyectamos el DataSource en el constructor
  const AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDataSource.signUpWithEmailPassword(
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDataSource.loginWithEmailPassword(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // 1. Obtener token del almacenamiento local
      final token = localDataSource.getToken();

      if (token == null) {
        return left(Failure('User not logged in'));
      }

      // 3. Si hay token, llamar al servidor para obtener datos del usuario
      final user = await remoteDataSource.getCurrentUserData(token);

      // 4. Actualizar el token local por si acaso (opcional pero recomendable)
      localDataSource.writeToken(user.token);

      return right(user);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // Función privada auxiliar para evitar repetir código en Login y SignUp
  Future<Either<Failure, User>> _getUser(
    Future<UserModel> Function() fn,
  ) async {
    try {
      final user = await fn();
      // IMPORTANTE: Guardamos el token en local cuando la operación es exitosa
      localDataSource.writeToken(user.token);
      return right(user);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      localDataSource.logout();
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
