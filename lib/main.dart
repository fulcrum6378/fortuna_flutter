import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'conf.dart';
import 'dict.dart';

void main() => runApp(const Fortuna());

class Fortuna extends StatelessWidget {
  const Fortuna({Key? key}) : super(key: key);

  static bool night() =>
      WidgetsBinding.instance?.window.platformBrightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = !night()
        ? ThemeData(
            primaryColor: const Color(0xFF4CAF50),
            colorScheme: ThemeData().colorScheme.copyWith(
                secondary: const Color(0xFFF44336), onPrimary: Colors.white),
            textTheme:
                const TextTheme(bodyText2: TextStyle(color: Color(0xFF777777))),
            scaffoldBackgroundColor: Colors.white,
            splashColor: const Color(0x444CAF50), // 0x44F44336
          )
        : ThemeData(
            primaryColor: const Color(0xFF034C06),
            colorScheme: ThemeData.dark().colorScheme.copyWith(
                secondary: const Color(0xFF670D06), onPrimary: Colors.white),
            textTheme:
                const TextTheme(bodyText2: TextStyle(color: Color(0xFFFFFFFF))),
            scaffoldBackgroundColor: Colors.black,
            splashColor: const Color(0x444CAF50),
          );
    // TODO: These values do NOT change when system night mode is changed!

    var navStyle = TextStyle(
      color: theme.colorScheme.onPrimary,
      fontFamily: 'Quattrocento',
      fontWeight: FontWeight.w800,
      fontSize: 17,
    );

    return MaterialApp(
      title: dict[Config.lang]!["appName"]!,
      theme: theme, //themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: theme.primaryColor,
            systemNavigationBarColor: theme.primaryColor,
          ),
          toolbarHeight: 60,
          backgroundColor: theme.primaryColor,
          title: Text(
            dict[Config.lang]!["appName"]!,
            style: const TextStyle(fontFamily: 'MorrisRoman', fontSize: 28),
          ),
        ),
        drawer: Drawer(
          backgroundColor: theme.primaryColor,
          child: ListView(
            padding: const EdgeInsets.only(top: 40),
            children: <InkWell>[
              InkWell(
                onTap: () => averageOfTotal(context),
                child: ListTile(
                  leading: Icon(Icons.calculate_sharp,
                      color: theme.colorScheme.onPrimary),
                  title:
                      Text(dict[Config.lang]!["navAverage"]!, style: navStyle),
                ),
              ),
              InkWell(
                onTap: () {},
                child: ListTile(
                  leading: Icon(Icons.import_export,
                      color: theme.colorScheme.onPrimary),
                  title:
                      Text(dict[Config.lang]!["navExport"]!, style: navStyle),
                ),
              ),
              InkWell(
                onTap: () {},
                child: ListTile(
                  leading: Icon(Icons.import_export,
                      color: theme.colorScheme.onPrimary),
                  title:
                      Text(dict[Config.lang]!["navImport"]!, style: navStyle),
                ),
              ),
            ],
          ),
        ),
        body: Column(children: const [Panel(), Flexible(child: Luna())]),
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
      padding: const EdgeInsets.symmetric(vertical: 140),
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
          TextField(
            maxLength: 4,
          ),
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
      //physics: const NeverScrollableScrollPhysics(),
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
                      Text(
                        romanNumbers[i],
                        style: const TextStyle(
                          fontFamily: 'Quattrocento',
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        "0",
                        style: TextStyle(
                          fontFamily: 'Quattrocento',
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

Future<void> averageOfTotal(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('AlertDialog Title'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('This is a demo alert dialog.'),
              Text('Would you like to approve of this message?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Approve'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
