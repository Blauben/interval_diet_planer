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
      builder: (context, child) =>
          MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child ?? Container()
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
          leading: Builder(builder: (context) {
            return IconButton(icon: const Icon(Icons.menu),
                onPressed: Scaffold.of(context).openDrawer);
          },),
          toolbarHeight: 80,
        ),
          drawer: Drawer(child: ListView(
            children: const [
              DrawerHeader(child: Center(child: Text("Menü", style: TextStyle(fontSize: 24)))),
              AboutListTile(aboutBoxChildren: [Text("""

Copyright 2024 Ben Frauenknecht

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
""",)],),
          ],),),
        body: const Center(child: AlarmWidget()),
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
    return TimeOfDay(hour: int.parse(tuple.first), minute: int.parse(tuple.last));
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
