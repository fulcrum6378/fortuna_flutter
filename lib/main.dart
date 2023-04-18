// ignore_for_file: invalid_use_of_protected_member

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:format/format.dart';
import 'package:jiffy/jiffy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import 'dict.dart';
import 'numerals.dart';
import 'vita.dart';

void main() {
  final mediumCornerStyle =
      BeveledRectangleBorder(borderRadius: BorderRadius.circular(12));
  final smallCornerStyle =
      BeveledRectangleBorder(borderRadius: BorderRadius.circular(8));
  final drawer = DrawerThemeData(
    backgroundColor: Fortuna.cp,
    shape: BeveledRectangleBorder(
      borderRadius: BorderRadius.horizontal(right: Radius.circular(15)),
    ),
  );
  final popupMenu = PopupMenuThemeData(
    color: Fortuna.cpu,
    shape: smallCornerStyle,
  );

  runApp(MaterialApp(
    title: s('appName'),
    theme: ThemeData(
      primaryColor: Fortuna.cp,
      colorScheme: ThemeData().colorScheme.copyWith(
          primary: Fortuna.cp,
          onPrimary: Colors.white,
          secondary: Fortuna.cpw,
          surface: Fortuna.cp,
          onSurface: Colors.white),
      // surface/onSurface is applied to AppBar
      textTheme: TextTheme(bodyMedium: Fortuna.font(15, night: false)),
      drawerTheme: drawer,
      dialogTheme: DialogTheme(
        titleTextStyle: Fortuna.font(20, bold: true, night: false),
        contentTextStyle: Fortuna.font(17, night: false),
        shape: mediumCornerStyle,
        backgroundColor: Fortuna.cpu,
      ),
      popupMenuTheme: popupMenu,
      scaffoldBackgroundColor: Colors.white,
      splashColor: Fortuna.cpw,
      useMaterial3: true,
    ),
    darkTheme: ThemeData(
      primaryColor: Fortuna.cpd,
      colorScheme: ThemeData.dark().colorScheme.copyWith(
          primary: Fortuna.cpd,
          onPrimary: Colors.white,
          secondary: Fortuna.cwd,
          surface: Fortuna.cp,
          onSurface: Colors.white),
      textTheme: TextTheme(bodyMedium: Fortuna.font(15, night: true)),
      drawerTheme: drawer,
      dialogTheme: DialogTheme(
        titleTextStyle: Fortuna.font(20, bold: true, night: true),
        contentTextStyle: Fortuna.font(17, night: true),
        shape: mediumCornerStyle,
        backgroundColor: Fortuna.cpu,
      ),
      popupMenuTheme: popupMenu,
      scaffoldBackgroundColor: Colors.black,
      splashColor: Fortuna.cwd,
      useMaterial3: true,
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

  static Luna emptyLuna() => Luna(calendar);

  static Luna thisLuna() => vita?[luna] ?? emptyLuna();

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
      cwd = Color(0x44FFFFFF),
      cpu = Color(0xFFECF1EB); // Popup

  static bool canShake = false;

  static shake() {
    if (!canShake) return;
    Vibration.vibrate(duration: 40, amplitude: 100);
  }

  static Icon verbumIcon([Color? tc]) =>
      Icon(Icons.chat_sharp, color: tc ?? textColor(), size: 19);

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
        stored = File('${dir.path}/fortuna.vita');
        stored?.exists().then((exists) {
          if (exists)
            stored?.readAsString().then((data) {
              vita = VitaUtils.load(data);
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
    String selectedNumType =
        Fortuna.sp?.getString(BaseNumeral.key) ?? BaseNumeral.defType;

    Vibration.hasVibrator().then((value) => canShake = value == true);

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: systemOverlayStyle,
        toolbarHeight: 60,
        title: Text(
          s('appName'),
          style: const TextStyle(fontFamily: 'MorrisRoman', fontSize: 28),
        ),
        actions: <Widget>[
          PopupMenuButton<NumeralType>(
            icon: Icon(Icons.calendar_month),
            tooltip: s('numerals'),
            initialValue: BaseNumeral.findById(selectedNumType),
            //elevation: 0, // In order to fix the grey problem!
            onSelected: (NumeralType item) {
              Fortuna.sp?.setString(BaseNumeral.key, item.id);
              Grid.id.currentState?.setState(() {});
              Fortuna.shake();
            },
            itemBuilder: (BuildContext c) =>
                [for (int i = 0; i < BaseNumeral.all.length; i++) i].map((i) {
              NumeralType type = BaseNumeral.all[i];

              return PopupMenuItem<NumeralType>(
                value: type,
                child: Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          s(type.id),
                          style: Theme.of(c).textTheme.bodyMedium,
                        ),
                      ),
                      Checkbox(
                        value: type.id == selectedNumType,
                        onChanged: (str) {},
                        activeColor: Fortuna.textColor(),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.only(top: 40),
          children: <InkWell>[
            navButton(context, Icons.today, 'navToday', () {
              calendar = DateTime.now();
              luna = calendar.toKey();
              Panel.update();
              Panel.id.currentState?.setState(() {});
              Grid.id.currentState?.setState(() {});
              Navigator.of(context).pop();
            }),
            navButton(
              context,
              Icons.calculate,
              'navStat',
              () => showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  final scores = <double>[];
                  Fortuna.vita?.forEach((key, luna) {
                    for (var v = 0; v < luna.diebus.length; v++) {
                      final score = luna[v] ?? luna.defVar;
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
                      sum.toString(),
                      scores.length);

                  final buttonStyle = Theme.of(context).textTheme.bodyMedium;
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
                    allowedExtensions: ['json', 'vita']).then((result) {
                  switch (result?.files.single.extension) {
                    case 'json':
                      importJson(context, result!.files.single.bytes!);
                      break;
                    case 'vita':
                      importVita(context, result!.files.single.bytes!);
                      break;
                    default:
                      break;
                  }
                });
              else
                FlutterDocumentPicker.openDocument(
                    params: FlutterDocumentPickerParams(allowedFileExtensions: [
                  'json'
                ], allowedUtiTypes: [
                  'json'
                ], allowedMimeTypes: [
                  'application/octet-stream',
                  'application/json'
                ])).then((path) {
                  if (path == null) return;
                  if (!path.endsWith(".json") && !path.endsWith(".vita")) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(s('nonJson')),
                        duration: Duration(seconds: 5)));
                    return;
                  }
                  File(path).readAsBytes().then((bytes) {
                    if (path.endsWith(".vita"))
                      importVita(context, bytes);
                    else
                      importJson(context, bytes);
                  });
                });
              Navigator.of(context).pop();
            }),
            navButton(context, Icons.send, 'navSend', () {
              if (stored != null)
                Share.shareXFiles(
                    [XFile(stored!.path, mimeType: 'application/json')],
                    text: 'fortuna');
              else if (vita != null)
                Share.share(vita!.dump(), subject: s('appName'));
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
                          style: Theme.of(context).textTheme.bodyMedium),
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

  void importJson(BuildContext context, Uint8List bytes) {
    final data = loadLegacyVita(new String.fromCharCodes(bytes));
    if (data.keys.any((k) => k.length != 7)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(s('invalidFile')), duration: Duration(seconds: 5)));
      return;
    }
    importData(context, data);
  }

  void importVita(BuildContext context, Uint8List bytes) {
    importData(context, VitaUtils.load(new String.fromCharCodes(bytes)));
  }

  void importData(BuildContext context, Vita data) {
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
  static final double arrowDistance = 15;
  String _annus = Panel.annus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20, right: 30),
          child: Align(
            alignment: Alignment.centerRight,
            child: Visibility(
              visible: Fortuna.thisLuna().verbum != null,
              child: Fortuna.verbumIcon(),
              maintainState: true,
              maintainAnimation: true,
              maintainSize: true,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 9, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.arrow_left, color: Fortuna.textColor()),
                  ),
                ),
                onTap: () => rollCalendar(false),
              ),
              SizedBox(width: arrowDistance),
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  // change 12 in Hebrew
                  items: [for (int i = 1; i <= 12; i++) i]
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
                    counterText: "", // NOT THE DEF VALUE ^
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
                  Fortuna.thisLuna().defVar.showScore(),
                  style: Fortuna.font(16),
                ),
                onPressed: () => Fortuna.thisLuna().changeVar(context, null),
                // onLongPress: () {},
                // Apparently not possible in Flutter yet!
                minWidth: 10,
              ),
              SizedBox(width: arrowDistance),
              InkWell(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.arrow_right, color: Fortuna.textColor()),
                  ),
                ),
                onTap: () => rollCalendar(true),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            Fortuna.thisLuna().mean().toString(),
            style: Fortuna.font(15),
          ),
        ),
      ],
    );
  }

  void valuesChanged() {
    Panel.id.currentState?.setState(() {});
    Fortuna.luna = "${z(Panel.annus, 4)}.${z(Panel.luna)}";
    Fortuna.calendar = Fortuna.luna.makeCalendar();
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
  Luna getLuna() {
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
        double? score = getLuna()[i] ?? getLuna().defVar;
        bool isEstimated = getLuna()[i] == null && getLuna().defVar != null;

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
          tc = Theme.of(context).textTheme.bodyMedium!.color!;
          bg = Colors.transparent;
        }

        String selectedNumType =
            Fortuna.sp?.getString(BaseNumeral.key) ?? BaseNumeral.defType;
        bool enlarge = BaseNumeral.findById(selectedNumType).enlarge;

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
                      color: Color(!Fortuna.night() ? 0x44000000 : 0x44FFFFFF),
                    ),
            ),
            child: Stack(
              children: [
                Visibility(
                  visible: getLuna().verba[i] != null,
                  child: Padding(
                    padding: EdgeInsets.only(right: 6, top: 6),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Fortuna.verbumIcon(tc),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        BaseNumeral.construct(selectedNumType, i + 1)
                                ?.toString() ??
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
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

String s(String key) => dict[Fortuna.l]![key]!;

/*TODO:
   * Fix numerals menu
   * Fix default verbum save problem only in Android?!?

   * Building a Windows app needs Visual Studio installed with its huge size.
   * Building a Linux app needs Linux, a MacOS app needs MacOS.
   *
   * Running "flutter create ." will import default files to Android and iOS too!
   * Run "flutter "flutter create --platforms=web ."; Add these arguments in
   * similar situations: "--org=ir.mahdiparastesh.fortuna --project-name=fortuna"
   */
