// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

import 'app.dart';
import 'dict.dart';
import 'numerals.dart';
import 'vita.dart';

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
        Row(
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
              onTap: () => rollCalendar(false, CalendarFields.MONTHS),
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
              child: Column(
                children: [
                  InkWell(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.arrow_drop_up,
                            color: Fortuna.textColor()),
                      ),
                    ),
                    onTap: () => rollCalendar(true, CalendarFields.YEARS),
                  ),
                  TextFormField(
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
                  InkWell(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.arrow_drop_down,
                            color: Fortuna.textColor()),
                      ),
                    ),
                    onTap: () => rollCalendar(false, CalendarFields.YEARS),
                  ),
                ],
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
              onTap: () => rollCalendar(true, CalendarFields.MONTHS),
            ),
          ],
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

  /// Move calendar in months or years
  void rollCalendar(bool up, CalendarFields field, [int times = 1]) {
    final jiffy = Jiffy(Fortuna.calendar);
    if (up) {
      if (field == CalendarFields.YEARS)
        jiffy.add(years: times);
      else
        jiffy.add(months: times);
    } else {
      if (field == CalendarFields.YEARS)
        jiffy.subtract(years: times);
      else
        jiffy.subtract(months: times);
    }
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

enum CalendarFields { YEARS, MONTHS }
