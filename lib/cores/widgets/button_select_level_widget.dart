import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/configs/configs.dart';
import 'package:logic_mathematics/cores/db_storage/db_funtion.dart';
import 'package:logic_mathematics/cores/enum/enum_difficulty_type.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:logic_mathematics/cores/extentions/utils.dart';
import 'package:logic_mathematics/cores/models/option_quesion_model.dart';
import 'package:logic_mathematics/main.dart';

class ButtonSelectLevelWidget extends StatefulWidget {
  const ButtonSelectLevelWidget({super.key});

  @override
  State<ButtonSelectLevelWidget> createState() =>
      _ButtonSelectLevelWidgetState();
}

class _ButtonSelectLevelWidgetState extends State<ButtonSelectLevelWidget> {
  final keyWidget = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: keyWidget,
      onTap: () =>
          showDialog(
            context: context,
            barrierColor: Colors.transparent,
            builder: (context) => PopupSelectLevel(
              padingTop:
                  getPosition(keyWidget).dy -
                  (50 + MediaQuery.of(Shared.instance.context).padding.top),
            ),
          ).then((value) {
            if (value != null) {
              Shared.instance.numberOfQuestions = Shared
                  .instance
                  .numberOfQuestions
                  .copyWith(option: value);
              setState(() {});
              serviceLocator<DataBaseFuntion>()
                  .saveNumberOfQuestionsAndDifficulty();
            }
          }),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: Configs.instance.commonPadding),
        width: double.infinity,
        height: 45,
        padding: EdgeInsets.all(Configs.instance.commonPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(Configs.instance.commonRadius),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Text(
          Shared.instance.numberOfQuestions.option,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(
              context,
            ).textTheme.titleSmall?.color?.withValues(alpha: .5),
          ),
        ),
      ),
    );
  }
}

class PopupSelectLevel extends StatefulWidget {
  const PopupSelectLevel({super.key, this.padingTop = 200});

  final double padingTop;

  @override
  State<PopupSelectLevel> createState() => _PopupSelectLevelState();
}

class _PopupSelectLevelState extends State<PopupSelectLevel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: widget.padingTop),
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: Configs.instance.commonPadding,
          ),
          padding: EdgeInsets.only(
            //top: Configs.instance.commonPadding,
            //bottom: Configs.instance.commonPadding,
            left: Configs.instance.commonPadding,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(Configs.instance.commonRadius),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Builder(
            builder: (context) {
              final list = Difficulty.values.toList();
              return ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) => _buildItem(index),
                separatorBuilder: (context, index) => Divider(height: 5),
                itemCount: list.length,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItem(int index) {
    return InkWell(
      onTap: () {
        Shared.instance.numberOfQuestions = Shared.instance.numberOfQuestions
            .copyWith(option: Difficulty.values[index].name);
        Navigator.pop(context, Difficulty.values[index].name);
        serviceLocator<DataBaseFuntion>().saveNumberOfQuestionsAndDifficulty();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level ${Difficulty.values[index].name}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            if (Shared.instance.numberOfQuestions.option ==
                Difficulty.values[index].name)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(Icons.check, color: Theme.of(context).primaryColor),
              ),
          ],
        ),
      ),
    );
  }
}
