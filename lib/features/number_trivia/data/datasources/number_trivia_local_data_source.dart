import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class NumberTriviaLocalDataSource {
  ///Throws [CacheException] if no cached data found
  Future<NumberTriviaModel> getLastNumberTrivia();

  Future<void> cacheLastNumberTrivia(NumberTriviaModel numberTrivia);
}

const CACHED_NUMBER_TRIVIA = 'CACHED_NUMBER_TRIVIA';

class NumberTriviaLocalDataSourceImpl implements NumberTriviaLocalDataSource {
  final SharedPreferences sharedPreferences;

  NumberTriviaLocalDataSourceImpl({@required this.sharedPreferences});

  @override
  Future<NumberTriviaModel> getLastNumberTrivia() {
    final jsonString = sharedPreferences.get(CACHED_NUMBER_TRIVIA);
    if (jsonString != null)
      return Future.value(NumberTriviaModel.fromJson(json.decode(jsonString)));
    else
      throw CacheException();
  }

  @override
  Future<void> cacheLastNumberTrivia(NumberTriviaModel numberTrivia) {
    final jsonString = json.encode(numberTrivia.toJson());
    return sharedPreferences.setString(CACHED_NUMBER_TRIVIA, jsonString);
  }
}
