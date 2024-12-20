import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jiffy/jiffy.dart';

import 'lang.dart';
import 'main.dart';
import 'numerals.dart';
import 'vita.dart';

class HomeCubit extends Cubit<DateTime> {
  HomeCubit() : super(DateTime.now());

  void update({int? year, int? month, DateTime? calendar}) {
    if (calendar != null) {
      emit(calendar);
    } else if (year != null || month != null) {
      emit(DateTime(year ?? state.year, month ?? state.month));
    } else {
      emit(state.copyWith(second: (state.second == 0) ? 1 : 0));
    }
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  final double arrowDistance = 15;
  final aspectRatio = .8;

  @override
  Widget build(BuildContext context) {
    final normalBorder = Border.all(
        width: .5,
        color: !Fortuna.night()
            ? const Color(0xFFF0F0F0)
            : const Color(0xFF252525));

    if (!Fortuna.loaded) { // FIXME doesn't work
      return BlocBuilder<HomeCubit, DateTime>(
          builder: (context, calendar) => Center(
                child: Text("Loading..."), //CircularProgressIndicator(),
              ));
    }

    return BlocBuilder<HomeCubit, DateTime>(
      builder: (context, calendar) {
        String lunaKey = calendar.toKey();
        Luna luna = context.read<Vita>().get(lunaKey, calendar);
        final todayCalendar = DateTime.now();
        final todayLunaKey = todayCalendar.toKey();

        return ListView(children: [
          // BEGIN PANEL
          Stack(children: [
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 7),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  InkWell(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child:
                            Icon(Icons.arrow_left, color: Fortuna.textColor()),
                      ),
                    ),
                    onTap: () => context.read<HomeCubit>().update(
                        calendar: rollCalendarInMonths(calendar, false)),
                  ),
                  SizedBox(width: arrowDistance),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      // change 12 in Hebrew
                      items: [for (int i = 1; i <= 12; i++) i]
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(gregorianMonths[value - 1]),
                        );
                      }).toList(),
                      value: calendar.month,
                      onChanged: (i) {
                        context.read<HomeCubit>().update(month: i!);
                      },
                      style: Fortuna.font(19, bold: true),
                    ),
                  ),
                  const SizedBox(width: 21),
                  SizedBox(
                    width: 54,
                    child: Column(children: [
                      InkWell(
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.arrow_drop_up,
                                color: Fortuna.textColor()),
                          ),
                        ),
                        onTap: () => context.read<HomeCubit>().update(
                            calendar: rollCalendarInYears(calendar, true)),
                      ), // TODO onLongClick
                      TextFormField(
                        controller: TextEditingController()
                          ..text = calendar.year.toString(),
                        maxLength: 4,
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        keyboardType: TextInputType.number,
                        style: Fortuna.font(20, bold: true),
                        decoration: InputDecoration(
                          counterText: '', // NOT THE DEF VALUE ^
                          border: InputBorder.none,
                        ),
                        onChanged: (s) {
                          if (s.length != 4) return;
                          context.read<HomeCubit>().update(year: int.parse(s));
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
                        onTap: () => context.read<HomeCubit>().update(
                            calendar: rollCalendarInYears(calendar, false)),
                      ),
                    ]),
                  ),
                  const SizedBox(width: 10),
                  MaterialButton(
                    onPressed: () => changeVar(context, lunaKey, luna, null),
                    // onLongPress: () {},
                    // Apparently not possible in Flutter yet!
                    minWidth: 10,
                    child: Text(
                      luna.defVar.showScore(),
                      style: Fortuna.font(16),
                    ),
                  ),
                  SizedBox(width: arrowDistance),
                  InkWell(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child:
                            Icon(Icons.arrow_right, color: Fortuna.textColor()),
                      ),
                    ),
                    onTap: () => context
                        .read<HomeCubit>()
                        .update(calendar: rollCalendarInMonths(calendar, true)),
                  ),
                ]),
                Text(
                  luna.mean().toString(),
                  style: Fortuna.font(15),
                ),
              ]),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20, right: 40),
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Visibility(
                    visible: luna.emoji != null,
                    maintainState: true,
                    maintainAnimation: true,
                    maintainSize: true,
                    child: Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Text(
                        luna.emoji != null ? luna.emoji! : '',
                        style: Fortuna.font(14),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: luna.verbum != null,
                    maintainState: true,
                    maintainAnimation: true,
                    maintainSize: true,
                    child: verbumIcon(),
                  ),
                ]),
              ),
            ),
          ]),
          // END PANEL
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: (cellSize(context) / aspectRatio) * cellsInColumn(context),
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              childAspectRatio: aspectRatio,
              crossAxisCount: cellsInRow(context),
              children:
                  [for (var i = 0; i < calendar.lunaMaxima(); i++) i].map((i) {
                double? score = luna[i] ?? luna.defVar;
                bool isEstimated = luna[i] == null && luna.defVar != null;

                Color bg, tc;
                if (score != null && score > 0) {
                  tc = Theme.of(context).colorScheme.onPrimary;
                  bg = (!Fortuna.night() ? Fortuna.cp : Fortuna.cpd).withAlpha(
                      ((score / ScoreUtils.MAX_RANGE) * 256).toInt() - 1);
                } else if (score != null && score < 0) {
                  tc = Theme.of(context).colorScheme.onPrimary;
                  bg = (!Fortuna.night() ? Fortuna.cs : Fortuna.csd).withAlpha(
                      ((-score / ScoreUtils.MAX_RANGE) * 256).toInt() - 1);
                } else {
                  tc = Theme.of(context).textTheme.bodyMedium!.color!;
                  bg = Colors.transparent;
                }

                String selectedNumType =
                    Fortuna.sp?.getString(BaseNumeral.key) ??
                        BaseNumeral.defType;
                bool enlarge = BaseNumeral.findById(selectedNumType).enlarge;

                return InkWell(
                  onTap: () => changeVar(context, lunaKey, luna, i),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bg,
                      border: !(lunaKey == todayLunaKey &&
                              todayCalendar.day == i + 1)
                          ? normalBorder
                          : Border.all(
                              width: 5,
                              color: Color(
                                  !Fortuna.night() ? 0x44000000 : 0x44FFFFFF),
                            ),
                    ),
                    child: Stack(children: [
                      Visibility(
                        visible: luna.emojis[i] != null,
                        child: Padding(
                          padding: EdgeInsets.only(left: 7, top: 5),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              luna.emojis[i] != null ? luna.emojis[i]! : '',
                              style: Fortuna.font(14),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: luna.verba[i] != null,
                        child: Padding(
                          padding: EdgeInsets.only(right: 6, top: 8),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: verbumIcon(tc),
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
                              style: Fortuna.font(
                                !enlarge ? 18 : 34,
                                color: tc,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              (isEstimated ? 'c. ' : '') + score.showScore(),
                              style: Fortuna.font(13, color: tc),
                            ),
                          ],
                        ),
                      )
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),
        ]);
      },
    );
  }

  DateTime rollCalendarInYears(DateTime calendar, bool up, [int times = 1]) {
    Jiffy jiffy = Jiffy.parseFromDateTime(calendar);
    if (up) {
      jiffy = jiffy.add(years: times);
    } else {
      jiffy = jiffy.subtract(years: times);
    }
    return jiffy.dateTime;
  }

  DateTime rollCalendarInMonths(DateTime calendar, bool up, [int times = 1]) {
    Jiffy jiffy = Jiffy.parseFromDateTime(calendar);
    if (up) {
      jiffy = jiffy.add(months: times);
    } else {
      jiffy = jiffy.subtract(months: times);
    }
    return jiffy.dateTime;
  }

  int cellsInRow(BuildContext c) {
    final screen = MediaQuery.of(c).size.width;
    if (screen < 900) {
      return 5;
    } else if (screen < 1200) {
      return 7;
    } else {
      return 10;
    }
  }

  dynamic cellsInColumn(BuildContext c) {
    switch (cellsInRow(c)) {
      case 5:
        return 8;
      case 7:
        return 5;
      default:
        return 4;
    }
  }

  dynamic cellSize(BuildContext c) =>
      MediaQuery.of(c).size.width / cellsInRow(c);

  Icon verbumIcon([Color? tc]) =>
      Icon(Icons.chat_sharp, color: tc ?? Fortuna.textColor(), size: 17);

  void changeVar(BuildContext c, String key, Luna luna, int? i) {
    int selectedVar = 6;
    String enteredEmoji = '', enteredVerbum = '';

    showCupertinoModalPopup(
      context: c,
      builder: (BuildContext context) {
        if (i != null && luna.diebus.length > i && luna.diebus[i] != null) {
          selectedVar = scoreToVariabilis(luna.diebus[i]!);
        } else if (luna.defVar != null) {
          selectedVar = scoreToVariabilis(luna.defVar!);
        } else {
          selectedVar = 6;
        }

        if (i != null) {
          enteredEmoji = luna.emojis[i] ?? '';
        } else {
          enteredEmoji = luna.emoji ?? '';
        }

        if (i != null) {
          enteredVerbum = luna.verba[i] ?? '';
        } else {
          enteredVerbum = luna.verbum ?? '';
        }

        return AlertDialog(
          title: Text((i != null) ? '$key.${z(i + 1)}' : s('defValue')),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              height: 200,
              child: Stack(children: [
                CupertinoPicker(
                  backgroundColor: Colors.transparent,
                  scrollController:
                      FixedExtentScrollController(initialItem: selectedVar),
                  useMagnifier: true,
                  magnification: 2,
                  squeeze: 0.7,
                  itemExtent: 30,
                  onSelectedItemChanged: (i) => selectedVar = i,
                  children: [
                    for (var i = 0; i <= 12; i++)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          variabilisToScore(i).showScore(),
                          style: Fortuna.font(18, bold: true),
                        ),
                      )
                  ],
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: TextFormField(
                      controller: TextEditingController()..text = enteredEmoji,
                      maxLines: 1,
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 19),
                      decoration: InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        hintText: luna.emoji ?? '😃',
                        hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                      inputFormatters: <TextInputFormatter>[
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          String entered = newValue.text;
                          if (oldValue.text.isNotEmpty) {
                            entered = entered.replaceFirst(oldValue.text, '');
                          }
                          return TextEditingValue(
                            text: (Fortuna.emojis.contains(entered))
                                ? entered
                                : '',
                          );
                        }),
                      ],
                      onChanged: (s) => enteredEmoji = s,
                    ),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, left: 10, right: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: TextFormField(
                    controller: TextEditingController()..text = enteredVerbum,
                    minLines: 1,
                    maxLines: 5,
                    textAlign: TextAlign.start,
                    keyboardType: TextInputType.text,
                    style: Fortuna.font(18),
                    decoration: InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                    ),
                    onChanged: (s) => enteredVerbum = s,
                  ),
                ),
              ),
            ),
          ]),
          actions: <MaterialButton>[
            MaterialButton(
              child: Text(
                s('clear'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onPressed: () {
                saveScore(c, key, luna, i, null, null, null);
              },
            ),
            MaterialButton(
              child: Text(
                s('cancel'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            MaterialButton(
              child: Text(
                s('save'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onPressed: () {
                saveScore(c, key, luna, i, variabilisToScore(selectedVar),
                    enteredEmoji, enteredVerbum);
                context.read<HomeCubit>().update();
                Navigator.of(context).pop();
                Fortuna.shake();
              },
            ),
          ],
        );
      },
    );
  }

  void saveScore(
    BuildContext context,
    String key,
    Luna luna,
    int? i,
    double? score,
    String? emoji,
    String? verbum,
  ) {
    if (verbum?.isEmpty == true) verbum = null;
    if (i != null) {
      luna.diebus[i] = score;
      luna.emojis[i] = emoji;
      luna.verba[i] = verbum;
    } else {
      luna.defVar = score;
      luna.emoji = emoji;
      luna.verbum = verbum;
    }
    context.read<Vita>().set(key, luna);
    context.read<HomeCubit>().update();
    Navigator.of(context).pop();
    Fortuna.shake();
  }
}

enum CalendarFields { years, months }
