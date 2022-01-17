import 'package:flutter/material.dart';

import 'data/conf.dart';
import 'dict.dart';
import 'intro.dart';
import 'panel.dart';

// adb connect 192.168.1.20:

void main() => runApp(const Fortuna());

class Fortuna extends StatelessWidget {
  const Fortuna({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: https://docs.flutter.dev/cookbook/persistence/sqlite

    return MaterialApp(
      title: dict[Config.lang]!["appName"]!,
      theme: ThemeData(
        primarySwatch: Colors.green, // 4CAF50
        secondaryHeaderColor: Colors.red, // F44336
      ),
      home: const Pager(),
    );
  }
}

class Pager extends StatefulWidget {
  const Pager({Key? key}) : super(key: key);

  @override
  PagerState createState() => PagerState();
}

class PagerState extends State<Pager> {
  var page = 1;

  @override
  Widget build(BuildContext context) {
    switch (page) {
      case 0:
        return const Intro();
      default:
        return const Panel();
    }
  }
}
