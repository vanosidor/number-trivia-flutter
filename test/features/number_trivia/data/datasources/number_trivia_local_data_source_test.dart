import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  NumberTriviaLocalDataSourceImpl localDataSource;
  MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    localDataSource = NumberTriviaLocalDataSourceImpl(
        sharedPreferences: mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    test(
        'should return numberTrivia from shared preferences then there is one in the cache',
        () async {
      //arrange
      final tNumberTriviaModel = NumberTriviaModel.fromJson(
          json.decode(fixture('trivia_cached.json')));

      when(mockSharedPreferences.get(any))
          .thenReturn(fixture('trivia_cached.json'));

      //act
      final result = await localDataSource.getLastNumberTrivia();

      // assert
      verify(mockSharedPreferences.get(CACHED_NUMBER_TRIVIA));
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw CacheException if is not cached value', () async {
      //arrange

      when(mockSharedPreferences.get(any)).thenReturn(null);

      //act
      final call = localDataSource.getLastNumberTrivia;

      // assert
      expect(call, throwsA(TypeMatcher<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(text: 'Text text', number: 1);

    test('should call SharedPreferences to cache the data', () async {
      //act
      localDataSource.cacheLastNumberTrivia(tNumberTriviaModel);

      final cachedNumberTrivia = json.encode(tNumberTriviaModel.toJson());

      //assert
      verify(mockSharedPreferences.setString(
          CACHED_NUMBER_TRIVIA, cachedNumberTrivia));
    });
  });
}
