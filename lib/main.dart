import 'package:flutter/material.dart';

import 'dict.dart';
import 'intro.dart';

// adb connect 192.168.1.20:

void main() => runApp(const Fortuna());

class Fortuna extends StatelessWidget {
  const Fortuna({Key? key}) : super(key: key);
  final String l = "en";

  @override
  Widget build(BuildContext context) {
    // TODO: https://docs.flutter.dev/cookbook/persistence/sqlite

    return MaterialApp(
        title: dict[l]!["appName"]!,
        theme: ThemeData(primarySwatch: Colors.blue),
        // TODO: MAKE IT CONDITIONAL BETWEEN INTRO AND HOME
        home: Intro(l));
  }
}
