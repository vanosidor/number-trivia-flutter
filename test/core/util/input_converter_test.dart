import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/core/util/input_converter.dart';

void main() {
  InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group('string to unsigned int', () {
    test(
        'should return an integer when the string represents as unsigned integer',
        () async {
      //arrange
      String str = '123';
      //act
      final result = inputConverter.stringToUnsignedInteger(str);
      //assert
      expect(result, equals(Right(123)));
    });

    test('should return failure if input is not integer', () async {
      //arrange
      final str = '1.0';
      //act
      final result = inputConverter.stringToUnsignedInteger(str);
      //assert
      expect(result, equals(Left(InvalidInputFailure())));
    });

    test('should return failure if input is negative', () {
      final str = '-134';
      final result = inputConverter.stringToUnsignedInteger(str);
      expect(result, equals(Left(InvalidInputFailure())));
    });
  });
}
