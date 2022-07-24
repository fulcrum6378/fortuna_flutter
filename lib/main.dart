// ignore_for_file: invalid_use_of_protected_member

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:format/format.dart';
import 'package:jiffy/jiffy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dict.dart';
import 'numerals.dart';
import 'vita.dart';

void main() {
  runApp(MaterialApp(
    title: s('appName'),
    theme: ThemeData(
      primaryColor: Fortuna.cp,
      colorScheme: ThemeData().colorScheme.copyWith(
          primary: Fortuna.cp, secondary: Fortuna.cpw, onPrimary: Colors.white),
      textTheme: TextTheme(bodyText2: Fortuna.font(15, night: false)),
      dialogTheme: DialogTheme(
        titleTextStyle: Fortuna.font(20, bold: true, night: false),
        contentTextStyle: Fortuna.font(17, night: false),
      ),
      scaffoldBackgroundColor: Colors.white,
      splashColor: Fortuna.cpw, // 0x44F44336
    ),
    darkTheme: ThemeData(
      primaryColor: Fortuna.cpd,
      colorScheme: ThemeData.dark().colorScheme.copyWith(
          primary: Fortuna.cpd,
          secondary: Fortuna.cwd,
          onPrimary: Colors.white),
      textTheme: TextTheme(bodyText2: Fortuna.font(15, night: true)),
      dialogTheme: DialogTheme(
        titleTextStyle: Fortuna.font(20, bold: true, night: true),
        contentTextStyle: Fortuna.font(17, night: true),
      ),
      scaffoldBackgroundColor: Colors.black,
      splashColor: Fortuna.cwd,
    ),
    themeMode: ThemeMode.system,
    debugShowCheckedModeBanner: false,
    home: Fortuna(),
  ));
}

class Fortuna extends StatelessWidget {
  Fortuna({Key? key}) : super(key: key);

  static File? stored;
  static Vita? vita;
  static late DateTime calendar;
  static late String luna;
  static bool lunaChanged = false;
  static String l = "en";
  static SharedPreferences? sp;

  static List<double?> emptyLuna() =>
      [for (var i = 1; i <= calendar.defPos() + 1; i++) null];

  static List<double?> thisLuna() => vita?[luna] ?? emptyLuna();

  static bool night() =>
      WidgetsBinding.instance.window.platformBrightness == Brightness.dark;

  static Color textColor([bool? night]) =>
      Color(!(night ?? Fortuna.night()) ? 0xFF777777 : 0xFFFFFFFF);

  static TextStyle font(double size,
          {bool bold = false, Color? color, bool? night}) =>
      TextStyle(
        color: color ?? textColor(night),
        fontFamily: 'Quattrocento',
        fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
        fontSize: size,
      );

  static const Color cp = Color(0xFF4CAF50),
      cpd = Color(0xFF034C06),
      cpw = Color(0x444CAF50),
      cs = Color(0xFFF44336),
      csd = Color(0xFF670D06),
      cwd = Color(0x44FFFFFF);

  @override
  Widget build(BuildContext context) {
    if (vita == null) vita = Vita();
    if (!lunaChanged) {
      calendar = DateTime.now();
      luna = calendar.toKey();
      // setState on second+ onResumes
    }
    if (vita?[luna] == null) vita?[luna] = emptyLuna();

    if (!kIsWeb)
      getApplicationSupportDirectory().then((dir) {
        stored = File('${dir.path}/fortuna.json');
        stored?.exists().then((exists) {
          if (exists)
            stored?.readAsString().then((json) {
              vita = VitaUtils.createFromJson(json);
              Panel.id.currentState?.setState(() {});
              Grid.id.currentState?.setState(() {});
            });
          else
            vita?.save();
        });
      });

    final systemOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Theme.of(context).primaryColor,
      systemNavigationBarColor: Theme.of(context).primaryColor,
    );
    SystemChrome.setSystemUIOverlayStyle(systemOverlayStyle);

    SharedPreferences.getInstance().then((value) {
      sp = value;
      Grid.id.currentState?.setState(() {});
    });

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: systemOverlayStyle,
        toolbarHeight: 60,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          s('appName'),
          style: const TextStyle(fontFamily: 'MorrisRoman', fontSize: 28),
        ),
        actions: <Widget>[
          PopupMenuButton<NumeralType>(
              icon: Icon(Icons.numbers),
              tooltip: s('numerals'),
              onSelected: (NumeralType item) {
                Fortuna.sp?.setString(BaseNumeral.key, item.id);
                Grid.id.currentState?.setState(() {});
              },
              itemBuilder: (BuildContext c) =>
                  [for (int i = 0; i < BaseNumeral.all.length; i++) i].map((i) {
                    NumeralType type = BaseNumeral.all[i];
                    String selectedType =
                        Fortuna.sp?.getString(BaseNumeral.key) ??
                            BaseNumeral.defType;

                    return PopupMenuItem<NumeralType>(
                      value: type,
                      child: Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                s(type.id),
                                style: Theme.of(c).textTheme.bodyText2,
                              ),
                            ),
                            Checkbox(
                              value: type.id == selectedType,
                              onChanged: (str) {},
                              activeColor: Fortuna.textColor(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList()),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).primaryColor,
        child: ListView(
          padding: const EdgeInsets.only(top: 40),
          children: <InkWell>[
            navButton(
              context,
              Icons.calculate_sharp,
              'navStat',
              () => showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  final scores = <double>[];
                  Fortuna.vita?.forEach((key, luna) {
                    final cal = makeCalendar(key);
                    for (var v = 0; v <= cal.lunaMaxima(); v++) {
                      final score = luna[v] ?? luna[cal.defPos()];
                      if (score != null) scores.add(score);
                    }
                  });
                  final sum = scores.sum();
                  final text = format(
                      s('statText'),
                      ((scores.length == 0)
                              ? 0.0
                              : sum.toDouble() / scores.length.toDouble())
                          .toString(),
                      sum.toString());

                  final buttonStyle = Theme.of(context).textTheme.bodyText2;
                  return AlertDialog(
                    title: Text(s('fortunaStat')),
                    content: Text(text),
                    actionsAlignment: MainAxisAlignment.end,
                    actions: <MaterialButton>[
                      MaterialButton(
                        child: Text(s('copy'), style: buttonStyle),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: text));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(s('done')),
                            duration: Duration(seconds: 2),
                          ));
                          Navigator.of(context).pop();
                        },
                      ),
                      MaterialButton(
                        child: Text(s('ok'), style: buttonStyle),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  );
                },
              ),
            ),
            navButton(context, Icons.outbox, 'navExport', () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(s('exportNotSupported')),
                  duration: Duration(seconds: 10)));
            }, false),
            navButton(context, Icons.move_to_inbox, 'navImport', () {
              if (kIsWeb)
                FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['json']).then((result) {
                  if (result != null)
                    importData(context, result.files.single.bytes!);
                });
              else
                FlutterDocumentPicker.openDocument(
                    params: FlutterDocumentPickerParams(
                        allowedFileExtensions: ['json'],
                        allowedUtiTypes: ['json'],
                        allowedMimeTypes: ['application/json'])).then((path) {
                  if (path == null) return;
                  if (!path.endsWith(".json")) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(s('nonJson')),
                        duration: Duration(seconds: 5)));
                    return;
                  }
                  File(path)
                      .readAsBytes()
                      .then((bytes) => importData(context, bytes));
                });
            }),
            navButton(context, Icons.send, 'navSend', () {
              if (stored != null)
                Share.shareFiles([stored!.path],
                    text: 'fortuna', mimeTypes: ['application/json']);
              else if (vita != null)
                Share.share(jsonEncode(vita), subject: s('appName'));
            }),
            navButton(
              context,
              Icons.help,
              'navHelp',
              () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text(s('navHelp')),
                  content: Text(s('help')),
                  actionsAlignment: MainAxisAlignment.end,
                  actions: <MaterialButton>[
                    MaterialButton(
                      child: Text(s('ok'),
                          style: Theme.of(context).textTheme.bodyText2),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          Panel(),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: (GridState.cellSize(context) / GridState.aspectRatio) *
                GridState.cellsInColumn(context),
            child: Grid(),
          ),
        ],
      ),
    );
  }

  InkWell navButton(BuildContext context, IconData icon, String title,
          void Function() onTap,
          [bool isEnabled = true]) =>
      InkWell(
        child: Opacity(
          opacity: isEnabled ? 1 : .5,
          child: MouseRegion(
            cursor: isEnabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.forbidden,
            child: ListTile(
              leading:
                  Icon(icon, color: Theme.of(context).colorScheme.onPrimary),
              title: Text(s(title),
                  style: Fortuna.font(19,
                      bold: true,
                      color: Theme.of(context).colorScheme.onPrimary)),
              enabled: isEnabled,
            ),
          ),
        ),
        onTap: onTap,
      );

  void importData(BuildContext context, Uint8List bytes) {
    final data = VitaUtils.createFromJson(new String.fromCharCodes(bytes));
    if (data.keys.any((k) => k.length != 7)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(s('invalidFile')), duration: Duration(seconds: 5)));
      return;
    }
    vita = data;
    vita?.save();
    Panel.id.currentState?.setState(() {});
    Grid.id.currentState?.setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s('done')), duration: Duration(seconds: 5)));
  }
}

class Panel extends StatefulWidget {
  Panel() : super(key: id);

  static final id = GlobalKey();
  static String annus = Fortuna.calendar.year.toString();
  static int luna = Fortuna.calendar.month;

  static void update() {
    annus = Fortuna.calendar.year.toString();
    luna = Fortuna.calendar.month;
  }

  @override
  State<StatefulWidget> createState() => PanelState();
}

class PanelState extends State<Panel> {
  static final double arrowDistance = 25;
  String _annus = Panel.annus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Icon(Icons.arrow_left, color: Fortuna.textColor()),
                ),
                onTap: () => rollCalendar(false),
              ),
              SizedBox(width: arrowDistance),
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  items: [
                    for (var i = 1; i <= 12; i++) i
                  ] // change 12 in Hebrew
                      .map<DropdownMenuItem<int>>(
                          (int value) => DropdownMenuItem<int>(
                                value: value,
                                child: Text(gregorianMonths[value - 1]),
                              ))
                      .toList(),
                  value: Panel.luna,
                  onChanged: (i) {
                    Fortuna.lunaChanged = true;
                    Panel.luna = i!;
                    valuesChanged();
                  },
                  style: Fortuna.font(19, bold: true),
                ),
              ),
              const SizedBox(width: 21),
              SizedBox(
                width: 54,
                child: TextFormField(
                  controller: TextEditingController()..text = _annus,
                  maxLength: 4,
                  maxLines: 1,
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.number,
                  style: Fortuna.font(20, bold: true),
                  decoration: InputDecoration(
                    counterText: "",
                    border: InputBorder.none,
                  ),
                  onChanged: (s) {
                    if (s.length != 4) return;
                    _annus = s;
                    Panel.annus = s;
                    valuesChanged();
                  },
                ),
              ),
              const SizedBox(width: 10),
              MaterialButton(
                child: Text(
                  Fortuna.thisLuna()[Fortuna.calendar.defPos()].showScore(),
                  style: Fortuna.font(16),
                ),
                onPressed: () {
                  Fortuna.thisLuna()
                      .changeVar(context, Fortuna.calendar.defPos());
                },
                // onLongPress: () {},
                // Apparently not possible in Flutter yet!
              ),
              SizedBox(width: arrowDistance),
              InkWell(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Icon(Icons.arrow_right, color: Fortuna.textColor()),
                ),
                onTap: () => rollCalendar(true),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            Fortuna.thisLuna().mean(Fortuna.calendar).toString(),
            style: Fortuna.font(15),
          ),
        ),
      ],
    );
  }

  void valuesChanged() {
    Panel.id.currentState?.setState(() {});
    Fortuna.luna = "${z(Panel.annus, 4)}.${z(Panel.luna)}";
    Fortuna.calendar = makeCalendar(Fortuna.luna);
    Grid.id.currentState?.setState(() {});
  }

  void rollCalendar(bool up) {
    final jiffy = Jiffy(Fortuna.calendar);
    if (up)
      jiffy.add(months: 1);
    else
      jiffy.subtract(months: 1);
    Fortuna.calendar = jiffy.dateTime;
    Fortuna.luna = Fortuna.calendar.toKey();
    Panel.update();
    Panel.id.currentState?.setState(() {
      _annus = Panel.annus;
    });
    Grid.id.currentState?.setState(() {});
  }
}

class Grid extends StatefulWidget {
  Grid() : super(key: id);

  static final id = GlobalKey();
  static final todayCalendar = DateTime.now();
  static final todayLuna = todayCalendar.toKey();

  @override
  State<StatefulWidget> createState() => GridState();
}

class GridState extends State<Grid> {
  List<double?> getLuna() {
    if (Fortuna.vita![Fortuna.luna] == null)
      Fortuna.vita![Fortuna.luna] = Fortuna.emptyLuna();
    return Fortuna.vita![Fortuna.luna]!;
  }

  static int cellsInRow(BuildContext c) {
    final screen = MediaQuery.of(c).size.width;
    if (screen < 900)
      return 5;
    else if (screen < 1200)
      return 7;
    else
      return 10;
  }

  static cellsInColumn(BuildContext c) {
    switch (GridState.cellsInRow(c)) {
      case 5:
        return 8;
      case 7:
        return 5;
      default:
        return 4;
    }
  }

  static cellSize(BuildContext c) =>
      MediaQuery.of(c).size.width / cellsInRow(c);
  static final aspectRatio = .8;

  @override
  Widget build(BuildContext context) {
    final normalBorder = Border.all(
        width: .5,
        color: !Fortuna.night()
            ? const Color(0xFFF0F0F0)
            : const Color(0xFF252525));

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      childAspectRatio: aspectRatio,
      crossAxisCount: cellsInRow(context),
      children:
          [for (var i = 0; i < Fortuna.calendar.lunaMaxima(); i++) i].map((i) {
        double? score = getLuna()[i] ?? getLuna().getDefault();
        bool isEstimated =
            getLuna()[i] == null && getLuna().getDefault() != null;

        Color bg, tc;
        if (score != null && score > 0) {
          tc = Theme.of(context).colorScheme.onPrimary;
          bg = (!Fortuna.night() ? Fortuna.cp : Fortuna.cpd)
              .withAlpha(((score / ScoreUtils.MAX_RANGE) * 256).toInt() - 1);
        } else if (score != null && score < 0) {
          tc = Theme.of(context).colorScheme.onPrimary;
          bg = (!Fortuna.night() ? Fortuna.cs : Fortuna.csd)
              .withAlpha(((-score / ScoreUtils.MAX_RANGE) * 256).toInt() - 1);
        } else {
          tc = Theme.of(context).textTheme.bodyText2!.color!;
          bg = Colors.transparent;
        }

        String selectedNumType =
            Fortuna.sp?.getString(BaseNumeral.key) ?? BaseNumeral.defType;
        bool enlarge = BaseNumeral.all
            .firstWhere((element) => element.id == selectedNumType,
                orElse: () => BaseNumeral.all.first)
            .enlarge;

        return InkWell(
          onTap: () => getLuna().changeVar(context, i),
          child: Container(
            decoration: BoxDecoration(
                color: bg,
                border: !(Fortuna.luna == Grid.todayLuna &&
                        Grid.todayCalendar.day == i + 1)
                    ? normalBorder
                    : Border.all(
                        width: 5,
                        color:
                            Color(!Fortuna.night() ? 0x44000000 : 0x44FFFFFF),
                      )),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  BaseNumeral.construct(selectedNumType, i + 1)?.toString() ??
                      (i + 1).toString(),
                  style: Fortuna.font(!enlarge ? 18 : 34, color: tc),
                ),
                const SizedBox(height: 3),
                Text(
                  (isEstimated ? "c. " : "") + score.showScore(),
                  style: Fortuna.font(13, color: tc),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

String s(String key) => dict[Fortuna.l]![key]!;

// Building a Windows app needs Visual Studio installed with its huge size.
// Building a Linux app needs Linux, a MacOS app needs MacOS.

// Running "flutter create ." will import default files to Android and iOS too!
// Run "flutter "flutter create --platforms=web ."; Add these arguments in
// similar situations: "--org=ir.mahdiparastesh.fortuna --project-name=fortuna"
