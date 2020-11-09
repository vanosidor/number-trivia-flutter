import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:number_trivia/features/number_trivia/presentation/widgets/widgets.dart';
import 'package:number_trivia/injection_container.dart';

class NumberTriviaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Number Trivia'),
        ),
        body: SingleChildScrollView(child: buildBody(context)));
  }

  BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
    return BlocProvider<NumberTriviaBloc>(
      create: (context) => sl(),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(height: 10),
            BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
              builder: (context, state) {
                // ignore: missing_return
                if (state is Empty) {
                  return MessageDisplay(
                    message: 'Initial',
                  );
                } else if (state is Loading) {
                  return LoadingWidget();
                } else if (state is Loaded) {
                  return TriviaDisplay(numberTrivia: state.numberTrivia);
                } else if (state is Error) {
                  return MessageDisplay(message: state.message);
                } else
                  throw UnsupportedError('Unknown state');
              },
            ),
            SizedBox(height: 20),
            TriviaControls(),
          ],
        ),
      ),
    );
  }
}
