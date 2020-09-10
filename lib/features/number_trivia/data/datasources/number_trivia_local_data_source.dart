import 'dart:ffi';

import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';

abstract class NumberTriviaLocalDataSource {
  ///Throws [CacheException] if no cached data found
    Future<NumberTriviaModel> getLastNumberTrivia();
    Future<void> cacheLastNumberTrivia(NumberTriviaModel numberTrivia);
}