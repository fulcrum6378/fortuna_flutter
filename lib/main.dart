import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_machine/time_machine.dart';

import 'conf.dart';
import 'dict.dart';

void main() {
  ThemeData theme = !Fortuna.night()
      ? ThemeData(
          primaryColor: const Color(0xFF4CAF50),
          colorScheme: ThemeData().colorScheme.copyWith(
              secondary: const Color(0xFFF44336), onPrimary: Colors.white),
          textTheme: TextTheme(bodyText2: Fortuna.font(15, false)),
          dialogTheme: DialogTheme(
            titleTextStyle: Fortuna.font(20, true),
            contentTextStyle: Fortuna.font(17, false),
          ),
          scaffoldBackgroundColor: Colors.white,
          splashColor: const Color(0x444CAF50), // 0x44F44336
        )
      : ThemeData(
          primaryColor: const Color(0xFF034C06),
          colorScheme: ThemeData.dark().colorScheme.copyWith(
              secondary: const Color(0xFF670D06), onPrimary: Colors.white),
          textTheme: TextTheme(bodyText2: Fortuna.font(15)),
          dialogTheme: DialogTheme(
            titleTextStyle: Fortuna.font(20, true),
            contentTextStyle: Fortuna.font(17),
          ),
          scaffoldBackgroundColor: Colors.black,
          splashColor: const Color(0x444CAF50),
        );
  // TODO: These values do NOT change when system night mode is changed!

  runApp(MaterialApp(
    title: dict[Config.lang]!["appName"]!,
    theme: theme, //themeMode: ThemeMode.system,
    debugShowCheckedModeBanner: false,
    home: const Fortuna(),
  ));
}

class Fortuna extends StatelessWidget {
  const Fortuna({Key? key}) : super(key: key);

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
          dict[Config.lang]!["appName"]!,
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
                  title: Text(dict[Config.lang]!["navAverage"]!),
                  content: const Text('1.54363'),
                  actionsAlignment: MainAxisAlignment.start,
                  actions: <Widget>[
                    MaterialButton(
                      child: Text(
                        dict[Config.lang]!["ok"]!,
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
                title: Text(dict[Config.lang]!["navAverage"]!, style: navStyle),
              ),
            ),
            InkWell(
              onTap: () {},
              child: ListTile(
                leading: Icon(Icons.import_export,
                    color: Theme.of(context).colorScheme.onPrimary),
                title: Text(dict[Config.lang]!["navExport"]!, style: navStyle),
              ),
            ),
            InkWell(
              onTap: () {},
              child: ListTile(
                leading: Icon(Icons.import_export,
                    color: Theme.of(context).colorScheme.onPrimary),
                title: Text(dict[Config.lang]!["navImport"]!, style: navStyle),
              ),
            ),
          ],
        ),
      ),
      body: ScrollConfiguration(
        behavior: const ScrollBehavior(),
        child: GlowingOverscrollIndicator(
          axisDirection: AxisDirection.down,
          color: Theme.of(context).splashColor,
          child: ListView(children: const [Panel(), Flexible(child: Luna())]),
        ),
      ),
    );
  }
}

class Panel extends StatefulWidget {
  const Panel({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PanelState();
}

class PanelState extends State<Panel> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropdownButton<String>(
              items: jalaliMonths
                  .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                  .toList(),
              onChanged: (s) {}),
          /*TextField(
            maxLength: 4,
          ),*/ // RUINS EVERYTHING
        ],
      ),
    );
  }
}

class Luna extends StatefulWidget {
  const Luna({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LunaState();
}

class LunaState extends State<Luna> {
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
      children: days
          .map((i) => InkWell(
                onTap: () {},
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
                      Text("0", style: Fortuna.font(13)),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}
