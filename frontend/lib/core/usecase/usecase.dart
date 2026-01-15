import 'package:fpdart/fpdart.dart';
import 'package:frontend/core/error/failures.dart';

abstract interface class UseCase<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}

// Clase helper para cuando un caso de uso no necesita parámetros
class NoParams {}
