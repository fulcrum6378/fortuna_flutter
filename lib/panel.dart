import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jiffy/jiffy.dart';

import 'dict.dart';
import 'main.dart';
import 'vita.dart';

class PanelCubit extends CalendarCubit {}

class Panel extends StatelessWidget {
  const Panel({super.key});

  static final double arrowDistance = 15;

  Luna thisLuna(String luna, DateTime calendar) =>
      vita?[luna] ?? emptyLuna(calendar);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PanelCubit, DateTime>(
      buildWhen: (a, b) => true,
      builder: (context, calendar) => Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20, right: 30),
            child: Align(
              alignment: Alignment.centerRight,
              child: Visibility(
                visible: Fortuna.thisLuna().verbum != null,
                maintainState: true,
                maintainAnimation: true,
                maintainSize: true,
                child: Fortuna.verbumIcon(),
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
                onTap: () => rollCalendar(false, CalendarFields.months),
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
                  value: calendar.month,
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
                      onTap: () => rollCalendar(true, CalendarFields.years),
                    ),
                    TextFormField(
                      controller: TextEditingController()
                        ..text = calendar.year.toString(),
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
                        annus = s;
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
                      onTap: () => rollCalendar(false, CalendarFields.years),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              MaterialButton(
                onPressed: () => Fortuna.thisLuna().changeVar(context, null),
                // onLongPress: () {},
                // Apparently not possible in Flutter yet!
                minWidth: 10,
                child: Text(
                  Fortuna.thisLuna().defVar.showScore(),
                  style: Fortuna.font(16),
                ),
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
                onTap: () => rollCalendar(true, CalendarFields.months),
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
      ),
    );
  }

  void valuesChanged() {
    context.read<PanelCubit>().update();
    Panel.id.currentState?.setState(() {});
    Fortuna.luna = "${z(Panel.annus, 4)}.${z(Panel.luna)}";
    Fortuna.calendar = Fortuna.luna.makeCalendar();
    context.read<GridCubit>().update();
  }

  /// Move calendar in months or years
  void rollCalendar(bool up, CalendarFields field, [int times = 1]) {
    final jiffy = Jiffy.parseFromDateTime(Fortuna.calendar);
    if (up) {
      if (field == CalendarFields.years) {
        jiffy.add(years: times);
      } else {
        jiffy.add(months: times);
      }
    } else {
      if (field == CalendarFields.years) {
        jiffy.subtract(years: times);
      } else {
        jiffy.subtract(months: times);
      }
    }
    Fortuna.calendar = jiffy.dateTime;
    Fortuna.luna = Fortuna.calendar.toKey();
    Panel.update();
    Panel.id.currentState?.setState(() {
      _annus = Panel.annus;
    });
    context.read<GridCubit>().update();
  }
}

enum CalendarFields { years, months }
