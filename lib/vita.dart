import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

typedef Luna = List<double?>;

typedef Vita = Map<String, Luna>;

extension VitaUtils on Vita {
  void save(File? stored) {
    stored?.writeAsString(jsonEncode(this));
  }
}

extension LunaUtils on List<double?> {
  double? getDefault() => this[length - 1];

  void setDefault(d) {
    this[length - 1] = d;
  }

  void changeVar(int i) {
    // TODO
  }
}

extension ScoreUtils on double? {
  String showScore() => (this != 0) ? (this?.toString() ?? "_") : "0";
}

String z(Object? n, [int ideal = 2]) {
  var s = n.toString();
  while (s.length < ideal) s = "0$s";
  return s;
}

// Months are in 1..12 in Dart.
extension CalendarKey on DateTime {
  String toKey() {
    return "${z(year, 4)}.${z(month)}";
  }

  int daysInMonth() => DateTimeRange(
          start: DateTime(year, month, 1), end: DateTime(year, month + 1))
      .duration
      .inDays;

  int lunaMaxima() => daysInMonth();

  int defPos() => 32;
}
