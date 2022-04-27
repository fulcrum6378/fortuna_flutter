// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'conf.dart';
import 'dict.dart';

void main() => runApp(const Fortuna());

class Fortuna extends StatelessWidget {
  const Fortuna({Key? key}) : super(key: key);

  static const CP = Color(0xFF4CAF50);
  static const CPD = Color(0xFF034C06);
  static const CS = Color(0xFFF44336);
  static const CSD = Color(0xFF670D06);

  bool night() =>
      WidgetsBinding.instance?.window.platformBrightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = !night()
        ? ThemeData(
            primaryColor: CP,
            colorScheme: ThemeData().colorScheme.copyWith(secondary: CS),
            textTheme:
                const TextTheme(bodyText2: TextStyle(color: Color(0xFF777777))),
            scaffoldBackgroundColor: Colors.white,
          )
        : ThemeData(
            primaryColor: CPD,
            colorScheme: ThemeData.dark().colorScheme.copyWith(secondary: CSD),
            textTheme:
                const TextTheme(bodyText2: TextStyle(color: Color(0xFFFFFFFF))),
            scaffoldBackgroundColor: Colors.black,
          );
    // TODO: These values do NOT change when system night mode is changed!

    return MaterialApp(
      title: dict[Config.lang]!["appName"]!,
      theme: theme, //themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: theme.primaryColor,
            systemNavigationBarColor: theme.primaryColor,
          ),
          toolbarHeight: 60,
          backgroundColor: theme.primaryColor,
          title: Text(
            dict[Config.lang]!["appName"]!,
            style: const TextStyle(
              fontFamily: 'MorrisRoman',
              fontSize: 28,
            ),
          ),
        ),
        drawer: Drawer(
          backgroundColor: theme.primaryColor,
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: <ListTile>[
              ListTile(),
            ],
          ),
        ),
        body: const TaoCalendar(),
      ),
    );
  }
}

class TaoCalendar extends StatefulWidget {
  const TaoCalendar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TaoCalendarState();
}

class TaoCalendarState extends State<TaoCalendar> {
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    List<int> days = [];

    for (var i = 0; i < 29; i++) {
      days.add(i);
    }

    return GridView.count(
      crossAxisCount: 5,
      children: days
          .map((i) => InkWell(
                onTap: () {},
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      romanNumbers[i],
                      style: const TextStyle(
                        fontFamily: 'Quattrocento',
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "0",
                      style: const TextStyle(
                        fontFamily: 'Quattrocento',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
