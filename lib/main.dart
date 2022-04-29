// ignore_for_file: invalid_use_of_protected_member

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'dict.dart';
import 'vita.dart';

void main() {
  const Color cp = Color(0xFF4CAF50),
      cpd = Color(0xFF034C06),
      cpw = Color(0x444CAF50),
      cs = Color(0xFFF44336),
      csd = Color(0xFF670D06),
      cwd = Color(0x44FFFFFF);
  ThemeData theme = !Fortuna.night()
      ? ThemeData(
          primaryColor: cp,
          colorScheme: ThemeData()
              .colorScheme
              .copyWith(primary: cp, secondary: cpw, onPrimary: Colors.white),
          textTheme: TextTheme(bodyText2: Fortuna.font(15, false)),
          dialogTheme: DialogTheme(
            titleTextStyle: Fortuna.font(20, true),
            contentTextStyle: Fortuna.font(17, false),
          ),
          scaffoldBackgroundColor: Colors.white,
          splashColor: cpw, // 0x44F44336
        )
      : ThemeData(
          primaryColor: cpd,
          colorScheme: ThemeData.dark()
              .colorScheme
              .copyWith(primary: cpd, secondary: cwd, onPrimary: Colors.white),
          textTheme: TextTheme(bodyText2: Fortuna.font(15)),
          dialogTheme: DialogTheme(
            titleTextStyle: Fortuna.font(20, true),
            contentTextStyle: Fortuna.font(17),
          ),
          scaffoldBackgroundColor: Colors.black,
          splashColor: cwd,
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

  static thisLuna() => vita?[luna] ?? emptyLuna();

  static bool night() =>
      WidgetsBinding.instance?.window.platformBrightness == Brightness.dark;

  static TextStyle font(double size, [bool bold = false, Color? color]) =>
      TextStyle(
        color: color ?? Color(!Fortuna.night() ? 0xFF777777 : 0xFF670D06),
        fontFamily: 'Quattrocento',
        fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
        fontSize: size,
      );

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
      stored = File('${dir.path}/vita.json');
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
            Grid.id.currentState?.setState(() {});
          });
        else
          vita?.save();
      });
    });

    TextStyle navStyle =
        Fortuna.font(19, true, Theme.of(context).colorScheme.onPrimary);

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
                barrierDismissible: false,
                builder: (BuildContext context) => AlertDialog(
                  title: Text(s('navAverage')),
                  content: const Text('1.54363'),
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
              onTap: () {},
              child: ListTile(
                leading: Icon(Icons.import_export,
                    color: Theme.of(context).colorScheme.onPrimary),
                title: Text(s('navExport'), style: navStyle),
              ),
            ),
            InkWell(
              onTap: () {},
              child: ListTile(
                leading: Icon(Icons.import_export,
                    color: Theme.of(context).colorScheme.onPrimary),
                title: Text(s('navImport'), style: navStyle),
              ),
            ),
          ],
        ),
      ),
      body: ListView(children: [Panel(), Flexible(child: Grid())]),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              items: [for (var i = 1; i <= 12; i++) i] // change 12 in Hebrew
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
              style: Fortuna.font(18.5, true),
            ),
          ),
          const SizedBox(width: 30),
          SizedBox(
            width: 100,
            child: TextFormField(
              initialValue: Panel.annus,
              maxLength: 4,
              maxLines: 1,
              textAlign: TextAlign.left,
              keyboardType: TextInputType.number,
              style: Fortuna.font(19.5, true),
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
        ],
      ),
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
    //DateTime now = DateTime.now();
    List<int> days = [];

    for (var i = 0; i < 31; i++) {
      days.add(i);
    }

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 5,
      children: days.map((i) {
        double? score = getLuna()[i] ?? getLuna().getDefault();
        bool isEstimated =
            getLuna()[i] == null && getLuna().getDefault() != null;

        return InkWell(
          onTap: () => getLuna().changeVar(context, i),
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(
                    width: 0.5,
                    color: !Fortuna.night()
                        ? const Color(0xFFF0F0F0)
                        : const Color(0xFF252525))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(romanNumbers[i], style: Fortuna.font(18)),
                const SizedBox(height: 3),
                Text(
                  (isEstimated ? "c. " : "") + score.showScore(),
                  style: Fortuna.font(13),
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
