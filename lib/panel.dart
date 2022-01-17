import 'package:flutter/material.dart';

import 'data/conf.dart';
import 'dict.dart';

class Panel extends StatelessWidget {
  const Panel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(dict[Config.lang]!["appName"]!),
      ),
      body: const TaoCalendar(),
    );
  }
}

class TaoCalendar extends StatefulWidget {
  const TaoCalendar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TaoCalendarState();
}

class TaoCalendarState extends State<TaoCalendar> {
  /*@override
  void initState() {
    super.initState();
  }*/

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now(); // .subtract(const Duration(days: 106))
    List<DayCell> days = [];

    DateTime cur = DateTime.utc(now.year, now.month, 1, 0, 0, 0, 0, 0);
    int dist = 0, i = Config.firstDayOfWeek;
    while (i != cur.weekday) {
      if (i > 7)
        i = 1;
      else {
        i++;
        dist++;
      }
    }
    for (var i = dist; i > 0; i--) {
      days.add(DayCell(cur.subtract(Duration(days: i)), shadowed: true));
    }
    while (cur.month == now.month) {
      days.add(DayCell(cur));
      cur = cur.add(const Duration(days: 1));
    }
    for (var i = 0; i <= (days.length % 7); i++) {
      days.add(DayCell(cur.add(Duration(days: i)), shadowed: true));
    }

    List<Widget> rows = [];
    for (int r = 0; r < days.length / 7; r++) {
      List<Widget> cells = [];
      for (int c = 0; c < 7; c++) {
        cells.add(Expanded(
          child: InkWell(
            child: Expanded(
              child: Text(
                days[(r * 7) + c].date.day.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 19,
                ),
              ),
            ),
            onTap: () => {},
          ),
        ));
      }
      rows.add(Expanded(child: Row(children: cells)));
    }
    return Column(children: rows);
  }
}

class DayCell {
  DayCell(this.date, {this.shadowed = false});

  DateTime date;
  bool shadowed;
}
