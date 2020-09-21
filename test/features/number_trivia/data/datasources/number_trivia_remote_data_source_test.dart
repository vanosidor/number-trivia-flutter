import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:matcher/matcher.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  MockHttpClient mockHttpClient;
  NumberTriviaRemoteDataSourceImpl remoteDataSource;

  setUp(() {
    mockHttpClient = MockHttpClient();
    remoteDataSource =
        NumberTriviaRemoteDataSourceImpl(httpClient: mockHttpClient);
  });

  void setUpMockHttpClientSuccess200() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientError404() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
        'should perform a GET request on the URL with number being the endpoint with application/json',
        () async {
      //arrange
      setUpMockHttpClientSuccess200();

      //act
      remoteDataSource.getConcreteNumberTrivia(tNumber);

      //assert
      verify(mockHttpClient.get('http://numbersapi.com/$tNumber',
          headers: {'Content-Type': 'application.json'}));
    });

    test('should return NumberTrivia if the response code is 200 (success)',
        () async {
      //arrange
      setUpMockHttpClientSuccess200();

      //act
      final result = await remoteDataSource.getConcreteNumberTrivia(tNumber);

      //assert
      // verify(remoteDataSource.getConcreteNumberTrivia(tNumber));
      expect(result, equals(tNumberTriviaModel));
    });

    test('should thrown ServerException if the response code 404 or other',
        () async {
      //arrange
      setUpMockHttpClientError404();

      //act
      final call = remoteDataSource.getConcreteNumberTrivia(tNumber);

      //assert
      expect(call, throwsA(TypeMatcher<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
        'should perform a GET request on the URL random number being the endpoint with application/json',
        () async {
      //arrange
      setUpMockHttpClientSuccess200();
      //act
      remoteDataSource.getRandomNumberTrivia();

      //assert
      verify(mockHttpClient.get('http://numbersapi.com/random/trivia',
          headers: {'Content-Type': 'application.json'}));
    });

    test('should return NumberTrivia if the response code is 200 (success)',
        () async {
      //arrange
      setUpMockHttpClientSuccess200();

      //act
      final result = await remoteDataSource.getRandomNumberTrivia();

      //assert
      // verify(remoteDataSource.getConcreteNumberTrivia(tNumber));
      expect(result, equals(tNumberTriviaModel));
    });

    test('should thrown ServerException if the response code 404 or other',
        () async {
      //arrange
      setUpMockHttpClientError404();

      //act
      final call = remoteDataSource.getRandomNumberTrivia();

      //assert
      expect(call, throwsA(TypeMatcher<ServerException>()));
    });
  });
}
