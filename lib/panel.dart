import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'dict.dart';

class Panel extends StatefulWidget {
  const Panel(this.l, {Key? key}) : super(key: key);
  final String l;

  @override
  PanelState createState() => PanelState();
}

class PanelState extends State<Panel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(dict[widget.l]!["appName"]!),
      ),
      body: Center(
        child: FractionallySizedBox(
          heightFactor: 0.58,
          child: TableCalendar(
            firstDay: DateTime.utc(2000, 2, 6), // birth date
            lastDay: DateTime.utc(2022, 1, 12), // tomorrow
            focusedDay: DateTime.now(),
          ),
        ),
      ),
    );
  }
}
