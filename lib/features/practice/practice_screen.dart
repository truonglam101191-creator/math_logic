import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logic_mathematics/cores/adsmob/ads_mob.dart';
import 'package:logic_mathematics/cores/datas/topic_data.dart';
import 'package:logic_mathematics/cores/db_storage/db_funtion.dart';
import 'package:logic_mathematics/cores/enum/enum_question_type.dart';
import 'package:logic_mathematics/cores/extentions/messagingservice.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:logic_mathematics/cores/extentions/utils.dart';
import 'package:logic_mathematics/cores/models/math_question_model.dart';
import 'package:logic_mathematics/cores/widgets/ad_native_widget.dart';
import 'package:logic_mathematics/cores/widgets/app_bar_widget.dart';
import 'package:logic_mathematics/cores/widgets/gradient_button_widget.dart';
import 'package:logic_mathematics/cores/widgets/user_coin_widget.dart';
import 'package:logic_mathematics/features/analytics/stats_service.dart';
import 'package:logic_mathematics/features/bottomsheets/result_question_bottomsheet.dart';
import 'package:logic_mathematics/features/home/widgets/animated_scale_button.dart';
import 'package:logic_mathematics/features/in_app/in_app_product_page.dart';
import 'package:logic_mathematics/features/popups/discription_popup.dart';
import 'package:logic_mathematics/features/popups/option_sugget_popup.dart';
import 'package:logic_mathematics/features/popups/suggest_popup.dart';
import 'package:logic_mathematics/gen/assets.gen.dart';
import 'package:logic_mathematics/l10n/l10n.dart';
import 'package:logic_mathematics/main.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logic_mathematics/cores/analytics/usage_service.dart';
import 'package:logic_mathematics/cores/enum/usage_type.dart';

class PracticeScreen extends StatefulWidget {
  final String topic;
  final List<MathQuestion> questions;
  final Function(int) onEarnCoins;
  final TopicKey topicKey;
  const PracticeScreen({
    super.key,
    required this.topic,
    required this.questions,
    required this.onEarnCoins,
    required this.topicKey,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with SingleTickerProviderStateMixin {
  // final _controller = TextEditingController();
  int current = 0;
  String feedback = '';
  //bool answered = false;
  //bool isCompleted = false;
  int hints = 0;
  // Per-question selections / inputs so switching tabs keeps values
  late List<int?> _selectedChoices;
  late List<TextEditingController?> _simpleControllers;
  late List<List<TextEditingController>> _perBlankControllers;

  // Fixed options per question to avoid re-randomizing on every setState
  late List<List<String>?> _fixedOptions;

  double heightAdsBanner = 50;

  final _streamCheckAnswer = StreamController.broadcast();

  late final TabController _tabController;

  final inputDecoration = InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.blue),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    hintText: Shared.instance.context.l10n.enterAnswer,
    hintStyle: TextStyle(color: Colors.grey.shade400),
  );

  final keySuggest = GlobalKey();

  String idRecordAttempt = '';
  String? _sessionUsageId;
  String? _questionUsageId;

  @override
  void initState() {
    super.initState();
    _loadCompletion();
    _initPerQuestionState();
    _initFixedOptions();
    _tabController = TabController(length: widget.questions.length, vsync: this)
      ..addListener(() {
        if (_tabController.indexIsChanging == false) {
          // stop previous question timer and start new one
          //_stopQuestionTimer();
          setState(() {
            current = _tabController.index;
          });
          //_startQuestionTimer(current);
        }
      });
    // start session usage measurement
    _sessionUsageId = UsageService.instance.start(
      UsageType.practice,
      widget.topic,
      meta: {'topic': widget.topic, 'topicKey': widget.topicKey.toString()},
    );
    // start timing the first question
    // if (widget.questions.isNotEmpty) {
    //   _startQuestionTimer(current);
    // }
  }

  // Initialize fixed options for each question once (or when questions change)
  void _initFixedOptions() {
    _fixedOptions = List.generate(widget.questions.length, (i) {
      final q = widget.questions[i];
      // If question provides choicesAnswer (display object), prefer and shuffle it
      try {
        final ca = q.choicesAnswer;
        if (ca != null && ca is List && ca.isNotEmpty) {
          final list = List<String>.from(ca.map((e) => e.toString()));
          list.shuffle();
          return list;
        }
      } catch (_) {}

      if (q.choices != null && q.choices!.isNotEmpty) {
        // copy and shuffle to randomize display order
        final list = List<String>.from(q.choices!);
        list.shuffle();
        return list;
      }
      if (q.type == QuestionType.simple) {
        return _generateOptionsForSimple(q);
      }
      return null;
    });
  }

  // Initialize per-question controllers and selections
  void _initPerQuestionState() {
    _selectedChoices = List<int?>.filled(widget.questions.length, null);
    _simpleControllers = List<TextEditingController?>.filled(
      widget.questions.length,
      null,
    );
    _perBlankControllers = List<List<TextEditingController>>.generate(
      widget.questions.length,
      (i) {
        final q = widget.questions[i];
        if (q.type == QuestionType.fillBlanks) {
          return List.generate(
            q.blanks?.length ?? 0,
            (_) => TextEditingController(),
          );
        }
        return <TextEditingController>[];
      },
    );

    // create simple input controllers for simple-type questions if needed
    for (int i = 0; i < widget.questions.length; i++) {
      final q = widget.questions[i];
      if (q.type == QuestionType.simple) {
        _simpleControllers[i] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    // stop any running timers
    //stopQuestionTimer();
    if (_sessionUsageId != null) {
      UsageService.instance.stop(_sessionUsageId!);
    }
    super.dispose();
    _tabController.dispose();
    _streamCheckAnswer.close();
  }

  @override
  void didUpdateWidget(covariant PracticeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-init per-question state & fixed options when questions changed
    if (oldWidget.questions != widget.questions) {
      _initPerQuestionState();
      _initFixedOptions();
      _tabController.dispose();
      // recreate tabcontroller to match new length and keep listener
      // ignore: invalid_use_of_protected_member
      _tabController =
          TabController(length: widget.questions.length, vsync: this)
            ..addListener(() {
              if (_tabController.indexIsChanging == false) {
                setState(() {
                  current = _tabController.index;
                });
              }
            });
    }
  }

  Future<void> _loadCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      //isCompleted = prefs.getBool('completed_${widget.topic}') ?? false;
      hints = prefs.getInt('hints_${widget.topic}') ?? 0;
    });
  }

  Future<void> _saveCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('completed_${widget.topic}', true);
  }

  Future<void> _saveHints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hints_${widget.topic}', hints);
  }

  void checkAnswer() {
    //if (answered) return;
    if (widget.questions.isEmpty) return;

    final q = widget.questions[current];
    final sel = _selectedChoices[current];
    final simpleCtrl = _simpleControllers[current];
    final blankCtrls = _perBlankControllers[current];

    // If we have fixed options for this question (generated or provided),
    // treat selection as a choice-answer regardless of q.type.
    final optionsForThis = (_fixedOptions.length > current)
        ? _fixedOptions[current]
        : null;
    if (optionsForThis != null && optionsForThis.isNotEmpty) {
      if (sel != null && sel >= 0 && sel < optionsForThis.length) {
        final selectedText = optionsForThis[sel];
        q.userAnswers = selectedText;
        // Prefer numeric comparison if both can be parsed to int
        final selNum = int.tryParse(selectedText);
        final ansNum = int.tryParse(q.answer.toString());
        if (selNum != null && ansNum != null) {
          q.correct = selNum == ansNum;
        } else {
          q.correct = selectedText == q.answer.toString();
        }
      } else {
        q.userAnswers = null;
        q.correct = false;
      }
      _streamCheckAnswer.add(null);
      return;
    }

    //bool correct = false;
    if (q.type == QuestionType.simple) {
      // Nếu là dạng chẵn/lẻ thì kiểm tra theo radio
      if (q.question.contains(Shared.instance.context.l10n.evenOddC)) {
        // correct =
        //     (selectedChoice != null &&
        //     ((selectedChoice == 0 &&
        //             q.answer == Shared.instance.context.l10n.even) ||
        //         (selectedChoice == 1 &&
        //             q.answer == Shared.instance.context.l10n.odd)));
        q.correct =
            sel != null &&
            ((sel == 0 && q.answer == Shared.instance.context.l10n.even) ||
                (sel == 1 && q.answer == Shared.instance.context.l10n.odd));
        q.userAnswers = sel == 0
            ? Shared.instance.context.l10n.even
            : (sel == 1 ? Shared.instance.context.l10n.odd : null);
      } else if (q.question.contains('___ +') || q.question.contains('... +')) {
        // Dạng điền số còn thiếu phép cộng
        q.correct = int.tryParse(simpleCtrl?.text ?? '') == q.answer;
        q.userAnswers = (simpleCtrl?.text.isNotEmpty ?? false)
            ? simpleCtrl!.text.trim()
            : null;
      } else if (q.question.contains('___ x') || q.question.contains('... x')) {
        // Dạng điền số còn thiếu phép nhân
        //correct = int.tryParse(_controller.text) == q.answer;
        q.correct = int.tryParse(simpleCtrl?.text ?? '') == q.answer;
        q.userAnswers = simpleCtrl?.text.trim();
      } else {
        // kiểm tra dạng sô
        // Kiểm tra nếu đáp án là số hợp lệ
        final answer = int.tryParse(simpleCtrl?.text ?? '');
        if (answer != null) {
          //correct = answer == q.answer;
          q.correct = answer == q.answer;
          q.userAnswers = (simpleCtrl?.text.isNotEmpty ?? false)
              ? simpleCtrl!.text.trim()
              : null;
        } else {
          //correct = _controller.text == q.answer;
          q.correct = (simpleCtrl?.text ?? '') == q.answer;
          q.userAnswers = (simpleCtrl?.text.isNotEmpty ?? false)
              ? simpleCtrl!.text.trim()
              : null;
        }
      }
    } else if (q.type == QuestionType.multipleChoice) {
      // Dạng so sánh số hoặc số lớn nhất/nhỏ nhất
      if (q.question.contains(
            Shared.instance.context.l10n.chooseThecorrectsign,
          ) ||
          q.question.contains(
            Shared.instance.context.l10n.maximumNumberamongC,
          )) {
        q.correct =
            sel != null &&
            q.choices != null &&
            q.choices![sel] == q.answer.toString();
        q.userAnswers = sel != null ? q.choices![sel] : null;
      } else {
        q.correct = sel == q.choices?.indexOf(q.answer.toString());
        q.userAnswers = sel != null ? q.choices![sel] : null;
      }
    } else if (q.type == QuestionType.fillBlanks) {
      final userAnswers = blankCtrls
          .map((c) => c.text.trim())
          .toList(growable: false);
      final ansList = q.answer as List;
      q.correct =
          userAnswers.length == ansList.length &&
          List.generate(
            userAnswers.length,
            (i) => userAnswers[i] == ansList[i],
          ).every((e) => e);
      q.userAnswers = userAnswers.isNotEmpty ? userAnswers : null;
    }
    _streamCheckAnswer.add(null);
  }

  void nextQuestion() async {
    if (widget.questions[current].userAnswers == null) {
      return;
    }
    if (current < widget.questions.length - 1) {
      setState(() {
        // move to next tab; TabController listener will update `current`
        // stop timing for this question and let listener start the next
        // _stopQuestionTimer();
        _tabController.animateTo(current + 1);
        feedback = '';
        //answered = false;
        // do not wipe per-question stored inputs here
        _simpleControllers[current]?.clear();
      });
    } else {
      feedback = 'Bạn đã hoàn thành tất cả bài toán!';
      //isCompleted = true;

      await _saveCompletion();
      // stop timers and record session
      //_stopQuestionTimer();
      if (_sessionUsageId != null) {
        UsageService.instance.stop(
          _sessionUsageId!,
          extraMeta: {
            'completed': true,
            'total_questions': widget.questions.length,
          },
        );
      }
    }
  }

  // void _startQuestionTimer(int index) {
  //   try {
  //     _questionUsageId = UsageService.instance.start(
  //       UsageType.question,
  //       'question_${index + 1}',
  //       meta: {'index': index, 'topic': widget.topic},
  //     );
  //   } catch (_) {}
  // }

  // void _stopQuestionTimer() {
  //   try {
  //     if (_questionUsageId != null) {
  //       UsageService.instance.stop(_questionUsageId!);
  //       _questionUsageId = null;
  //     }
  //   } catch (_) {}
  // }

  void buyHint() async {
    widget.onEarnCoins(-5); // Trừ 5 xu
    setState(() {
      hints++;
    });
    await _saveHints();
  }

  void showPopupSusggest() {
    final paddingBottom = Device.height - getPosition(keySuggest).dy - 10;
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => SuggestPopup(
        paddingBottom: paddingBottom,
        result: widget.questions[current].answer.toString(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: Text(
          widget.topic,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: Center(
          child: AnimatedScaleButton(
            onPressed: () => Navigator.pop(context),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AssetsImages.icons.iconArrowRight.svg(
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
          ),
        ),
        actions: [
          UserCoinWidget(),
          // IconButton(
          //   onPressed: () => showDialog(
          //     context: context,
          //     builder: (context) => DiscriptionPopup(),
          //   ),
          //   icon: Icon(
          //     Icons.info_outline,
          //     color: Theme.of(context).iconTheme.color,
          //   ),
          // ),
        ],
      ),
      body: _buildBody,
    );
  }

  Widget get _buildBody {
    //final q = widget.questions.isNotEmpty ? widget.questions[current] : null;
    return SafeArea(
      top: false,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            bottom: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Builder(
                            builder: (context) {
                              final total = widget.questions.isEmpty
                                  ? 1
                                  : widget.questions.length;
                              final target = (current + 1) / total;
                              return TweenAnimationBuilder<double>(
                                tween: Tween<double>(end: target),
                                duration: const Duration(milliseconds: 450),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) =>
                                    LinearProgressIndicator(
                                      value: value.clamp(0.0, 1.0),
                                      minHeight: 12,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation(
                                        Color(0xff9AE59E),
                                      ),
                                    ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // SizedBox(height: 12),

                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16),
                //   child: Container(
                //     width: Device.width / 2,
                //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.circular(22),
                //       border: Border.all(color: Colors.green.shade50),
                //       boxShadow: [
                //         BoxShadow(
                //           color: Colors.black.withOpacity(0.03),
                //           blurRadius: 6,
                //         ),
                //       ],
                //     ),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Row(
                //           children: [
                //             Icon(Icons.emoji_events, color: Colors.orange.shade400),
                //             SizedBox(width: 8),
                //             Text(
                //               Shared.instance.context.l10n.practice_score,
                //               style: TextStyle(color: Colors.grey.shade700),
                //             ),
                //           ],
                //         ),
                //         SizedBox(height: 8),
                //         Text(
                //           '${widget.questions.where((q) => q.userAnswers != null).length} / ${widget.questions.length}',
                //           style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                //             fontWeight: FontWeight.bold,
                //             fontSize: 28,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                SizedBox(height: 18),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      for (
                        int index = 0;
                        index < widget.questions.length;
                        index++
                      )
                        SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              SizedBox(height: 12),
                              // Question card
                              Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.only(top: 12),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 36,
                                      horizontal: 18,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.06),
                                          blurRadius: 12,
                                          offset: Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        SizedBox(height: 6),
                                        Text(
                                          widget.questions[index].question,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 44,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xff061A18),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Question index bubble (top-right)
                                  Positioned(
                                    right: 22,
                                    top: 0,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        // use localization with placeholders
                                        Shared.instance.context.l10n
                                            .practice_question_index(
                                              (index + 1),
                                              widget.questions.length,
                                            ),
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 26),

                              Builder(
                                builder: (context) {
                                  // Use precomputed shuffled list if available, otherwise fallback
                                  final options =
                                      (_fixedOptions.length > index &&
                                          _fixedOptions[index] != null)
                                      ? _fixedOptions[index]!
                                      : (List<String>.from(
                                          widget.questions[index].choicesAnswer
                                              .map((e) => e.toString()),
                                        ));

                                  return GridView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 10,
                                          crossAxisSpacing: 10,
                                          mainAxisExtent: 85,
                                        ),
                                    itemCount: options.length,
                                    itemBuilder:
                                        (BuildContext context, int optIndex) {
                                          return _buildOption(
                                            text: options[optIndex],
                                            index: optIndex,
                                            onTap: () {
                                              setState(() {
                                                // store selection per-question
                                                _selectedChoices[index] =
                                                    optIndex;
                                                current = index;
                                                widget
                                                        .questions[index]
                                                        .userAnswers =
                                                    options[_selectedChoices[index]!];
                                                checkAnswer();
                                              });
                                            },
                                            isSelected:
                                                _selectedChoices[index] ==
                                                optIndex,
                                          );
                                        },
                                  );
                                },
                              ),
                              SizedBox(height: 24),
                              AdNativeWidget(),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Bottom action row (Next & Suggest)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: StreamBuilder(
                      stream: _streamCheckAnswer.stream,
                      builder: (context, snapshot) {
                        return GradientButtonWidget(
                          isBoolUnselected:
                              widget.questions[current].userAnswers == null,
                          onPressed: () {
                            if (current < widget.questions.length - 1) {
                              nextQuestion();
                            } else {
                              StatsService()
                                  .recordAttempt(
                                    topicName: widget.topic,
                                    correct: widget.questions
                                        .where((q) => q.correct)
                                        .length,
                                    incorrect: widget.questions
                                        .where((q) => !q.correct)
                                        .length,
                                    idAttemp: idRecordAttempt,
                                    topicKey: widget.topicKey,
                                  )
                                  .then((value) {
                                    idRecordAttempt = value;
                                  });

                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (context) => ResultQuestionBottomsheet(
                                  questions: widget.questions,
                                  topicName: widget.topic,
                                ),
                              ).then((value) {
                                if (value == true) {
                                  Navigator.pop(context);
                                }
                              });
                            }
                          },
                          child: Text(
                            current == widget.questions.length - 1
                                ? Shared.instance.context.l10n.result
                                : Shared.instance.context.l10n.next,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 30,
            bottom: 60,
            child: InkWell(
              key: keySuggest,
              onTap: () async {
                // final getCoin = await serviceLocator<DataBaseFuntion>()
                //     .getStar();
                // if (getCoin < 1) {
                //   serviceLocator<AdmobController>().showInterstitialAd(
                //     callback: (isSucess) => {
                //       if (isSucess)
                //         {showPopupSusggest()}
                //       else
                //         {
                //           Navigator.push(
                //             context,
                //             createRouter(InAppProductPage()),
                //           ),
                //         },
                //     },
                //   );
                // } else {
                //   if (!widget.questions[current].isBuy) {
                //     widget.questions[current].isBuy = true;
                //     serviceLocator<DataBaseFuntion>()
                //         .saveStar(getCoin - 1)
                //         .then((value) {
                //           serviceLocator<MessagingService>().send(
                //             channel: MessageChannel.startUserChanged,
                //             parameter: '',
                //           );
                //         });
                //   }
                //   showPopupSusggest();
                // }
                if (widget.questions[current].isBuy) {
                  showPopupSusggest();
                  return;
                }
                OptionSuggestPopup.show(
                  context,
                  onUseCoin: () async {
                    final getCoin = await serviceLocator<DataBaseFuntion>()
                        .getStar();
                    if (getCoin >= 1) {
                      if (!widget.questions[current].isBuy) {
                        widget.questions[current].isBuy = true;
                        serviceLocator<DataBaseFuntion>()
                            .saveStar(getCoin - 2)
                            .then((value) {
                              serviceLocator<MessagingService>().send(
                                channel: MessageChannel.startUserChanged,
                                parameter: '',
                              );
                            });
                      }
                      showPopupSusggest();
                    } else {
                      Navigator.push(context, createRouter(InAppProductPage()));
                    }
                  },
                  onWatchVideo: () {
                    serviceLocator.get<AdmobController>().showInterstitialAd(
                      callback: (isSuccess) {
                        if (isSuccess) {
                          showPopupSusggest();
                        } else {
                          Fluttertoast.showToast(
                            msg: Shared
                                .instance
                                .context
                                .l10n
                                .ads_not_ready_please_try_again_later,
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.black54,
                            textColor: Colors.white,
                          );
                        }
                      },
                    );
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC700),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    Icons.question_mark,
                    color: const Color(0xFFFFC700),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper: build each big option button
  Widget _buildOption({
    required String text,
    required int index,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            height: 84,
            decoration: BoxDecoration(
              color: isSelected ? Color(0xff4EE76E) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: isSelected ? Color(0xff06A954) : Colors.grey.shade100,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.black : Color(0xff061A18),
              ),
            ),
          ),
          if (isSelected)
            Positioned(
              right: 12,
              top: 8,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Color(0xff0AB23F),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 18, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // Helper: when question simple and no choices, generate 4 options incl. correct
  List<String> _generateOptionsForSimple(MathQuestion q) {
    final ans = int.tryParse(q.answer.toString());
    if (ans == null) {
      return [q.answer.toString()];
    }
    final rnd = Random();
    final Set<int> set = {ans};
    while (set.length < 4) {
      int delta = (rnd.nextInt(5) + 1) * (rnd.nextBool() ? 1 : -1);
      set.add(ans + delta);
    }
    return set.map((e) => e.toString()).toList()..shuffle();
  }
}

class CustomNumberFormatter extends TextInputFormatter {
  final Set<String> bannedKeys;

  CustomNumberFormatter({this.bannedKeys = const {}});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Regex chỉ cho số
    final regex = RegExp(r'^[0-9]*$');
    final newText = newValue.text;

    // Nếu ký tự mới không phải số → giữ nguyên text cũ
    if (!regex.hasMatch(newText)) {
      return oldValue;
    }

    // Nếu ký tự mới có chứa ký tự bị cấm → giữ nguyên text cũ
    for (var banned in bannedKeys) {
      if (newText.endsWith(banned)) {
        return oldValue;
      }
    }

    // Ngược lại → chấp nhận
    return newValue;
  }
}
