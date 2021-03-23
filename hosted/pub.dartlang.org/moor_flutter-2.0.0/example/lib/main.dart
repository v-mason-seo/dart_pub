import 'package:flutter/material.dart';
import 'package:moor_example/bloc.dart';
import 'widgets/homescreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() {
    return MyAppState();
  }
}

// We use this widget to set up the material app and provide an InheritedWidget that
// the rest of this simple app can then use to access the database
class MyAppState extends State<MyApp> {
  TodoAppBloc bloc;

  @override
  void initState() {
    bloc = TodoAppBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: bloc,
      child: MaterialApp(
        title: 'moor Demo',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          // use the good-looking updated material text style
          typography: Typography(
            englishLike: Typography.englishLike2018,
            dense: Typography.dense2018,
            tall: Typography.tall2018,
          ),
        ),
        home: HomeScreen(),
      ),
    );
  }
}

class BlocProvider extends InheritedWidget {
  final TodoAppBloc bloc;

  BlocProvider({@required this.bloc, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(BlocProvider oldWidget) {
    return oldWidget.bloc != bloc;
  }

  static TodoAppBloc provideBloc(BuildContext ctx) =>
      (ctx.inheritFromWidgetOfExactType(BlocProvider) as BlocProvider).bloc;
}
