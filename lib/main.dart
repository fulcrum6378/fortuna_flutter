// ignore_for_file: invalid_use_of_protected_member

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

import 'dict.dart';
import 'vita.dart';

void main() {
  ThemeData theme = !Fortuna.night()
      ? ThemeData(
          primaryColor: Fortuna.cp,
          colorScheme: ThemeData().colorScheme.copyWith(
              primary: Fortuna.cp,
              secondary: Fortuna.cpw,
              onPrimary: Colors.white),
          textTheme: TextTheme(bodyText2: Fortuna.font(15, bold: false)),
          dialogTheme: DialogTheme(
            titleTextStyle: Fortuna.font(20, bold: true),
            contentTextStyle: Fortuna.font(17),
          ),
          scaffoldBackgroundColor: Colors.white,
          splashColor: Fortuna.cpw, // 0x44F44336
        )
      : ThemeData(
          primaryColor: Fortuna.cpd,
          colorScheme: ThemeData.dark().colorScheme.copyWith(
              primary: Fortuna.cpd,
              secondary: Fortuna.cwd,
              onPrimary: Colors.white),
          textTheme: TextTheme(bodyText2: Fortuna.font(15)),
          dialogTheme: DialogTheme(
            titleTextStyle: Fortuna.font(20, bold: true),
            contentTextStyle: Fortuna.font(17),
          ),
          scaffoldBackgroundColor: Colors.black,
          splashColor: Fortuna.cwd,
        );
  // TODO: These values do NOT change when system night mode is changed!

  runApp(MaterialApp(
    title: s('appName'),
    theme: theme, //themeMode: ThemeMode.system,
    debugShowCheckedModeBanner: false,
    home: const Fortuna(),
  ));
}

class Fortuna extends StatelessWidget {
  const Fortuna({Key? key}) : super(key: key);

  static File? stored;
  static Vita? vita;
  static late DateTime calendar;
  static late String luna;
  static bool lunaChanged = false;
  static String l = "en";

  static List<double?> emptyLuna() =>
      [for (var i = 1; i <= calendar.defPos() + 1; i++) null];

  static List<double?> thisLuna() => vita?[luna] ?? emptyLuna();

  static bool night() =>
      WidgetsBinding.instance?.window.platformBrightness == Brightness.dark;

  static TextStyle font(double size, {bool bold = false, Color? color}) =>
      TextStyle(
        color: color ?? Color(!Fortuna.night() ? 0xFF777777 : 0xFF670D06),
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

    getApplicationSupportDirectory().then((dir) {
      stored = File('${dir.path}/fortuna.json');
      stored?.exists().then((exists) {
        if (exists)
          stored?.readAsString().then((json) {
            final data = new Map<String, List<dynamic>>.from(jsonDecode(json));
            data.forEach((key, value) {
              List<dynamic> rawLuna = value;
              List<double?> newLuna = <double?>[];
              for (final v in rawLuna) newLuna.add(v);
              vita![key] = newLuna;
            });
            Panel.id.currentState?.setState(() {});
            Grid.id.currentState?.setState(() {});
          });
        else
          vita?.save();
      });
    });

    TextStyle navStyle = Fortuna.font(19,
        bold: true, color: Theme.of(context).colorScheme.onPrimary);

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).primaryColor,
          systemNavigationBarColor: Theme.of(context).primaryColor,
        ),
        toolbarHeight: 60,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          s('appName'),
          style: const TextStyle(fontFamily: 'MorrisRoman', fontSize: 28),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).primaryColor,
        child: ListView(
          padding: const EdgeInsets.only(top: 40),
          children: <InkWell>[
            InkWell(
              onTap: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text(s('navAverage')),
                  content: Text(Fortuna.vita?.mean().toString() ?? ''),
                  actionsAlignment: MainAxisAlignment.start,
                  actions: <MaterialButton>[
                    MaterialButton(
                      child: Text(
                        s('ok'),
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              child: ListTile(
                leading: Icon(Icons.calculate_sharp,
                    color: Theme.of(context).colorScheme.onPrimary),
                title: Text(s('navAverage'), style: navStyle),
              ),
            ),
            InkWell(
              onTap: () {
                if (stored != null)
                  Share.shareFiles([stored!.path],
                      text: 'fortuna', mimeTypes: ['application/json']);
              },
              child: ListTile(
                leading: Icon(Icons.import_export,
                    color: Theme.of(context).colorScheme.onPrimary),
                title: Text(s('navExport'), style: navStyle),
              ),
            ),
            InkWell(
              onTap: () {
                FilePicker.platform
                    .pickFiles(allowedExtensions: ['json']).then((result) {
                  if (result == null) return;
                  File(result.files.single.path!).readAsString().then((value) {
                    jsonDecode(value);
                    // TODO COMPLETE IT
                  });
                });
              },
              child: ListTile(
                leading: Icon(Icons.import_export,
                    color: Theme.of(context).colorScheme.onPrimary),
                title: Text(s('navImport'), style: navStyle),
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
            height: 580,
            child: Grid(),
          ),
        ],
      ),
    );
  }
}

class Panel extends StatefulWidget {
  Panel() : super(key: id);

  static final id = GlobalKey();
  static String annus = Fortuna.calendar.year.toString();
  static int luna = Fortuna.calendar.month;

  @override
  State<StatefulWidget> createState() => PanelState();
}

class PanelState extends State<Panel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                  initialValue: Panel.annus,
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
}

class Grid extends StatefulWidget {
  Grid() : super(key: id);

  static final id = GlobalKey();

  @override
  State<StatefulWidget> createState() => GridState();
}

class GridState extends State<Grid> {
  List<double?> getLuna() {
    if (Fortuna.vita![Fortuna.luna] == null)
      Fortuna.vita![Fortuna.luna] = Fortuna.emptyLuna();
    return Fortuna.vita![Fortuna.luna]!;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 5,
      children:
          [for (var i = 0; i < Fortuna.calendar.lunaMaxima(); i++) i].map((i) {
        double? score = getLuna()[i] ?? getLuna().getDefault();
        bool isEstimated =
            getLuna()[i] == null && getLuna().getDefault() != null;

        Color bg, tc;
        if (score != null && score > 0) {
          tc = Theme.of(context).colorScheme.onPrimary;
          bg = Fortuna.cp
              .withAlpha(((score / ScoreUtils.MAX_RANGE) * 256).toInt() - 1);
        } else if (score != null && score < 0) {
          tc = Theme.of(context).colorScheme.onPrimary;
          bg = Fortuna.cs
              .withAlpha(((-score / ScoreUtils.MAX_RANGE) * 256).toInt() - 1);
        } else {
          tc = Theme.of(context).textTheme.bodyText2!.color!;
          bg = Colors.transparent;
        }

        return InkWell(
          onTap: () => getLuna().changeVar(context, i),
          child: Container(
            decoration: BoxDecoration(
                color: bg,
                border: Border.all(
                    width: 0.5,
                    color: !Fortuna.night()
                        ? const Color(0xFFF0F0F0)
                        : const Color(0xFF252525))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(romanNumbers[i], style: Fortuna.font(18, color: tc)),
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
