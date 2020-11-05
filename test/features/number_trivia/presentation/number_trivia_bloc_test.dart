import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/failure.dart';
import 'package:number_trivia/core/usecases/usecase.dart';
import 'package:number_trivia/core/util/input_converter.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  NumberTriviaBloc bloc;
  MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
        concrete: mockGetConcreteNumberTrivia,
        random: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter);
  });

  test('initial state should be empty', () async {
    expect(bloc.state, equals(Empty()));
  });

  group('getTrivia for concrete number', () {
    final tNumberString = '1';
    final tNumberParsed = 1;
    final tNumberTrivia = NumberTrivia(text: 'testTrivia', number: 1);

    void setupInputConverterSuccess() {
      when(mockInputConverter.stringToUnsignedInteger(any))
          .thenReturn(Right(tNumberParsed));
    }

    void setupGetConcreteNumberTriviaSuccess() {
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));
    }

    blocTest(
      'should emits [Error] when the input is invalid',
      build: () {
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Left(InvalidInputFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
      expect: [Error(message: NUMBER_FAILURE_MESSAGE)],
    );

    test(
        'should get data from the concrete use case '
        'and call input converter to validate the string to an unsigned integer',
        () async {
      setupInputConverterSuccess();

      setupGetConcreteNumberTriviaSuccess();

      bloc.add(GetTriviaForConcreteNumber(tNumberString));

      await untilCalled(mockGetConcreteNumberTrivia(any));

      verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
      verify(mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
    });

    blocTest('should emit [Loading, Loaded] when data is gotten successfully',
        build: () {
          setupInputConverterSuccess();
          setupGetConcreteNumberTriviaSuccess();
          return bloc;
        },
        act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
        expect: [Loading(), Loaded(numberTrivia: tNumberTrivia)]);

    blocTest('should emit [Loading, Error] when get an error',
        build: () {
          setupInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => Left(ServerFailure()));
          return bloc;
        },
        act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
        expect: [Loading(), Error(message: SERVER_FAILURE_MESSAGE)]);

    blocTest('should emit [Loading, Error] with a proper message of error',
        build: () {
          setupInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => Left(CacheFailure()));
          return bloc;
        },
        act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
        expect: [Loading(), Error(message: CACHE_FAILURE_MESSAGE)]);
  });

  group('getRandomTrivia', () {
    final tNumberTrivia = NumberTrivia(text: 'testTrivia', number: 1);
    final tNoParams = NoParams();

    void setupGetRandomNumberTriviaSuccess() {
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));
    }

    test('should get data from the random use case', () async {
      setupGetRandomNumberTriviaSuccess();

      bloc.add(GetTriviaForRandomNumber());

      await untilCalled(mockGetRandomNumberTrivia(any));

      verify(mockGetRandomNumberTrivia(tNoParams));
    });

    blocTest('should emit [Loading, Loaded] when data is gotten successfully',
        build: () {
          setupGetRandomNumberTriviaSuccess();
          return bloc;
        },
        act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
        expect: [Loading(), Loaded(numberTrivia: tNumberTrivia)]);

    blocTest('should emit [Loading, Error] when get an error',
        build: () {
          when(mockGetRandomNumberTrivia(any))
              .thenAnswer((_) async => Left(ServerFailure()));
          return bloc;
        },
        act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
        expect: [Loading(), Error(message: SERVER_FAILURE_MESSAGE)]);

    blocTest('should emit [Loading, Error] with a proper message of error',
        build: () {
          when(mockGetRandomNumberTrivia(any))
              .thenAnswer((_) async => Left(CacheFailure()));
          return bloc;
        },
        act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
        expect: [Loading(), Error(message: CACHE_FAILURE_MESSAGE)]);
  });
}
