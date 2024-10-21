import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

typedef Vita = SplayTreeMap<String, Luna>;

class VitaRepo {
  Vita? vita;
  File? stored;

  void parse(String text) {
    String? key;
    int dies = 0;

    for (String ln in text.split("\n")) {
      if (key == null) {
        if (!ln.startsWith('@')) continue;
        var sn = split(ln, ";", 2);
        var s = sn[0].split("~");
        key = s[0].substring(1);
        var splitKey = key.split(".");
        vita![key] = Luna(
          DateTime(int.parse(splitKey[0]), int.parse(splitKey[1])),
          (s.length > 1) ? double.parse(s[1]) : null,
          (sn.length > 1) ? sn[1].loadVitaText() : null,
        );
        dies = 0;
      } else {
        if (ln.isEmpty) {
          key = null;
          continue;
        }
        var sn = split(ln, ";", 2);
        var s = sn[0].split(":");
        if (s.length == 2) dies = int.parse(s[0]) - 1;
        vita![key]!.diebus[dies] = double.parse((s.length > 1) ? s[1] : s[0]);
        vita![key]!.verba[dies] = (sn.length > 1) ? sn[1].loadVitaText() : null;
        dies++;
      }
    }
  }

  String dump() {
    if (vita == null) return '';

    StringBuffer sb = StringBuffer();
    vita!.forEach((k, luna) {
      sb.write("@$k");
      if (luna.defVar != null) {
        sb.write("~${luna.defVar}");
        if (luna.verbum?.trim().isNotEmpty == true) {
          sb.write(";${luna.verbum!.saveVitaText()}");
        }
      }
      sb.write("\n");
      var skipped = false;
      for (int d = 0; d < luna.diebus.length; d++) {
        if (luna.diebus[d] == null) {
          skipped = true;
          continue;
        }
        if (skipped) {
          sb.write("${d + 1}:");
          skipped = false;
        }
        sb.write(luna.diebus[d]);
        if (luna.verba[d]?.trim().isNotEmpty == true) {
          sb.write(";${luna.verba[d]!.saveVitaText()}");
        }
        sb.write("\n");
      }
      sb.write("\n");
    });
    return sb.toString();
  }

  Future<void> load() async {
    vita ??= Vita();
    if (!kIsWeb) {
      Directory dir = await getApplicationSupportDirectory();
      stored = File('${dir.path}/fortuna.vita');
      bool? exists = await stored?.exists();
      if (exists == true) {
        final String data = await stored!.readAsString();
        parse(data);
      } else {
        save();
      }
    }
  }

  void import(Uint8List data) {
    vita = Vita();
    parse(String.fromCharCodes(data));
    save();
  }

  void save() {
    if (kIsWeb) return;
    stored?.writeAsString(dump());
  }

  Luna get(String key, DateTime calendar) {
    if (vita![key] == null) {
      vita![key] = Luna(calendar);
    }
    return vita![key]!;
  }

  void set(String key, Luna luna) {
    vita![key] = luna;
    save();
  }
}

class Luna {
  late List<double?> diebus;
  late List<String?> verba;
  double? defVar;
  String? verbum;

  Luna(DateTime cal, [double? defVar, String? verbum]) {
    int max = cal.lunaMaxima();
    diebus = List<double?>.filled(max, null);
    verba = List<String?>.filled(max, null);
  }

  get length => diebus.length;

  operator [](int index) => diebus[index];

  operator []=(int index, double? value) => diebus[index] = value;

  double mean() {
    final scores = <double>[];
    for (int v = 0; v < diebus.length; v++) {
      final score = this[v] ?? defVar;
      if (score != null) scores.add(score);
    }
    return (scores.isEmpty) ? 0 : (scores.sum() / scores.length);
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
}

String z(Object? n, [int ideal = 2]) {
  var s = n.toString();
  while (s.length < ideal) {
    s = "0$s";
  }
  return s;
}

extension StringUtils on String {
  DateTime makeCalendar() {
    final spl = this.split('.');
    return DateTime(int.parse(spl[0]), int.parse(spl[1]) - 1, 1);
  }

  String loadVitaText() => replaceAll("\\n", "\n");

  String saveVitaText() => replaceAll("\n", "\\n");
}

List<String> split(String string, String pattern, [int limit = 0]) {
  var result = <String>[];
  if (pattern.isEmpty) {
    result.add(string);
    return result;
  }
  while (true) {
    var index = string.indexOf(pattern, 0);
    if (index == -1 || (limit > 0 && result.length >= limit)) {
      result.add(string);
      break;
    }
    result.add(string.substring(0, index));
    string = string.substring(index + pattern.length);
  }
  return result;
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
    for (var i = 0; i < length; i++) {
      value += this[i];
    }
    return value;
  }
}
