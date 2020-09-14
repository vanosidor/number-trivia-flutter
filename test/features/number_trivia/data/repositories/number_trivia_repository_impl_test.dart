import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/core/error/failure.dart';
import 'package:number_trivia/core/platform/network_info.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  NumberTriviaRepositoryImpl repository;
  MockRemoteDataSource mockRemoteDataSource;
  MockLocalDataSource mockLocalDataSource;
  MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();

    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('getConcreteNumberTrivia', () {
    int tNumber = 1;

    NumberTriviaModel tNumberTriviaModel =
        NumberTriviaModel(number: tNumber, text: 'Text trivia');
    NumberTrivia tNumberTrivia = tNumberTriviaModel;
    test('should check is the device is online', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      repository.getConcreteNumberTrivia(1);

      verify(mockNetworkInfo.isConnected);
    });

    void runTestsOnline(Function body) {
      group('device is online', () {
        setUp(() {
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        });

        body();
      });
    }

    void runTestsOffline(Function body) {
      group('device is offline', () {
        setUp(() {
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        });

        body();
      });
    }

    runTestsOnline(() {
      test(
          'should return remote data when call to remote data source is successful',
          () async {
        //arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => tNumberTriviaModel);

        //act

        final result = await repository.getConcreteNumberTrivia(tNumber);

        //assert

        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));

        expect(result, equals(Right(tNumberTrivia)));
      });

      test('should cache the data locally when the remote data success',
          () async {
        //arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => tNumberTriviaModel);

        //act

        final result = await repository.getConcreteNumberTrivia(tNumber);

        //assert

        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verify(mockLocalDataSource.cacheLastNumberTrivia(tNumberTrivia));

        expect(result, equals(Right(tNumberTrivia)));
      });

      test(
          'should return server failure when call to remote data source is unsuccessful',
          () async {
        //arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenThrow(ServerException());

        //act

        final result = await repository.getConcreteNumberTrivia(tNumber);

        //assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, equals(Left(ServerFailure())));
      });
    });

    runTestsOffline(() {
      test(
          'should return last locally cached data when the cached data is present',
          () async {
        //arrange
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);

        //act
        final cachedNumberTrivia =
            await repository.getConcreteNumberTrivia(tNumber);

        //assert
        verify(mockLocalDataSource.getLastNumberTrivia());
        verifyZeroInteractions(mockRemoteDataSource);

        expect(cachedNumberTrivia, equals(Right(tNumberTrivia)));
      });
      test('should return cache failure if no data present', () async {
        //arrange
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());
        //act
        final cachedNumberTrivia =
            await repository.getConcreteNumberTrivia(tNumber);

        // assert
        verify(mockLocalDataSource.getLastNumberTrivia());
        verifyZeroInteractions(mockRemoteDataSource);
        expect(cachedNumberTrivia, equals(Left(CacheFailure())));
      });
    });
  });

  group('getRandomTrivia', () {
    int tNumber = 1;

    NumberTriviaModel tNumberTriviaModel =
        NumberTriviaModel(number: tNumber, text: 'Text trivia');
    NumberTrivia tNumberTrivia = tNumberTriviaModel;
    test('should check is the device is online', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      repository.getRandomNumberTrivia();

      verify(mockNetworkInfo.isConnected);
    });

    void runTestsOnline(Function body) {
      group('device is online', () {
        setUp(() {
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        });

        body();
      });
    }

    void runTestsOffline(Function body) {
      group('device is offline', () {
        setUp(() {
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        });

        body();
      });
    }

    runTestsOnline(() {
      test(
          'should return remote data when call to remote data source is successful',
          () async {
        //arrange
        when(mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);

        //act

        final result = await repository.getRandomNumberTrivia();

        //assert

        verify(mockRemoteDataSource.getRandomNumberTrivia());

        expect(result, equals(Right(tNumberTrivia)));
      });

      test('should cache the data locally when the remote data success',
          () async {
        //arrange
        when(mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);

        //act

        final result = await repository.getRandomNumberTrivia();

        //assert

        verify(mockRemoteDataSource.getRandomNumberTrivia());
        verify(mockLocalDataSource.cacheLastNumberTrivia(tNumberTrivia));

        expect(result, equals(Right(tNumberTrivia)));
      });

      test(
          'should return server failure when call to remote data source is unsuccessful',
          () async {
        //arrange
        when(mockRemoteDataSource.getRandomNumberTrivia())
            .thenThrow(ServerException());

        //act

        final result = await repository.getRandomNumberTrivia();

        //assert
        verify(mockRemoteDataSource.getRandomNumberTrivia());
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, equals(Left(ServerFailure())));
      });
    });

    runTestsOffline(() {
      test(
          'should return last locally cached data when the cached data is present',
          () async {
        //arrange
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);

        //act
        final cachedNumberTrivia = await repository.getRandomNumberTrivia();

        //assert
        verify(mockLocalDataSource.getLastNumberTrivia());
        verifyZeroInteractions(mockRemoteDataSource);

        expect(cachedNumberTrivia, equals(Right(tNumberTrivia)));
      });
      test('should return cache failure if no data present', () async {
        //arrange
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());
        //act
        final cachedNumberTrivia = await repository.getRandomNumberTrivia();

        // assert
        verify(mockLocalDataSource.getLastNumberTrivia());
        verifyZeroInteractions(mockRemoteDataSource);
        expect(cachedNumberTrivia, equals(Left(CacheFailure())));
      });
    });
  });
}
