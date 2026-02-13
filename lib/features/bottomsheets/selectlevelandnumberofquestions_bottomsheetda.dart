import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logic_mathematics/cores/configs/configs.dart';
import 'package:logic_mathematics/cores/db_storage/db_funtion.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:logic_mathematics/cores/models/option_quesion_model.dart';
import 'package:logic_mathematics/cores/widgets/button_select_level_widget.dart';
import 'package:logic_mathematics/l10n/l10n.dart';
import 'package:logic_mathematics/main.dart';

class SelectlevelandnumberofquestionsBottomsheetda extends StatefulWidget {
  const SelectlevelandnumberofquestionsBottomsheetda({super.key});

  @override
  State<SelectlevelandnumberofquestionsBottomsheetda> createState() =>
      _SelectlevelandnumberofquestionsBottomsheetdaState();
}

class _SelectlevelandnumberofquestionsBottomsheetdaState
    extends State<SelectlevelandnumberofquestionsBottomsheetda> {
  final _focusNode = FocusNode();

  final _textEditingController = TextEditingController();

  final cache = Shared.instance.numberOfQuestions.copyWith();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: InkWell(onTap: () => Navigator.pop(context))),
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  Configs.instance.commonRadiusBottomSheet,
                ),
                topRight: Radius.circular(
                  Configs.instance.commonRadiusBottomSheet,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppBar(
                    leading: SizedBox(),
                    backgroundColor: Colors.transparent,
                    title: Text(
                      context
                          .l10n
                          .selectlevelandnumberofquestionsBottomsheetdata,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    centerTitle: true,
                  ),
                  Padding(
                    padding: EdgeInsets.all(Configs.instance.commonPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.level,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.color
                                    ?.withValues(alpha: .5),
                              ),
                        ),
                        ButtonSelectLevelWidget(),
                        Text(
                          context.l10n.numberOfquestions,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.color
                                    ?.withValues(alpha: .5),
                              ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: Configs.instance.commonPadding,
                          ),
                          child: TextFormField(
                            focusNode: _focusNode,
                            controller: _textEditingController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(100),
                            ],
                            decoration: InputDecoration(
                              hintText: Shared
                                  .instance
                                  .numberOfQuestions
                                  .numberOfQuestions
                                  .toString(),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  Configs.instance.commonRadius,
                                ),
                                borderSide: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  Configs.instance.commonRadius,
                                ),
                                borderSide: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  Configs.instance.commonRadius,
                                ),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  Shared.instance.numberOfQuestions = cache;
                                  serviceLocator<DataBaseFuntion>()
                                      .saveNumberOfQuestionsAndDifficulty();
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: .1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      Configs.instance.commonRadius,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  context.l10n.cancel,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ),
                            SizedBox(width: Configs.instance.commonPadding),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_textEditingController.text.isNotEmpty) {
                                    Shared.instance.numberOfQuestions = Shared
                                        .instance
                                        .numberOfQuestions
                                        .copyWith(
                                          numberOfQuestions:
                                              int.tryParse(
                                                _textEditingController.text,
                                              ) ??
                                              20,
                                        );
                                  }
                                  serviceLocator<DataBaseFuntion>()
                                      .saveNumberOfQuestionsAndDifficulty()
                                      .then((value) {
                                        Navigator.pop(context);
                                      });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      Configs.instance.commonRadius,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  context.l10n.save,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: _focusNode.hasFocus
                        ? Shared.instance.paddingBottom
                        : 0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
