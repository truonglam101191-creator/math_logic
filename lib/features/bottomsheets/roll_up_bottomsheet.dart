import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/db_storage/db_funtion.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:logic_mathematics/cores/utils/fraction_utils.dart';
import 'package:logic_mathematics/features/home/widgets/animated_scale_button.dart';
import 'package:logic_mathematics/gen/assets.gen.dart';
import 'package:logic_mathematics/l10n/l10n.dart';
import 'package:logic_mathematics/main.dart';

class RollUpBottomsheet extends StatefulWidget {
  const RollUpBottomsheet({super.key});

  @override
  State<RollUpBottomsheet> createState() => _RollUpBottomsheetState();
}

class _RollUpBottomsheetState extends State<RollUpBottomsheet> {
  final List<DateTime> listDayCheckIns = [];

  final dateNow = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    serviceLocator<DataBaseFuntion>().getCheckInDates().then((value) {
      listDayCheckIns.addAll(value);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: InkWell(onTap: () => Navigator.of(context).pop()),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                spacing: 10,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.rollCall,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: AppColors.gradientPremium,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gradientPremium.first.withOpacity(
                            0.3,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: getCurrentWeekDates()
                          .map(
                            (date) => Expanded(
                              child: Column(
                                spacing: 5,
                                children: [
                                  Text(
                                    date.day.toString(),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Builder(
                                    builder: (context) {
                                      return listDayCheckIns.isNotEmpty
                                          ? listDayCheckIns.any(
                                                  (d) =>
                                                      d.year == date.year &&
                                                      d.month == date.month &&
                                                      d.day == date.day,
                                                )
                                                ? Icon(
                                                    Icons.check_circle,
                                                    color: Colors.white,
                                                  )
                                                : Icon(
                                                    Icons.info,
                                                    color:
                                                        listDayCheckIns.last
                                                            .isAfter(date)
                                                        ? Colors.white
                                                        : Colors.transparent,
                                                  )
                                          : dateNow.year <= date.year &&
                                                dateNow.month <= date.month &&
                                                dateNow.day <= date.day
                                          ? dateNow.year == date.year &&
                                                    dateNow.month ==
                                                        date.month &&
                                                    dateNow.day == date.day
                                                ? Icon(
                                                    Icons.timelapse,
                                                    color: Colors.white,
                                                  )
                                                : Icon(
                                                    Icons.info,
                                                    color: Colors.transparent,
                                                  )
                                          : Icon(
                                              Icons.info,
                                              color: Colors.white,
                                            );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  AssetsImages.images.imageStar.image(width: 80),
                  Text(
                    context.l10n.checkIndailytoreceive30coins.replaceAll(
                      '2',
                      '5',
                    ),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: 10),
                  AnimatedScaleButton(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color:
                            !listDayCheckIns.any(
                              (element) =>
                                  element.day == dateNow.day &&
                                  element.month == dateNow.month &&
                                  element.year == dateNow.year,
                            )
                            ? Theme.of(context).primaryColor
                            : Colors.grey,

                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color:
                                !listDayCheckIns.any(
                                  (element) =>
                                      element.day == dateNow.day &&
                                      element.month == dateNow.month &&
                                      element.year == dateNow.year,
                                )
                                ? Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.5)
                                : Colors.grey.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(context.l10n.checkIn),
                    ),
                    onPressed: () {
                      if (listDayCheckIns.any(
                        (element) =>
                            element.day == dateNow.day &&
                            element.month == dateNow.month &&
                            element.year == dateNow.year,
                      )) {
                        return;
                      }
                      Navigator.of(context).pop(true);
                    },
                  ),
                  // TextButton(
                  //   onPressed: () {
                  //     if (listDayCheckIns.any(
                  //       (element) =>
                  //           element.day == dateNow.day &&
                  //           element.month == dateNow.month &&
                  //           element.year == dateNow.year,
                  //     )) {
                  //       return;
                  //     }
                  //     Navigator.of(context).pop(true);
                  //   },
                  //   style: TextButton.styleFrom(
                  //     backgroundColor:
                  //         !listDayCheckIns.any(
                  //           (element) =>
                  //               element.day == dateNow.day &&
                  //               element.month == dateNow.month &&
                  //               element.year == dateNow.year,
                  //         )
                  //         ? Theme.of(context).primaryColor
                  //         : Colors.grey,
                  //     foregroundColor: Colors.white,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(100),
                  //     ),
                  //   ),
                  //   child: Text(
                  //     context.l10n.checkIn,
                  //     style: Theme.of(
                  //       context,
                  //     ).textTheme.titleSmall?.copyWith(color: Colors.white),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
