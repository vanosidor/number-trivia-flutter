import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/repositories/number_trivia_repository.dart';
import '../datasources/number_trivia_local_data_source.dart';
import '../datasources/number_trivia_remote_data_source.dart';

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final NumberTriviaLocalDataSource localDataSource;
  final NumberTriviaRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  NumberTriviaRepositoryImpl(
      {@required this.localDataSource,
      @required this.remoteDataSource,
      @required this.networkInfo});

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(
      int number) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteNumberTrivia =
            await remoteDataSource.getConcreteNumberTrivia(number);
        localDataSource.cacheLastNumberTrivia(remoteNumberTrivia);
        return Right(remoteNumberTrivia);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final cachedNumberTrivia = await localDataSource.getLastNumberTrivia();
        return Right(cachedNumberTrivia);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async {
    if (await networkInfo.isConnected) {
      try {
        final randomNumberTrivia =
            await remoteDataSource.getRandomNumberTrivia();

        localDataSource.cacheLastNumberTrivia(randomNumberTrivia);
        return Right(randomNumberTrivia);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final cachedNumberTrivia = await localDataSource.getLastNumberTrivia();
        return Right(cachedNumberTrivia);
      } on Exception {
        return Left(CacheFailure());
      }
    }
  }
}
