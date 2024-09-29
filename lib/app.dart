import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:format/format.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import 'dict.dart';
import 'main.dart';
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
        surfaceTintColor: Fortuna.cpu,
      ),
      popupMenuTheme: popupMenu,
      scaffoldBackgroundColor: Colors.white,
      splashColor: Fortuna.cpw,
      canvasColor: Fortuna.cpu,
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
        surfaceTintColor: Fortuna.cpu,
      ),
      popupMenuTheme: popupMenu,
      scaffoldBackgroundColor: Colors.black,
      splashColor: Fortuna.cwd,
      canvasColor: Fortuna.cpu,
      useMaterial3: true,
    ),
    themeMode: ThemeMode.system,
    debugShowCheckedModeBanner: false,
    home: Fortuna(),
  ));
}

class Fortuna extends StatelessWidget {
  const Fortuna({super.key});

  static File? stored;
  static Vita? vita;
  static late DateTime calendar;
  static late String luna;
  static bool lunaChanged = false;
  static String l = "en";
  static SharedPreferences? sp;
  static bool showingSnackbar = false;

  static Luna emptyLuna() => Luna(calendar);

  static Luna thisLuna() => vita?[luna] ?? emptyLuna();

  static bool night() =>
      PlatformDispatcher.instance.platformBrightness == Brightness.dark;

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
    vita ??= Vita();
    if (!lunaChanged) {
      calendar = DateTime.now();
      luna = calendar.toKey();
      // setState on second+ onResumes
    }
    if (vita?[luna] == null) vita?[luna] = emptyLuna();

    if (!kIsWeb) {
      getApplicationSupportDirectory().then((dir) {
        stored = File('${dir.path}/fortuna.vita');
        stored?.exists().then((exists) {
          if (exists) {
            stored?.readAsString().then((data) {
              vita = VitaUtils.load(data);
              Panel.id.currentState?.setState(() {});
              Grid.id.currentState?.setState(() {});
            });
          } else {
            vita?.save();
          }
        });
      });
    }

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
            icon: Icon(Icons.numbers, color: Colors.white),
            tooltip: s('numerals'),
            initialValue: BaseNumeral.findById(selectedNumType),
            //elevation: 0, // In order to fix the grey problem!
            onSelected: (NumeralType item) {
              Fortuna.sp?.setString(BaseNumeral.key, item.id);
              Grid.id.currentState?.setState(() {});
              Fortuna.shake();
            },
            surfaceTintColor: Fortuna.cpu,
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
                      ((scores.isEmpty)
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
              if (showingSnackbar) return;
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                    SnackBar(
                        content: Text(s('exportNotSupported')),
                        duration: Duration(seconds: 10),
                        onVisible: () {
                          showingSnackbar = true;
                        }),
                  )
                  .closed
                  .then((_) => showingSnackbar = false);
            }, false),
            navButton(context, Icons.move_to_inbox, 'navImport', () {
              if (kIsWeb) {
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
              } else {
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
                    if (path.endsWith(".vita")) {
                      importVita(context, bytes);
                    } else {
                      importJson(context, bytes);
                    }
                  });
                });
              }
              Navigator.of(context).pop();
            }),
            navButton(context, Icons.send, 'navSend', () {
              if (stored != null) {
                Share.shareXFiles(
                    [XFile(stored!.path, mimeType: 'application/json')],
                    text: 'fortuna');
              } else if (vita != null) {
                Share.share(vita!.dump(), subject: s('appName'));
              }
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
        onTap: onTap,
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
      );

  void importJson(BuildContext context, Uint8List bytes) {
    final data = loadLegacyVita(String.fromCharCodes(bytes));
    if (data.keys.any((k) => k.length != 7)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(s('invalidFile')), duration: Duration(seconds: 5)));
      return;
    }
    importData(context, data);
  }

  void importVita(BuildContext context, Uint8List bytes) {
    importData(context, VitaUtils.load(String.fromCharCodes(bytes)));
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

String s(String key) => dict[Fortuna.l]![key]!;

/*TODO:
   * Fix default verbum save problem only in Android?!?

 * Running "flutter create ." will import default files to Android and iOS too!
 * Run "flutter "flutter create --platforms=web ."; Add these arguments in
 * similar situations: "--org=ir.mahdiparastesh.fortuna --project-name=fortuna"
 */
