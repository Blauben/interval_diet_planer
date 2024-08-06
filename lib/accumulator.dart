import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';

class AlarmWidget extends StatelessWidget {
  const AlarmWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var highCard = SizedBox(
      height: 0.3 * MediaQuery.of(context).size.height,
      width: 0.8 * MediaQuery.of(context).size.width,
      child: Card(
        color: Colors.lightBlue,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                  style: TextStyle(color: Colors.white, fontSize: 30),
                  "Letzte Mahlzeit:"),
              Text(
                style: const TextStyle(fontSize: 50.0),
                "${appState.time.hour.toString().padLeft(2, "0")}:${appState.time.minute.toString().padLeft(2, "0")} Uhr",
              ),
              ElevatedButton(
                onPressed: () async => appState.setTime(await showTimePicker(
                        context: context, initialTime: TimeOfDay.now()) ??
                    TimeOfDay.now()),
                child:
                    const Text(style: TextStyle(fontSize: 20), "Zeit eingeben"),
              ),
            ]),
      ),
    );

    var middle = [
      Container(
        padding: EdgeInsets.only(
            left: 0.1 * MediaQuery.of(context).size.width,
            right: 0.05 * MediaQuery.of(context).size.width),
        child: Text(
            style: const TextStyle(fontSize: 20.0),
            "Zeit zwischen Mahlzeiten:\n${appState.delta.hour} Stunden und ${appState.delta.minute} Minuten!"),
      ),
      ElevatedButton(
        onPressed: () async => appState.setDelta(await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 12, minute: 0),
        ) ?? const TimeOfDay(hour: 12, minute: 0)),
        child: const Text(style: TextStyle(fontSize: 20), "Ändern"),
      )
    ];

    var lowCard = Card(
      color: Colors.lightBlueAccent[100],
      child: Container(
        margin: EdgeInsets.all(0.05 * MediaQuery.of(context).size.width),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 30.0,
              color: Colors.black,
            ),
            children: <TextSpan>[
              const TextSpan(text: "Nächste Mahlzeit ab "),
              TextSpan(
                  text:
                      "${(((appState.time.hour + appState.delta.hour + (appState.time.minute + appState.delta.minute) / 60).floor()) % 24).toString().padLeft(2, "0")}:${((appState.time.minute + appState.delta.minute) % 60).toString().padLeft(2, "0")}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: " Uhr planen!"),
            ],
          ),
        ),
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(
          vertical: 0.05 * MediaQuery.of(context).size.height,
          horizontal: 0.05 * MediaQuery.of(context).size.width),
      child: Column(
        children: [
          highCard,
          SizedBox(height: 0.05 * MediaQuery.of(context).size.height),
          ...middle,
          SizedBox(height: 0.05 * MediaQuery.of(context).size.height),
          lowCard,
        ],
      ),
    );
  }
}
