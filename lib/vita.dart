// ignore_for_file: invalid_use_of_protected_member

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'main.dart';

typedef Luna = List<double?>;

typedef Vita = Map<String, Luna>;

extension VitaUtils on Vita {
  void save() {
    if (kIsWeb) return;
    Fortuna.stored?.writeAsString(jsonEncode(this));
  }

  static Vita createFromJson(String json) {
    final data = new Map<String, List<dynamic>>.from(jsonDecode(json));
    final vita = Vita();
    data.forEach((key, value) {
      List<dynamic> rawLuna = value;
      List<double?> newLuna = <double?>[];
      for (final v in rawLuna) newLuna.add(v);
      vita[key] = newLuna;
    });
    return vita;
  }
}

extension LunaUtils on List<double?> {
  static int selectedVar = 6;

  double? getDefault() => this[length - 1];

  void setDefault(d) {
    this[length - 1] = d;
  }

  void changeVar(BuildContext c, int i) {
    showCupertinoModalPopup(
        context: c,
        builder: (BuildContext context) {
          int? newVar;
          if (this[i] != null) newVar = scoreToVariabilis(this[i]!);
          if (this[Fortuna.calendar.defPos()] != null)
            newVar = scoreToVariabilis(this[Fortuna.calendar.defPos()]!);
          if (newVar == null) newVar = 6;
          selectedVar = newVar;

          return AlertDialog(
            title: Text(s('variabilis') +
                ((i != Fortuna.calendar.defPos())
                    ? "${Fortuna.luna}.${z(i + 1)}"
                    : s('defValue'))),
            content: SizedBox(
              height: 200,
              child: CupertinoPicker(
                backgroundColor: Colors.transparent,
                scrollController:
                    FixedExtentScrollController(initialItem: selectedVar),
                useMagnifier: true,
                magnification: 2,
                squeeze: 0.7,
                children: [
                  for (var i = 0; i <= 12; i++)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        "${variabilisToScore(i).showScore()}",
                        style: Fortuna.font(18, bold: true),
                      ),
                    )
                ],
                itemExtent: 30,
                onSelectedItemChanged: (i) {
                  selectedVar = i;
                },
              ),
            ),
            actions: <MaterialButton>[
              MaterialButton(
                child: Text(
                  s('save'),
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                onPressed: () {
                  if (Fortuna.vita != null)
                    saveScore(i, variabilisToScore(selectedVar));
                  Navigator.of(context).pop();
                },
              ),
              MaterialButton(
                child: Text(
                  s('cancel'),
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              MaterialButton(
                child: Text(
                  s('clear'),
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                onPressed: () {
                  if (Fortuna.vita != null) saveScore(i, null);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void saveScore(int i, double? score) {
    this[i] = score;
    Fortuna.vita!.save();
    Grid.id.currentState?.setState(() {});
    Panel.id.currentState?.setState(() {});
  }

  double mean(DateTime cal) {
    final scores = <double>[];
    for (var v = 0; v <= cal.lunaMaxima(); v++) {
      final score = this[v] ?? this[cal.defPos()];
      if (score != null) scores.add(score);
    }
    return (scores.length == 0) ? 0 : (scores.sum() / scores.length);
  }
}

extension CalendarKey on DateTime {
  // Months are in 1..12 in Dart.

  String toKey() {
    return "${z(year, 4)}.${z(month)}";
  }

  int daysInMonth() => DateTimeRange(
          start: DateTime(year, month, 1), end: DateTime(year, month + 1))
      .duration
      .inDays;

  int lunaMaxima() => daysInMonth();

  int defPos() => 31;
}

String z(Object? n, [int ideal = 2]) {
  var s = n.toString();
  while (s.length < ideal) s = "0$s";
  return s;
}

DateTime makeCalendar(String luna) {
  final spl = luna.split('.');
  return DateTime(int.parse(spl[0]), int.parse(spl[1]) - 1, 1);
}

extension ScoreUtils on double? {
  // ignore: non_constant_identifier_names
  static double MAX_RANGE = 3.0;

  String showScore() => (this != 0) ? (this?.toString() ?? "_") : "0";
}

int scoreToVariabilis(double score) => (-(score * 2.0) + 6.0).toInt();

double variabilisToScore(int variabilis) =>
    -(variabilis.toDouble() - 6.0) / 2.0;

extension Sum on List<double> {
  double sum() {
    double value = 0.0;
    for (var i = 0; i < length; i++) value += this[i];
    return value;
  }
}
