import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'main.dart';
import 'numerals.dart';
import 'vita.dart';

class GridCubit extends CalendarCubit {}

class Grid extends StatelessWidget {
  const Grid({super.key});

  static int cellsInRow(BuildContext c) {
    final screen = MediaQuery.of(c).size.width;
    if (screen < 900) {
      return 5;
    } else if (screen < 1200) {
      return 7;
    } else {
      return 10;
    }
  }

  static cellsInColumn(BuildContext c) {
    switch (cellsInRow(c)) {
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
    final todayCalendar = DateTime.now();
    final todayLuna = todayCalendar.toKey();

    state.luna;
    if (Fortuna.vita![Fortuna.luna] == null) {
      Fortuna.vita![Fortuna.luna] = Fortuna.emptyLuna();
    }
    Luna luna = Fortuna.vita![Fortuna.luna]!;

    final normalBorder = Border.all(
        width: .5,
        color: !Fortuna.night()
            ? const Color(0xFFF0F0F0)
            : const Color(0xFF252525));

    return BlocBuilder<GridCubit, String>(
      buildWhen: (a, b) => true,
      builder: (context, calendar) => GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        childAspectRatio: aspectRatio,
        crossAxisCount: cellsInRow(context),
        children: [for (var i = 0; i < Fortuna.calendar.lunaMaxima(); i++) i]
            .map((i) {
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
                border: !(Fortuna.luna == todayLuna &&
                        todayCalendar.day == i + 1)
                    ? normalBorder
                    : Border.all(
                        width: 5,
                        color:
                            Color(!Fortuna.night() ? 0x44000000 : 0x44FFFFFF),
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
      ),
    );
  }
}
