import 'dart:math';

import 'package:flutter/material.dart';

import 'more/page.dart';
import 'dict.dart';

class Panel extends MyPage {
  Panel(String l, {Key? key}) : super(l, "appName", TaoCalendar(l), key: key);
}

class TaoCalendar extends StatefulWidget {
  const TaoCalendar(this.l, {Key? key}) : super(key: key);
  final String l;

  @override
  State<StatefulWidget> createState() => TaoCalendarState();
}

class TaoCalendarState extends State<TaoCalendar> {
  MediaQueryData? mq;
  late double baseSize;

  @override
  void initState() {
    mq = MediaQuery.of(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    baseSize = [mq!.size.width, mq!.size.height].reduce(min);

    return Table(
      defaultColumnWidth: const FlexColumnWidth(1),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: <TableRow>[
        TableRow(
          children: <Widget>[],
        ),
      ],
    );
  }
}
