import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'accumulator.dart';

void main() {
  runApp(const RootRestorationScope(restorationId: "root", child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interval Fasten',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.lightBlue,
            iconTheme: IconThemeData(color: Colors.white, size: 30),
            centerTitle: true,
            elevation: 15,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 30)),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<StatefulWidget> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with RestorationMixin {
  final RestorableAppState _restorableAppState = RestorableAppState();

  @override
  String get restorationId => 'time';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_restorableAppState, 'time');
  }

  @override
  void dispose() {
    _restorableAppState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>.value(
      value: _restorableAppState.value,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Intervall Fasten"),
          leading: const Icon(Icons.timer),
          toolbarHeight: 80,
        ),
        body: const AlarmWidget(),
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  TimeOfDay time = TimeOfDay.now();
  TimeOfDay delta = const TimeOfDay(hour: 12, minute: 00);

  AppState() {
    loadAcc();
  }

  String timeOfDayToString(TimeOfDay time) {
    return "${time.hour};${time.minute}";
  }

  TimeOfDay stringToTimeOfDay(String timeString) {
    List<String> tuple = timeString.split(";");
    return TimeOfDay(hour: tuple.first as int, minute: tuple.last as int);
  }

  void loadAcc() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    time = prefs.getString("time") != null
        ? stringToTimeOfDay(prefs.getString("time")!)
        : time;
    delta = prefs.getString("delta") != null
        ? stringToTimeOfDay(prefs.getString("delta")!)
        : delta;
    notifyListeners();
  }

  void setTime(TimeOfDay time) async {
    this.time = time;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("time", timeOfDayToString(time));
    notifyListeners();
  }

  void setDelta(TimeOfDay delta) async {
    this.delta = delta;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("delta", timeOfDayToString(delta));
    notifyListeners();
  }
}

class Primitive {
  TimeOfDay time;
  TimeOfDay delta;

  Primitive(this.time, this.delta);
}

class RestorableAppState extends RestorableChangeNotifier<AppState> {
  @override
  AppState createDefaultValue() {
    return AppState();
  }

  @override
  AppState fromPrimitives(Object? data) {
    var state = AppState();
    Primitive primitive = data as Primitive;
    state.time = primitive.time;
    state.delta = primitive.delta;
    return state;
  }

  @override
  Object? toPrimitives() {
    return Primitive(value.time, value.delta);
  }
}
