import "dart:collection";
import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:path_provider/path_provider.dart";

/// Representation of the VITA file type as [SplayTreeMap]<String, Luna>
///
/// We need the whole Vita loaded on startup for search and statistics;
/// so we put the whole data in a single file.
class Vita {
  SplayTreeMap<String, Luna>? vita;
  File? stored;

  /// Loads the Vita data from [Vita.stored].
  Future<void> load() async {
    vita ??= SplayTreeMap<String, Luna>();
    if (!kIsWeb) {
      Directory dir = await getApplicationSupportDirectory();
      stored = File("${dir.path}/fortuna.vita");
      bool? exists = await stored?.exists();
      if (exists == true) {
        final String data = await stored!.readAsString();
        loads(data);
      } else {
        save();
      }
    }
  }

  /// Loads the Vita data from a given string [text].
  void loads(String text) {
    String? key;
    int dies = 0;

    for (String ln in text.split("\n")) {
      if (key == null) {
        if (!ln.startsWith("@")) continue;
        var sn = split(ln, ";", 3);
        var s = sn[0].split("~");
        key = s[0].substring(1);
        var splitKey = key.split(".");
        vita![key] = Luna(
          DateTime(int.parse(splitKey[0]), int.parse(splitKey[1])),
          (s.length > 1) ? double.parse(s[1]) : null,
          (sn.length > 1 && sn[1].isNotEmpty) ? sn[1] : null,
          (sn.length > 2) ? sn[2].loadVitaText() : null,
        );
        dies = 0;
      } else {
        if (ln.isEmpty) {
          key = null;
          continue;
        }
        var sn = split(ln, ";", 3);
        var s = sn[0].split(":");
        if (s.length == 2) dies = int.parse(s[0]) - 1;
        vita![key]!.diebus[dies] = double.parse((s.length > 1) ? s[1] : s[0]);
        vita![key]!.emojis[dies] =
            (sn.length > 1 && sn[1].isNotEmpty) ? sn[1] : null;
        vita![key]!.verba[dies] = (sn.length > 2) ? sn[2].loadVitaText() : null;
        dies++;
      }
    }
  }

  /// Dumps Vita data into a string to be written in a *.vita file.
  String dump() {
    StringBuffer sb = StringBuffer();
    bool hasVerbum = false;
    vita!.forEach((k, luna) {
      sb.write("@$k");
      if (luna.defVar != null) {
        sb.write("~${luna.defVar!.writeScore()}");
        hasVerbum = luna.verbum?.trim().isNotEmpty == true;
        if (luna.emoji?.isNotEmpty == true) {
          sb.write(";${luna.emoji}");
        } else if (hasVerbum) {
          sb.write(";");
        }
        if (hasVerbum) {
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
        hasVerbum = luna.verba[d]?.trim().isNotEmpty == true;
        if (luna.emojis[d]?.isNotEmpty == true) {
          sb.write(";${luna.emojis[d]!}");
        } else if (hasVerbum) {
          sb.write(";");
        }
        if (hasVerbum) {
          sb.write(";${luna.verba[d]!.saveVitaText()}");
        }
        sb.write("\n");
      }
      sb.write("\n");
    });
    return sb.toString();
  }

  /// Saves Vita data in [Vita.stored].
  void save() {
    if (kIsWeb) return;
    stored?.writeAsString(dump());
  }

  /// Replaces the Vita data.
  void import(Uint8List data) {
    vita = SplayTreeMap<String, Luna>();
    loads(String.fromCharCodes(data));
    save();
  }

  /// Reforms the Vita data and dumps it to be exported.
  String export() {
    reform();
    return dump();
  }

  /// Removes the empty entries.
  void reform() {
    List<String> removal = [];
    bool someNull;
    vita!.forEach((k, luna) {
      someNull = false;
      for (var e in luna.diebus) {
        if (e != null) someNull = true;
      }
      if (!someNull) removal.add(k);
    });
    for (var k in removal) {
      vita!.remove(k);
    }
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

/// Subset of [Vita] for managing months.
class Luna {
  double? defVar;
  String? emoji;
  String? verbum;
  late List<double?> diebus;
  late List<String?> emojis;
  late List<String?> verba;

  Luna(DateTime cal, [this.defVar, this.emoji, this.verbum]) {
    int max = cal.lunaMaxima();
    diebus = List<double?>.filled(max, null);
    emojis = List<String?>.filled(max, null);
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
    final spl = this.split(".");
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

extension ScoreUtils on double {
  // ignore: non_constant_identifier_names
  static double MAX_RANGE = 3.0;

  String writeScore() => (this % 1.0 == 0.0) ? toInt().toString() : toString();
}

extension ScoreNullableUtils on double? {
  String showScore() => (this != 0.0) ? (this?.toString() ?? "_") : "0";
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
