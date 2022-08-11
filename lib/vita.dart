// ignore_for_file: invalid_use_of_protected_member

import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'main.dart';

typedef Vita = SplayTreeMap<String, Luna>;

extension VitaUtils on Vita {
  static Vita load(String text) {
    Vita vita = Vita();
    DateTime cal = DateTime.now();
    String? key;
    var dies = 0;

    for (String ln in text.split("\n"))
      if (key == null) {
        if (!ln.startsWith('@')) continue;
        var sn = split(ln, ";", 2);
        var s = sn[0].split("~");
        key = s[0].substring(1);
        vita[key] = Luna(cal, (s.length > 1) ? double.parse(s[1]) : null,
            (sn.length > 1) ? sn[1].loadVitaText() : null);
        dies = 0;
      } else {
        if (ln.isEmpty) {
          key = null;
          continue;
        }
        var sn = split(ln, ";", 2);
        var s = sn[0].split(":");
        if (s.length == 2) dies = int.parse(s[0]) - 1;
        vita[key]!.diebus[dies] = double.parse((s.length > 1) ? s[1] : s[0]);
        vita[key]!.verba[dies] = (sn.length > 1) ? sn[1].loadVitaText() : null;
        dies++;
      }
    return vita;
  }

  String dump() {
    StringBuffer sb = StringBuffer();
    forEach((k, luna) {
      sb.write("@$k");
      if (luna.defVar != null) {
        sb.write("~${luna.defVar}");
        if (luna.verbum?.trim().isNotEmpty == true)
          sb.write(";${luna.verbum!.saveVitaText()}");
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
        if (luna.verba[d]?.trim().isNotEmpty == true)
          sb.write(";${luna.verba[d]!.saveVitaText()}");
        sb.write("\n");
      }
      sb.write("\n");
    });
    return sb.toString();
  }

  void save() {
    if (kIsWeb) return;
    Fortuna.stored?.writeAsString(dump());
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

  static int selectedVar = 6;
  static String enteredVerbum = "";

  void changeVar(BuildContext c, int? i) {
    showCupertinoModalPopup(
      context: c,
      builder: (BuildContext context) {
        if (i != null && diebus.length > i && diebus[i] != null)
          selectedVar = scoreToVariabilis(diebus[i]!);
        else if (defVar != null)
          selectedVar = scoreToVariabilis(defVar!);
        else
          selectedVar = 6;

        if (i != null && verba.length > i && verba[i] != null)
          enteredVerbum = verba[i]!;
        else if (verbum != null)
          enteredVerbum = verbum!;
        else
          enteredVerbum = "";

        return AlertDialog(
          title: Text(s('variabilis') +
              ((i != null) ? "${Fortuna.luna}.${z(i + 1)}" : s('defValue'))),
          content: SizedBox(
            height: 270,
            child: Column(
              children: [
                SizedBox(
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
                    onSelectedItemChanged: (i) => selectedVar = i,
                  ),
                ),
                SizedBox(
                  height: 70,
                  // FractionallySizedBox didn't fix it!
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFEFEFEF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: TextFormField(
                        controller: TextEditingController()
                          ..text = enteredVerbum,
                        maxLines: 5,
                        textAlign: TextAlign.start,
                        keyboardType: TextInputType.text,
                        style: Fortuna.font(18, bold: true),
                        decoration: InputDecoration(
                          counterText: "",
                          border: InputBorder.none,
                        ),
                        onChanged: (s) => enteredVerbum = s,
                      ),
                    ),
                  ),
                ),
              ],
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
                  saveScore(i, variabilisToScore(selectedVar), enteredVerbum);
                Navigator.of(context).pop();
                Fortuna.shake();
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
                if (Fortuna.vita != null) saveScore(i, null, null);
                Navigator.of(context).pop();
                Fortuna.shake();
              },
            ),
          ],
        );
      },
    );
  }

  void saveScore(int? i, double? score, String? verbum) {
    if (verbum?.isEmpty == true) verbum = null;
    if (i != null) {
      diebus[i] = score;
      verba[i] = verbum;
    } else {
      defVar = score;
      this.verbum = verbum;
    }
    Fortuna.vita![Fortuna.luna] = this;
    Fortuna.vita!.save();
    Grid.id.currentState?.setState(() {});
    Panel.id.currentState?.setState(() {});
  }

  double mean() {
    final scores = <double>[];
    for (int v = 0; v < diebus.length; v++) {
      final score = this[v] ?? defVar;
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
}

String z(Object? n, [int ideal = 2]) {
  var s = n.toString();
  while (s.length < ideal) s = "0$s";
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
    for (var i = 0; i < length; i++) value += this[i];
    return value;
  }
}

Vita loadLegacyVita(String json) {
  final data = new Map<String, List<dynamic>>.from(jsonDecode(json));
  final vita = Vita();
  data.forEach((key, value) {
    List<dynamic> rawLuna = value;
    Luna newLuna = Luna(key.makeCalendar(), rawLuna.last);
    for (int d = 0; d < newLuna.length; d++) newLuna[d] = rawLuna[d];
    vita[key] = newLuna;
  });
  return vita;
}
