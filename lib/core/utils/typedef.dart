import 'package:dartz/dartz.dart';

import '../errors/failures.dart';
import '../network/network_info.dart'; // Ensure you have this import

typedef ResultFuture<T> = Future<Either<Failure, T>>;

typedef ResultFutureV2<T> = Future<Either<FailureV2, T>>;

typedef ResultVoid = ResultFuture<Null>;

typedef DataMap = Map<String, dynamic>;

