import 'dart:math';
import 'package:logic_mathematics/cores/enum/enum_difficulty_type.dart';
import 'package:logic_mathematics/cores/enum/enum_question_type.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:logic_mathematics/cores/models/math_question_model.dart';
import 'package:logic_mathematics/gen/assets.gen.dart';
import 'package:logic_mathematics/l10n/l10n.dart';

// Enum of available topics (kept in sync with TopicData.allTopics)
enum TopicKey {
  addition,
  subtraction,
  basicMath,
  mathlogic,
  funGeometry,
  advancedArithmetic,
  specialChallenge,
  probabilityMath,
  visualLogicMath, // first visual logic topic
  timeMath,
  sequenceMath,
  deductiveLogicMath,
  divisionMath,
  comprehensiveArithmetic,
  visualLogicMath2, // second visual logic topic (distinct key)
  primeNumberMath,
  perfectNumberMath,
  fibonacciMath,
  palindromeNumberMath,
  oddEvenNumberMath,
  powerAndRootMath,
  moduloMath,
}

class TopicData {
  final TopicKey key;
  final String title;
  final AssetGenImage path;
  final List<Difficulty> supportedDifficulties;
  final List<QuestionType> supportedTypes;
  final List<String>? description;
  final List<String>? images;
  final List<MathQuestion> Function(Difficulty, int) generateQuestions;

  TopicData({
    required this.key,
    required this.title,
    required this.generateQuestions,
    required this.path,
    this.supportedDifficulties = const [
      Difficulty.easy,
      Difficulty.medium,
      Difficulty.hard,
    ],
    this.supportedTypes = const [
      QuestionType.simple,
      QuestionType.multipleChoice,
      QuestionType.fillBlanks,
    ],
    this.description,
    this.images,
  });

  static final List<TopicData> allTopics = [
    TopicData(
      key: TopicKey.addition,
      title: Shared.instance.context.l10n.addition,
      path: AssetsImages.images.imageAdvancedArithmetic,
      generateQuestions: (difficulty, count) {
        final rand = Random();
        final List<MathQuestion> result = [];
        for (int i = 0; i < count; i++) {
          int a, b;
          if (difficulty == Difficulty.easy) {
            a = rand.nextInt(10) + 1;
            b = rand.nextInt(10) + 1;
          } else if (difficulty == Difficulty.medium) {
            a = rand.nextInt(91) + 10; // 10-100
            b = rand.nextInt(91) + 10;
          } else {
            a = rand.nextInt(401) + 100; // 100-500
            b = rand.nextInt(401) + 100;
          }
          result.add(
            MathQuestion(
              '$a + $b = ?',
              a + b,
              difficulty: difficulty,
              choicesAnswer: [
                (a + b).toString(),
                (a + b + rand.nextInt(10) + 1).toString(),
                (a + b - (rand.nextInt(10) + 1)).toString(),
                (a + b + rand.nextInt(10)).toString(),
              ],
            ),
          );
        }
        return result;
      },
    ),

    TopicData(
      key: TopicKey.subtraction,
      title: Shared.instance.context.l10n.subtraction,
      path: AssetsImages.images.imageAdvancedArithmetic,
      generateQuestions: (difficulty, count) {
        final rand = Random();
        final List<MathQuestion> result = [];
        for (int i = 0; i < count; i++) {
          int a, b;
          if (difficulty == Difficulty.easy) {
            a = rand.nextInt(10) + 1;
            b = rand.nextInt(10) + 1;
          } else if (difficulty == Difficulty.medium) {
            a = rand.nextInt(91) + 10; // 10-100
            b = rand.nextInt(91) + 10;
          } else {
            a = rand.nextInt(401) + 100; // 100-500
            b = rand.nextInt(401) + 100;
          }
          if (a < b) {
            final t = a;
            a = b;
            b = t;
          }
          final answer = a - b;
          result.add(
            MathQuestion(
              '$a - $b = ?',
              answer,
              difficulty: difficulty,
              choicesAnswer: [
                answer.toString(),
                (answer + rand.nextInt(10) + 1).toString(),
                (answer - rand.nextInt(10) - 1).abs().toString(),
                (answer + rand.nextInt(5) + 1).toString(),
              ],
            ),
          );
        }
        return result;
      },
    ),
    TopicData(
      key: TopicKey.basicMath,
      title: Shared.instance.context.l10n.basicMath,
      path: AssetsImages.images.imageBasicMathematicalThinking,
      generateQuestions: (difficulty, count) {
        final rand = Random();
        List<MathQuestion> result = [];
        for (int i = 0; i < count; i++) {
          int a, b, op;
          if (difficulty == Difficulty.easy) {
            a = rand.nextInt(10) + 1;
            b = rand.nextInt(10) + 1;
          } else if (difficulty == Difficulty.medium) {
            a = rand.nextInt(91) + 10; // 10-100
            b = rand.nextInt(91) + 10;
          } else {
            a = rand.nextInt(401) + 100; // 100-500
            b = rand.nextInt(401) + 100;
          }
          op = rand.nextInt(8); // tăng số dạng lên 8
          if (op == 0) {
            final answer = a + b;
            result.add(
              MathQuestion(
                '$a + $b = ?',
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  (answer + rand.nextInt(10) + 1).toString(),
                  (answer - rand.nextInt(10) - 1).abs().toString(),
                  (answer + rand.nextInt(5) + 1).toString(),
                ],
              ),
            );
          } else if (op == 1) {
            if (a < b) {
              final tmp = a;
              a = b;
              b = tmp;
            }
            final answer = a - b;
            result.add(
              MathQuestion(
                '$a - $b = ?',
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  (answer + rand.nextInt(10) + 1).toString(),
                  (answer - rand.nextInt(10) - 1).abs().toString(),
                  (answer + rand.nextInt(5) + 1).toString(),
                ],
              ),
            );
          } else if (op == 2) {
            final answer = a * b;
            result.add(
              MathQuestion(
                '$a x $b = ?',
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  (answer + rand.nextInt(20) + 1).toString(),
                  (answer - rand.nextInt(20) - 1).abs().toString(),
                  (answer + rand.nextInt(10) + 1).toString(),
                ],
              ),
            );
          } else if (op == 3) {
            // Dạng so sánh số
            List<String> choices = ['>', '<', '='];
            String sign = a > b ? '>' : (a < b ? '<' : '=');
            result.add(
              MathQuestion(
                '$a ... $b (${Shared.instance.context.l10n.chooseThecorrectsign})',
                sign,
                type: QuestionType.multipleChoice,
                choices: choices,
                difficulty: difficulty,
                choicesAnswer: [sign, choices],
              ),
            );
          } else if (op == 4) {
            // Dạng điền số còn thiếu phép cộng
            int sum = a + b;
            result.add(
              MathQuestion(
                '___ + $b = $sum (${Shared.instance.context.l10n.fillInthemissingnumber})',
                a,
                type: QuestionType.simple,
                difficulty: difficulty,
                choicesAnswer: [
                  a.toString(),
                  a + rand.nextInt(10) + 1,
                  a - (rand.nextInt(10) + 1).abs(),
                  a + rand.nextInt(10),
                ],
              ),
            );
          } else if (op == 5) {
            // Dạng điền số còn thiếu phép nhân
            int prod = a * b;
            result.add(
              MathQuestion(
                '___ x $b = $prod (${Shared.instance.context.l10n.fillInthemissingnumber})',
                a,
                type: QuestionType.simple,
                difficulty: difficulty,
                choicesAnswer: [
                  a,
                  a + rand.nextInt(10) + 1,
                  (a - (rand.nextInt(10) + 1)).abs(),
                  a + rand.nextInt(10),
                ],
              ),
            );
          } else if (op == 6) {
            // Dạng số lớn nhất/nhỏ nhất
            int c = (difficulty == Difficulty.easy)
                ? rand.nextInt(10) + 1
                : (difficulty == Difficulty.medium)
                ? rand.nextInt(91) + 10
                : rand.nextInt(401) + 100;
            List<int> nums = [a, b, c];
            nums.shuffle();
            List<String> choices = nums.map((e) => e.toString()).toList();
            int maxVal = nums.reduce((v, e) => v > e ? v : e);
            result.add(
              MathQuestion(
                //'Số lớn nhất trong các số: ${nums.join(', ')} là?',
                Shared.instance.context.l10n.maximumnumber(nums.join(', ')),
                maxVal.toString(),
                type: QuestionType.multipleChoice,
                choices: choices,
                difficulty: difficulty,
                choicesAnswer: [maxVal.toString(), choices],
              ),
            );
          } else {
            // Dạng số chẵn/lẻ
            final answer = a % 2 == 0
                ? Shared.instance.context.l10n.even
                : Shared.instance.context.l10n.odd;
            result.add(
              MathQuestion(
                '$a ${Shared.instance.context.l10n.isItevenorodd}',
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  Shared.instance.context.l10n.even,
                  Shared.instance.context.l10n.odd,
                  Shared.instance.context.l10n.either,
                  '?',
                ],
              ),
            );
          }
        }
        return result;
      },
    ),
    TopicData(
      key: TopicKey.mathlogic,
      title: Shared.instance.context.l10n.mathlogic,
      path: AssetsImages.images.imageLogicMathematics,
      generateQuestions: (difficulty, count) {
        final rand = Random();
        List<MathQuestion> result = [];
        for (int i = 0; i < count; i++) {
          int a, b;
          if (difficulty == Difficulty.easy) {
            a = rand.nextInt(10) + 1;
            b = rand.nextInt(10) + 1;
          } else if (difficulty == Difficulty.medium) {
            a = rand.nextInt(91) + 10; // 10-100
            b = rand.nextInt(91) + 10;
          } else {
            a = rand.nextInt(401) + 100; // 100-500
            b = rand.nextInt(401) + 100;
          }
          result.add(
            MathQuestion(
              //'Nếu $a + $b = ${a + b}, thì $a là số nào?',
              Shared.instance.context.l10n.ifExpressionresultthenwhatisunknown(
                'x + $b ',
                '${a + b}',
                'x',
              ),
              a,
              difficulty: difficulty,
              choicesAnswer: [
                a.toString(),
                (a + rand.nextInt(10) + 1).toString(),
                (a - rand.nextInt(5) - 1).abs().toString(),
                (a + rand.nextInt(5) + 1).toString(),
              ],
            ),
          );
          result.add(
            MathQuestion(
              //'Nếu $a + $b = ${a + b}, thì $a là số nào?',
              Shared.instance.context.l10n.ifExpressionresultthenwhatisunknown(
                '$a + x ',
                '${a + b}',
                'x',
              ),
              b,
              difficulty: difficulty,
              choicesAnswer: [
                b.toString(),
                (b + rand.nextInt(10) + 1).toString(),
                (b - rand.nextInt(5) - 1).abs().toString(),
                (b + rand.nextInt(5) + 1).toString(),
              ],
            ),
          );
          result.add(
            MathQuestion(
              //'Nếu $a - $b = ${a - b}, thì $a là số nào?',
              Shared.instance.context.l10n.ifExpressionresultthenwhatisunknown(
                'x - $b ',
                '${a - b}',
                'x',
              ),
              a,
              difficulty: difficulty,
              choicesAnswer: [
                a.toString(),
                (a + rand.nextInt(10) + 1).toString(),
                (a - rand.nextInt(5) - 1).abs().toString(),
                (a + rand.nextInt(5) + 1).toString(),
              ],
            ),
          );
          result.add(
            MathQuestion(
              //'Nếu $a - $b = ${a - b}, thì $a là số nào?',
              Shared.instance.context.l10n.ifExpressionresultthenwhatisunknown(
                '$a - x ',
                '${a - b}',
                'x',
              ),
              b,
              difficulty: difficulty,
              choicesAnswer: [
                b.toString(),
                (b + rand.nextInt(10) + 1).toString(),
                (b - rand.nextInt(5) - 1).abs().toString(),
                (b + rand.nextInt(5) + 1).toString(),
              ],
            ),
          );
        }
        return result;
      },
    ),
    TopicData(
      key: TopicKey.funGeometry,
      title: Shared.instance.context.l10n.funGeometry,
      path: AssetsImages.images.imageFunGeometry,
      generateQuestions: (difficulty, count) {
        final rand = Random();
        List<MathQuestion> result = [];
        for (int i = 0; i < count; i++) {
          if (difficulty == Difficulty.easy) {
            // Tổng góc trong đa giác: số cạnh bằng số góc
            int sides = rand.nextInt(6) + 3;
            result.add(
              MathQuestion(
                Shared.instance.context.l10n.totalAnglesOfShape(
                  sides.toString(),
                ),
                sides,
                difficulty: difficulty,
                choicesAnswer: [
                  sides.toString(),
                  (sides + 1).toString(),
                  (sides - 1).toString(),
                  (sides + 2).toString(),
                ],
              ),
            );

            // Ngẫu nhiên: diện tích hình vuông hoặc diện tích tam giác (số nguyên)
            if (rand.nextBool()) {
              int a = rand.nextInt(9) + 2;
              int area = a * a;
              result.add(
                MathQuestion(
                  Shared.instance.context.l10n.squareArea(a.toString()),
                  area,
                  difficulty: difficulty,
                  choicesAnswer: [
                    area.toString(),
                    (area + rand.nextInt(10) + 1).toString(),
                    (area - rand.nextInt(5) - 1).abs().toString(),
                    (area + rand.nextInt(5) + 2).toString(),
                  ],
                ),
              );
            } else {
              int base = (rand.nextInt(9) + 2) * 2; // chẵn để area nguyên
              int height = rand.nextInt(9) + 2;
              int area = (base * height) ~/ 2;
              result.add(
                MathQuestion(
                  Shared.instance.context.l10n.triangleArea(
                    base.toString(),
                    height.toString(),
                  ),
                  area,
                  difficulty: difficulty,
                  choicesAnswer: [
                    area.toString(),
                    (area + rand.nextInt(10) + 1).toString(),
                    (area - rand.nextInt(5) - 1).abs().toString(),
                    (area + rand.nextInt(5) + 2).toString(),
                  ],
                ),
              );
            }
          } else if (difficulty == Difficulty.medium) {
            // Câu hỏi góc: ngẫu nhiên giữa góc vuông hoặc góc ngoài đa giác đều
            if (rand.nextBool()) {
              result.add(
                MathQuestion(
                  Shared.instance.context.l10n.whatIsthemeasureofarightangle,
                  90,
                  difficulty: difficulty,
                  choicesAnswer: ['90', '45', '60', '180'],
                ),
              );
            } else {
              final sidesList = [3, 4, 5, 6, 8, 9, 10, 12];
              final s = sidesList[rand.nextInt(sidesList.length)];
              int angle = 360 ~/ s;
              result.add(
                MathQuestion(
                  Shared.instance.context.l10n.exteriorAngleRegularPolygon(
                    s.toString(),
                  ),
                  angle,
                  difficulty: difficulty,
                  choicesAnswer: [
                    angle.toString(),
                    (angle + 10).toString(),
                    (angle - 10).abs().toString(),
                    (angle + 20).toString(),
                  ],
                ),
              );
            }

            // Ngẫu nhiên: diện tích hoặc chu vi hình chữ nhật
            int a = rand.nextInt(10) + 2;
            int b = rand.nextInt(10) + 2;
            if (rand.nextBool()) {
              int area = a * b;
              result.add(
                MathQuestion(
                  Shared.instance.context.l10n.rectangleArea(
                    a.toString(),
                    b.toString(),
                  ),
                  area,
                  difficulty: difficulty,
                  choicesAnswer: [
                    area.toString(),
                    (area + rand.nextInt(10) + 1).toString(),
                    (area - rand.nextInt(5) - 1).abs().toString(),
                    (area + rand.nextInt(5) + 2).toString(),
                  ],
                ),
              );
            } else {
              int perimeter = 2 * (a + b);
              result.add(
                MathQuestion(
                  Shared.instance.context.l10n.rectanglePerimeter(
                    a.toString(),
                    b.toString(),
                  ),
                  perimeter,
                  difficulty: difficulty,
                  choicesAnswer: [
                    perimeter.toString(),
                    (perimeter + rand.nextInt(10) + 1).toString(),
                    (perimeter - rand.nextInt(5) - 1).abs().toString(),
                    (perimeter + rand.nextInt(5) + 2).toString(),
                  ],
                ),
              );
            }
          } else {
            int radius = rand.nextInt(20) + 10;
            int circumference = (2 * 3.14 * radius).round();
            result.add(
              MathQuestion(
                Shared.instance.context.l10n
                    .theCircumferenceofacirclewithradiusisrounded(
                      radius.toString(),
                    ),
                circumference,
                difficulty: difficulty,
                choicesAnswer: [
                  circumference.toString(),
                  (circumference + rand.nextInt(20) + 5).toString(),
                  (circumference - rand.nextInt(10) - 5).abs().toString(),
                  (circumference + rand.nextInt(10) + 10).toString(),
                ],
              ),
            );
            int a = rand.nextInt(20) + 5;
            int h = rand.nextInt(10) + 2;
            int triangleArea = (a * h / 2).round();
            result.add(
              MathQuestion(
                Shared.instance.context.l10n.triangleArea(
                  a.toString(),
                  h.toString(),
                ),
                triangleArea,
                difficulty: difficulty,
                choicesAnswer: [
                  triangleArea.toString(),
                  (triangleArea + rand.nextInt(10) + 1).toString(),
                  (triangleArea - rand.nextInt(5) - 1).abs().toString(),
                  (triangleArea + rand.nextInt(5) + 2).toString(),
                ],
              ),
            );
            result.add(
              MathQuestion(
                Shared
                    .instance
                    .context
                    .l10n
                    .shapeWithAllEqualSidesAndRightAngles,
                Shared.instance.context.l10n.square,
                difficulty: difficulty,
                choicesAnswer: [
                  Shared.instance.context.l10n.square,
                  Shared.instance.context.l10n.rectangle,
                  Shared.instance.context.l10n.circle,
                  Shared.instance.context.l10n.triangle,
                ],
              ),
            );
          }
        }
        return result;
      },
    ),
    TopicData(
      key: TopicKey.advancedArithmetic,
      title: Shared.instance.context.l10n.advancedArithmetic,
      path: AssetsImages.images.imageAdvancedArithmetic,
      generateQuestions: (difficulty, count) {
        final rand = Random();
        List<MathQuestion> result = [];
        for (int i = 0; i < count; i++) {
          int a, b;
          if (difficulty == Difficulty.easy) {
            b = rand.nextInt(9) + 2; // 2..10
            int k = rand.nextInt(9) + 2; // 2..10
            a = b * k;
            int answer = a ~/ b;
            result.add(
              MathQuestion(
                Shared.instance.context.l10n.divisionQuestion(
                  a.toString(),
                  b.toString(),
                ),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  (answer + rand.nextInt(5) + 1).toString(),
                  (answer - rand.nextInt(3) - 1).abs().toString(),
                  (answer + rand.nextInt(3) + 2).toString(),
                ],
              ),
            );
          } else if (difficulty == Difficulty.medium) {
            a = rand.nextInt(80) + 21;
            b = rand.nextInt(10) + 2;
            int answer = a * b;
            result.add(
              MathQuestion(
                Shared.instance.context.l10n.multiplicationQuestion(
                  a.toString(),
                  b.toString(),
                ),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  (answer + rand.nextInt(50) + 10).toString(),
                  (answer - rand.nextInt(30) - 10).abs().toString(),
                  (answer + rand.nextInt(30) + 20).toString(),
                ],
              ),
            );
          } else {
            b = rand.nextInt(29) + 2; // 2..30
            int k = rand.nextInt(50) + 10; // 10..59
            a = b * k;
            int answer = a ~/ b;
            result.add(
              MathQuestion(
                Shared.instance.context.l10n.divisionQuestion(
                  a.toString(),
                  b.toString(),
                ),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  (answer + rand.nextInt(10) + 5).toString(),
                  (answer - rand.nextInt(5) - 2).abs().toString(),
                  (answer + rand.nextInt(5) + 8).toString(),
                ],
              ),
            );
          }
        }
        return result;
      },
    ),
    TopicData(
      key: TopicKey.specialChallenge,
      title: Shared.instance.context.l10n.specialChallenge,
      path: AssetsImages.images.imageSpecialChallenge,
      generateQuestions: (difficulty, count) {
        final rand = Random();
        List<MathQuestion> result = [];
        for (int i = 0; i < count; i++) {
          int a, b;
          if (difficulty == Difficulty.easy) {
            a = rand.nextInt(10) + 1;
            b = rand.nextInt(10) + 1;
            result.add(
              MathQuestion(
                Shared.instance.context.l10n.findXAddition(
                  a.toString(),
                  (a + b).toString(),
                ),
                b,
                difficulty: difficulty,
                choicesAnswer: [
                  b.toString(),
                  (b + rand.nextInt(5) + 1).toString(),
                  (b - rand.nextInt(3) - 1).abs().toString(),
                  (b + rand.nextInt(3) + 2).toString(),
                ],
              ),
            );
          } else if (difficulty == Difficulty.medium) {
            a = rand.nextInt(80) + 21;
            b = rand.nextInt(80) + 21;
            int answer = a + b;
            result.add(
              MathQuestion(
                Shared.instance.context.l10n.findXSubtraction(
                  a.toString(),
                  b.toString(),
                ),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  (answer + rand.nextInt(20) + 5).toString(),
                  (answer - rand.nextInt(10) - 5).abs().toString(),
                  (answer + rand.nextInt(10) + 10).toString(),
                ],
              ),
            );
          } else {
            // Đảm bảo b là bội của a: nghiệm x nguyên
            a = rand.nextInt(38) + 12; // 12..49
            int x = rand.nextInt(18) + 2; // 2..19
            b = a * x;
            result.add(
              MathQuestion(
                Shared.instance.context.l10n.findXMultiplication(
                  a.toString(),
                  b.toString(),
                ),
                x,
                difficulty: difficulty,
                choicesAnswer: [
                  x.toString(),
                  (x + rand.nextInt(5) + 1).toString(),
                  (x - rand.nextInt(3) - 1).abs().toString(),
                  (x + rand.nextInt(3) + 2).toString(),
                ],
              ),
            );
          }
        }
        return result;
      },
    ),
    TopicData(
      key: TopicKey.probabilityMath,
      title: Shared.instance.context.l10n.probabilityMath,
      path: AssetsImages.images.imageProbabilityMathematics,
      generateQuestions: (difficulty, count) {
        final rand = Random();
        List<MathQuestion> result = [];
        for (int i = 0; i < count; i++) {
          int total, pick;
          if (difficulty == Difficulty.easy) {
            total = rand.nextInt(6) + 5; // 5-10
            pick = rand.nextInt(total - 1) + 1;
            result.add(
              MathQuestion(
                //'Có $total viên bi, lấy ngẫu nhiên $pick viên. Xác suất lấy được viên đầu tiên là bao nhiêu?',
                Shared.instance.context.l10n.probabilityMarble(
                  total.toString(),
                  pick.toString(),
                ),
                '1/$total',
                difficulty: difficulty,
                choicesAnswer: [
                  '1/$total',
                  '1/${total + 1}',
                  '1/${total - 1}',
                  '$pick/$total',
                ],
              ),
            );
          } else if (difficulty == Difficulty.medium) {
            total = rand.nextInt(11) + 10; // 10-20
            pick = rand.nextInt(total - 2) + 2;
            result.add(
              MathQuestion(
                //'Có $total lá bài, rút $pick lá. Xác suất rút được lá đầu là bao nhiêu?',
                Shared.instance.context.l10n.probabilityCard(
                  total.toString(),
                  pick.toString(),
                ),
                '1/$total',
                difficulty: difficulty,
                choicesAnswer: [
                  '1/$total',
                  '1/${total + 2}',
                  '1/${total - 2}',
                  '$pick/$total',
                ],
              ),
            );
          } else {
            total = rand.nextInt(41) + 10; // 10-50
            pick = rand.nextInt(total - 5) + 5;
            int answer = _comb(total, pick);
            result.add(
              MathQuestion(
                //'Có $total học sinh, chọn $pick bạn đi thi. Có bao nhiêu cách chọn?',
                Shared.instance.context.l10n.probabilityStudent(
                  total.toString(),
                  pick.toString(),
                ),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  (answer + rand.nextInt(1000) + 100).toString(),
                  (answer - rand.nextInt(100) - 50).abs().toString(),
                  (answer + rand.nextInt(500) + 200).toString(),
                ],
              ),
            );
          }
        }
        return result;
      },
    ),
    TopicData(
      key: TopicKey.visualLogicMath,
      title: Shared.instance.context.l10n.visualLogicMath,
      path: AssetsImages.images.imageProbabilityMathematics,
      generateQuestions: (difficulty, count) {
        final rand = Random();
        List<MathQuestion> result = [];
        for (int i = 0; i < count; i++) {
          int a = rand.nextInt(10) + 1;
          int b = rand.nextInt(10) + 1;
          if (difficulty == Difficulty.easy) {
            int answer = a + b;
            result.add(
              MathQuestion(
                // 'Có $a hình tròn và $b hình vuông. Tổng số hình là?',
                Shared.instance.context.l10n.shapesTotal(
                  a.toString(),
                  b.toString(),
                ),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  (answer + rand.nextInt(5) + 1).toString(),
                  (answer - rand.nextInt(3) - 1).abs().toString(),
                  (answer + rand.nextInt(3) + 2).toString(),
                ],
              ),
            );
          } else if (difficulty == Difficulty.medium) {
            result.add(
              MathQuestion(
                //'Có $a hình tam giác, $b hình vuông. Nếu bỏ đi $a hình tam giác, còn lại bao nhiêu hình?',
                Shared.instance.context.l10n.shapesRemove(
                  a.toString(),
                  b.toString(),
                ),
                b,
                difficulty: difficulty,
                choicesAnswer: [
                  b.toString(),
                  (b + rand.nextInt(5) + 1).toString(),
                  (b - rand.nextInt(3) - 1).abs().toString(),
                  a.toString(),
                ],
              ),
            );
          } else {
            int c = rand.nextInt(10) + 1;
            int answer = a + b + c;
            result.add(
              MathQuestion(
                //'Có $a hình tròn, $b hình vuông, $c hình tam giác. Tổng số hình là?',
                Shared.instance.context.l10n.shapesTotal3(
                  a.toString(),
                  b.toString(),
                  c.toString(),
                ),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  (answer + rand.nextInt(5) + 1).toString(),
                  (answer - rand.nextInt(3) - 1).abs().toString(),
                  (answer + rand.nextInt(3) + 2).toString(),
                ],
              ),
            );
          }
        }
        return result;
      },
    ),
    TopicData(
      key: TopicKey.timeMath,
      title: Shared.instance.context.l10n.timeMath,
      path: AssetsImages.images.imageTimeMathematics,
      generateQuestions: (difficulty, count) {
        final rand = Random();
        List<MathQuestion> result = [];
        for (int i = 0; i < count; i++) {
          int h = rand.nextInt(12) + 1;
          int m = rand.nextInt(60);
          if (difficulty == Difficulty.easy) {
            int answer = (h + 2) > 12 ? (h + 2 - 12) : (h + 2);
            result.add(
              MathQuestion(
                //'Bây giờ là $h giờ. Sau 2 giờ là mấy giờ?',
                Shared.instance.context.l10n.nowIsHour(h.toString()),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  ((answer + 1) > 12 ? (answer + 1 - 12) : (answer + 1))
                      .toString(),
                  ((answer - 1) < 1 ? 12 : (answer - 1)).toString(),
                  ((answer + 3) > 12 ? (answer + 3 - 12) : (answer + 3))
                      .toString(),
                ],
              ),
            );
          } else if (difficulty == Difficulty.medium) {
            int newH = (h + ((m + 45) ~/ 60)) % 12 == 0
                ? 12
                : (h + ((m + 45) ~/ 60)) % 12;
            int newM = (m + 45) % 60;
            String answer =
                '$newH ${Shared.instance.context.l10n.time} $newM ${Shared.instance.context.l10n.minute}';
            int wrongH1 = (newH + 1) > 12 ? (newH + 1 - 12) : (newH + 1);
            int wrongH2 = (newH - 1) < 1 ? 12 : (newH - 1);
            int wrongM1 = (newM + 15) % 60;
            result.add(
              MathQuestion(
                //'Bây giờ là $h giờ $m phút. Sau 45 phút là mấy giờ mấy phút?',
                Shared.instance.context.l10n.nowIsHourMinute(
                  h.toString(),
                  m.toString(),
                ),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer,
                  '$wrongH1 ${Shared.instance.context.l10n.time} $newM ${Shared.instance.context.l10n.minute}',
                  '$wrongH2 ${Shared.instance.context.l10n.time} $wrongM1 ${Shared.instance.context.l10n.minute}',
                  '$newH ${Shared.instance.context.l10n.time} $wrongM1 ${Shared.instance.context.l10n.minute}',
                ],
              ),
            );
          } else {
            int add = rand.nextInt(120) + 60;
            int newH = (h + ((m + add) ~/ 60)) % 12 == 0
                ? 12
                : (h + ((m + add) ~/ 60)) % 12;
            int newM = (m + add) % 60;
            String answer =
                '$newH ${Shared.instance.context.l10n.time} $newM ${Shared.instance.context.l10n.minute}';
            int wrongH1 = (newH + 1) > 12 ? (newH + 1 - 12) : (newH + 1);
            int wrongH2 = (newH - 1) < 1 ? 12 : (newH - 1);
            int wrongM1 = (newM + 15) % 60;
            result.add(
              MathQuestion(
                //'Bây giờ là $h giờ $m phút. Sau $add phút là mấy giờ mấy phút?',
                Shared.instance.context.l10n.nowIsHourMinuteAdd(
                  h.toString(),
                  m.toString(),
                  add.toString(),
                ),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer,
                  '$wrongH1 ${Shared.instance.context.l10n.time} $newM ${Shared.instance.context.l10n.minute}',
                  '$wrongH2 ${Shared.instance.context.l10n.time} $wrongM1 ${Shared.instance.context.l10n.minute}',
                  '$newH ${Shared.instance.context.l10n.time} $wrongM1 ${Shared.instance.context.l10n.minute}',
                ],
              ),
            );
          }
        }
        return result;
      },
    ),
    TopicData(
      key: TopicKey.sequenceMath,
      title: Shared.instance.context.l10n.sequenceMath,
      path: AssetsImages.images.imageSequenceMathematics,
      generateQuestions: (difficulty, count) {
        final rand = Random();
        List<MathQuestion> result = [];
        for (int i = 0; i < count; i++) {
          int start, step, n;
          if (difficulty == Difficulty.easy) {
            start = rand.nextInt(10);
            step = rand.nextInt(3) + 1;
            n = rand.nextInt(5) + 3;
          } else if (difficulty == Difficulty.medium) {
            start = rand.nextInt(20);
            step = rand.nextInt(5) + 2;
            n = rand.nextInt(7) + 5;
          } else {
            start = rand.nextInt(50);
            step = rand.nextInt(10) + 5;
            n = rand.nextInt(10) + 8;
          }
          List<int> seq = List.generate(n, (i) => start + i * step);
          int answer = seq.last + step;
          result.add(
            MathQuestion(
              '${Shared.instance.context.l10n.nextNumberintheSeries}: ${seq.join(', ')}',
              answer,
              difficulty: difficulty,
              choicesAnswer: [
                answer.toString(),
                (answer + step).toString(),
                (answer - step).toString(),
                (answer + step * 2).toString(),
              ],
            ),
          );
        }
        return result;
      },
    ),
    TopicData(
      key: TopicKey.deductiveLogicMath,
      title: Shared.instance.context.l10n.deductiveLogicMath,
      path: AssetsImages.images.imageDeductiveLogicMathematics,
      generateQuestions: (difficulty, count) {
        final rand = Random();
        List<MathQuestion> result = [];
        for (int i = 0; i < count; i++) {
          int a = rand.nextInt(7) + 1; // 1-7 for days of week
          if (difficulty == Difficulty.easy) {
            int answer = a == 7 ? 1 : a + 1;
            result.add(
              MathQuestion(
                //'Nếu hôm nay là thứ $a, ngày mai là thứ mấy?',
                Shared.instance.context.l10n.todayIsDay(a.toString()),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  (answer == 7 ? 1 : answer + 1).toString(),
                  (answer == 1 ? 7 : answer - 1).toString(),
                  ((answer + 2) > 7 ? (answer + 2 - 7) : (answer + 2))
                      .toString(),
                ],
              ),
            );
          } else if (difficulty == Difficulty.medium) {
            int days = rand.nextInt(5) + 2;
            int answer = ((a + days - 1) % 7) + 1;
            result.add(
              MathQuestion(
                //'Nếu hôm nay là thứ $a, $days ngày nữa là thứ mấy?',
                Shared.instance.context.l10n.todayIsDayInDays(
                  a.toString(),
                  days.toString(),
                ),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  (answer == 7 ? 1 : answer + 1).toString(),
                  (answer == 1 ? 7 : answer - 1).toString(),
                  ((answer + 2) > 7 ? (answer + 2 - 7) : (answer + 2))
                      .toString(),
                ],
              ),
            );
          } else {
            int days = rand.nextInt(20) + 7;
            int answer = ((a + days - 1) % 7) + 1;
            result.add(
              MathQuestion(
                //'Nếu hôm nay là thứ $a, $days ngày nữa là thứ mấy?',
                Shared.instance.context.l10n.todayIsDayInDays(
                  a.toString(),
                  days.toString(),
                ),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  (answer == 7 ? 1 : answer + 1).toString(),
                  (answer == 1 ? 7 : answer - 1).toString(),
                  ((answer + 2) > 7 ? (answer + 2 - 7) : (answer + 2))
                      .toString(),
                ],
              ),
            );
          }
        }
        return result;
      },
    ),
    TopicData(
      key: TopicKey.divisionMath,
      title: Shared.instance.context.l10n.divisionMath,
      path: AssetsImages.images.imageDivisionMathematics,
      generateQuestions: (difficulty, count) {
        final rand = Random();
        List<MathQuestion> result = [];
        for (int i = 0; i < count; i++) {
          int a, b;
          if (difficulty == Difficulty.easy) {
            b = rand.nextInt(9) + 2;
            a = b * (rand.nextInt(10) + 1);
          } else if (difficulty == Difficulty.medium) {
            b = rand.nextInt(19) + 2;
            a = b * (rand.nextInt(20) + 1);
          } else {
            b = rand.nextInt(49) + 2;
            a = b * (rand.nextInt(50) + 1);
          }
          int answer = a ~/ b;
          result.add(
            MathQuestion(
              Shared.instance.context.l10n.divisionQuestion(
                a.toString(),
                b.toString(),
              ),
              answer,
              difficulty: difficulty,
              choicesAnswer: [
                answer.toString(),
                (answer + rand.nextInt(5) + 1).toString(),
                (answer - rand.nextInt(3) - 1).abs().toString(),
                (answer + rand.nextInt(3) + 2).toString(),
              ],
            ),
          );
        }
        return result;
      },
    ),
    TopicData(
      key: TopicKey.comprehensiveArithmetic,
      title: Shared.instance.context.l10n.comprehensiveArithmetic,
      path: AssetsImages.images.imageComprehensiveArithmetic,
      generateQuestions: (difficulty, count) {
        final rand = Random();
        List<MathQuestion> result = [];
        for (int i = 0; i < count; i++) {
          int a = rand.nextInt(100) + 1;
          int b = rand.nextInt(100) + 1;
          int c = rand.nextInt(100) + 1;
          if (difficulty == Difficulty.easy) {
            int answer = a + b;
            result.add(
              MathQuestion(
                Shared.instance.context.l10n.additionQuestion(
                  a.toString(),
                  b.toString(),
                ),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  (answer + rand.nextInt(20) + 5).toString(),
                  (answer - rand.nextInt(10) - 5).abs().toString(),
                  (answer + rand.nextInt(10) + 10).toString(),
                ],
              ),
            );
          } else if (difficulty == Difficulty.medium) {
            int answer = (a + b) * c;
            result.add(
              MathQuestion(
                Shared.instance.context.l10n.compositeAddMul(
                  a.toString(),
                  b.toString(),
                  c.toString(),
                ),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  (answer + rand.nextInt(100) + 50).toString(),
                  (answer - rand.nextInt(50) - 20).abs().toString(),
                  (answer + rand.nextInt(50) + 100).toString(),
                ],
              ),
            );
          } else {
            int answer = ((a + b) * c) - a;
            result.add(
              MathQuestion(
                Shared.instance.context.l10n.compositeAddMulMinus(
                  a.toString(),
                  b.toString(),
                  c.toString(),
                ),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  (answer + rand.nextInt(100) + 50).toString(),
                  (answer - rand.nextInt(50) - 20).abs().toString(),
                  (answer + rand.nextInt(50) + 100).toString(),
                ],
              ),
            );
          }
        }
        return result;
      },
    ),
    TopicData(
      key: TopicKey.visualLogicMath2,
      title: Shared.instance.context.l10n.visualLogicMath,
      path: AssetsImages.images.imageBasicMathematicalThinking,
      generateQuestions: (difficulty, count) {
        final rand = Random();
        List<MathQuestion> result = [];
        for (int i = 0; i < count; i++) {
          int a, b, c, d;
          if (difficulty == Difficulty.easy) {
            a = rand.nextInt(9) + 1;
            b = rand.nextInt(9) + 1;
            c = rand.nextInt(9) + 1;
            d = rand.nextInt(9) + 1;
            String answer = ((a * d + c * b) / (b * d)).toStringAsFixed(2);
            double val = (a * d + c * b) / (b * d);
            result.add(
              MathQuestion(
                //'Tính: $a/$b + $c/$d = ?',
                Shared.instance.context.l10n.fractionAddition(
                  a.toString(),
                  b.toString(),
                  c.toString(),
                  d.toString(),
                ),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer,
                  (val + 0.5).toStringAsFixed(2),
                  (val - 0.5).abs().toStringAsFixed(2),
                  (val + 1.0).toStringAsFixed(2),
                ],
              ),
            );
          } else if (difficulty == Difficulty.medium) {
            a = rand.nextInt(19) + 2;
            b = rand.nextInt(19) + 2;
            c = rand.nextInt(19) + 2;
            d = rand.nextInt(19) + 2;
            String answer = ((a * d - c * b) / (b * d)).toStringAsFixed(2);
            double val = (a * d - c * b) / (b * d);
            result.add(
              MathQuestion(
                //'Tính: $a/$b - $c/$d = ?',
                Shared.instance.context.l10n.fractionSubtraction(
                  a.toString(),
                  b.toString(),
                  c.toString(),
                  d.toString(),
                ),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer,
                  (val + 0.5).toStringAsFixed(2),
                  (val - 0.5).toStringAsFixed(2),
                  (val + 1.0).toStringAsFixed(2),
                ],
              ),
            );
          } else {
            a = rand.nextInt(19) + 2;
            b = rand.nextInt(19) + 2;
            c = rand.nextInt(19) + 2;
            d = rand.nextInt(19) + 2;
            String answer = ((a * c) / (b * d)).toStringAsFixed(2);
            double val = (a * c) / (b * d);
            result.add(
              MathQuestion(
                //'Tính: ($a/$b) x ($c/$d) = ?',
                Shared.instance.context.l10n.fractionMultiplication(
                  a.toString(),
                  b.toString(),
                  c.toString(),
                  d.toString(),
                ),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer,
                  (val + 0.5).toStringAsFixed(2),
                  (val - 0.3).abs().toStringAsFixed(2),
                  (val + 1.0).toStringAsFixed(2),
                ],
              ),
            );
          }
        }
        return result;
      },
    ),
    TopicData(
      key: TopicKey.primeNumberMath,
      title: Shared.instance.context.l10n.primeNumberMath,
      path: AssetsImages.images.imageBasicMathematicalThinking,
      generateQuestions: (difficulty, count) {
        final rand = Random();
        List<MathQuestion> result = [];
        for (int i = 0; i < count; i++) {
          int n;
          if (difficulty == Difficulty.easy) {
            n = rand.nextInt(20) + 2;
            String answer = _isPrime(n)
                ? Shared.instance.context.l10n.yes
                : Shared.instance.context.l10n.no;
            result.add(
              MathQuestion(
                //'Số $n có phải là số nguyên tố không?',
                Shared.instance.context.l10n.isPrime(n.toString()),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  Shared.instance.context.l10n.yes,
                  Shared.instance.context.l10n.no,
                ],
              ),
            );
          } else if (difficulty == Difficulty.medium) {
            n = rand.nextInt(50) + 20;
            int answer = _nextPrime(n) as int;
            result.add(
              MathQuestion(
                //'Số nguyên tố tiếp theo sau $n là số nào?',
                Shared.instance.context.l10n.nextPrime(n.toString()),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  (answer + 2).toString(),
                  (answer + 4).toString(),
                  (answer + 6).toString(),
                ],
              ),
            );
          } else {
            n = rand.nextInt(100) + 50;
            int answer = _countPrimes(n) as int;
            result.add(
              MathQuestion(
                // 'Có bao nhiêu số nguyên tố nhỏ hơn $n?',
                Shared.instance.context.l10n.countPrimes(n.toString()),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  (answer + rand.nextInt(5) + 1).toString(),
                  (answer - rand.nextInt(3) - 1).abs().toString(),
                  (answer + rand.nextInt(3) + 2).toString(),
                ],
              ),
            );
          }
        }
        return result;
      },
    ),
    TopicData(
      key: TopicKey.perfectNumberMath,
      title: Shared.instance.context.l10n.perfectNumberMath,
      path: AssetsImages.images.imageBasicMathematicalThinking,
      generateQuestions: (difficulty, count) {
        final rand = Random();
        List<MathQuestion> result = [];
        for (int i = 0; i < count; i++) {
          int n;
          if (difficulty == Difficulty.easy) {
            n = rand.nextInt(30) + 1;
            String answer = _isPerfect(n)
                ? Shared.instance.context.l10n.yes
                : Shared.instance.context.l10n.no;
            result.add(
              MathQuestion(
                //'Số $n có phải là số hoàn hảo không?',
                Shared.instance.context.l10n.isPerfect(n.toString()),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  Shared.instance.context.l10n.yes,
                  Shared.instance.context.l10n.no,
                ],
              ),
            );
          } else if (difficulty == Difficulty.medium) {
            n = rand.nextInt(100) + 30;
            var answer = _nextPerfect(n);
            result.add(
              MathQuestion(
                //'Số hoàn hảo nhỏ nhất lớn hơn $n là số nào?',
                Shared.instance.context.l10n.nextPerfect(n.toString()),
                answer,
                difficulty: difficulty,
                choicesAnswer: [answer.toString(), '6', '28', '496'],
              ),
            );
          } else {
            n = rand.nextInt(500) + 100;
            var answer = _countPerfects(n);
            result.add(
              MathQuestion(
                //'Có bao nhiêu số hoàn hảo nhỏ hơn $n?',
                Shared.instance.context.l10n.countPerfects(n.toString()),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  (answer is int ? answer + 1 : 1).toString(),
                  (answer is int ? answer + 2 : 2).toString(),
                  '0',
                ],
              ),
            );
          }
        }
        return result;
      },
    ),
    TopicData(
      key: TopicKey.fibonacciMath,
      title: Shared.instance.context.l10n.fibonacciMath,
      path: AssetsImages.images.imageAdvancedArithmetic,
      generateQuestions: (difficulty, count) {
        final rand = Random();
        List<MathQuestion> result = [];
        for (int i = 0; i < count; i++) {
          int n;
          if (difficulty == Difficulty.easy) {
            n = rand.nextInt(6) + 3;
            int answer = _fibo(n);
            result.add(
              MathQuestion(
                //'Số Fibonacci thứ $n là?',
                Shared.instance.context.l10n.fibonacci(n.toString()),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  _fibo(n + 1).toString(),
                  _fibo(n - 1).toString(),
                  _fibo(n + 2).toString(),
                ],
              ),
            );
          } else if (difficulty == Difficulty.medium) {
            n = rand.nextInt(8) + 8;
            int answer = _fibo(n);
            result.add(
              MathQuestion(
                //'Số Fibonacci thứ $n là?',
                Shared.instance.context.l10n.fibonacci(n.toString()),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  _fibo(n + 1).toString(),
                  _fibo(n - 1).toString(),
                  _fibo(n + 2).toString(),
                ],
              ),
            );
          } else {
            n = rand.nextInt(10) + 15;
            int answer = _fibo(n);
            result.add(
              MathQuestion(
                //'Số Fibonacci thứ $n là?',
                Shared.instance.context.l10n.fibonacci(n.toString()),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  _fibo(n + 1).toString(),
                  _fibo(n - 1).toString(),
                  _fibo(n + 2).toString(),
                ],
              ),
            );
          }
        }
        return result;
      },
    ),
    TopicData(
      key: TopicKey.palindromeNumberMath,
      title: Shared.instance.context.l10n.palindromeNumberMath,
      path: AssetsImages.images.imageBasicMathematicalThinking,
      generateQuestions: (difficulty, count) {
        final rand = Random();
        List<MathQuestion> result = [];
        for (int i = 0; i < count; i++) {
          int n;
          if (difficulty == Difficulty.easy) {
            n = rand.nextInt(90) + 10;
            String answer = _isPalindrome(n)
                ? Shared.instance.context.l10n.yes
                : Shared.instance.context.l10n.no;
            result.add(
              MathQuestion(
                //'Số $n có phải là số đối xứng không?',
                Shared.instance.context.l10n.isPalindrome(n.toString()),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  Shared.instance.context.l10n.yes,
                  Shared.instance.context.l10n.no,
                ],
              ),
            );
          } else if (difficulty == Difficulty.medium) {
            n = rand.nextInt(900) + 100;
            String answer = _isPalindrome(n)
                ? Shared.instance.context.l10n.yes
                : Shared.instance.context.l10n.no;
            result.add(
              MathQuestion(
                //'Số $n có phải là số đối xứng không?',
                Shared.instance.context.l10n.isPalindrome(n.toString()),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  Shared.instance.context.l10n.yes,
                  Shared.instance.context.l10n.no,
                ],
              ),
            );
          } else {
            n = rand.nextInt(9000) + 1000;
            String answer = _isPalindrome(n)
                ? Shared.instance.context.l10n.yes
                : Shared.instance.context.l10n.no;
            result.add(
              MathQuestion(
                //'Số $n có phải là số đối xứng không?',
                Shared.instance.context.l10n.isPalindrome(n.toString()),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  Shared.instance.context.l10n.yes,
                  Shared.instance.context.l10n.no,
                ],
              ),
            );
          }
        }
        return result;
      },
    ),
    TopicData(
      key: TopicKey.oddEvenNumberMath,
      title: Shared.instance.context.l10n.oddEvenNumberMath,
      path: AssetsImages.images.imageBasicMathematicalThinking,
      generateQuestions: (difficulty, count) {
        final rand = Random();
        List<MathQuestion> result = [];
        for (int i = 0; i < count; i++) {
          int n;
          if (difficulty == Difficulty.easy) {
            n = rand.nextInt(100);
            String answer = n % 2 == 0
                ? Shared.instance.context.l10n.even
                : Shared.instance.context.l10n.odd;
            result.add(
              MathQuestion(
                //'Số $n là số chẵn hay lẻ?',
                Shared.instance.context.l10n.evenOdd(n.toString()),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  Shared.instance.context.l10n.even,
                  Shared.instance.context.l10n.odd,
                ],
              ),
            );
          } else if (difficulty == Difficulty.medium) {
            n = rand.nextInt(100) + 100;
            String answer = n % 2 == 0
                ? Shared.instance.context.l10n.even
                : Shared.instance.context.l10n.odd;
            result.add(
              MathQuestion(
                //'Số $n là số chẵn hay lẻ?',
                Shared.instance.context.l10n.evenOdd(n.toString()),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  Shared.instance.context.l10n.even,
                  Shared.instance.context.l10n.odd,
                ],
              ),
            );
          } else {
            n = rand.nextInt(900) + 100;
            String answer = n % 2 == 0
                ? Shared.instance.context.l10n.even
                : Shared.instance.context.l10n.odd;
            result.add(
              MathQuestion(
                //'Số $n là số chẵn hay lẻ?',
                Shared.instance.context.l10n.evenOdd(n.toString()),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  Shared.instance.context.l10n.even,
                  Shared.instance.context.l10n.odd,
                ],
              ),
            );
          }
        }
        return result;
      },
    ),
    TopicData(
      key: TopicKey.powerAndRootMath,
      title: Shared.instance.context.l10n.powerAndRootMath,
      path: AssetsImages.images.imageBasicMathematicalThinking,
      generateQuestions: (difficulty, count) {
        final rand = Random();
        List<MathQuestion> result = [];
        for (int i = 0; i < count; i++) {
          int a, b;
          if (difficulty == Difficulty.easy) {
            a = rand.nextInt(10) + 2;
            int answer = a * a;
            result.add(
              MathQuestion(
                Shared.instance.context.l10n.square(a.toString()),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  ((a + 1) * (a + 1)).toString(),
                  ((a - 1) * (a - 1)).toString(),
                  (a * a + a).toString(),
                ],
              ),
            );
          } else if (difficulty == Difficulty.medium) {
            a = rand.nextInt(10) + 2;
            b = 3;
            int answer = pow(a, b).toInt();
            result.add(
              MathQuestion(
                Shared.instance.context.l10n.powerQuestion(
                  a.toString(),
                  b.toString(),
                ),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  pow(a + 1, b).toInt().toString(),
                  pow(a - 1, b).toInt().toString(),
                  pow(a, b + 1).toInt().toString(),
                ],
              ),
            );
          } else {
            a = rand.nextInt(100) + 1;
            int answer = sqrt(a).round();
            result.add(
              MathQuestion(
                Shared.instance.context.l10n.sqrt(a.toString()),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  (answer + 1).toString(),
                  (answer - 1).abs().toString(),
                  (answer + 2).toString(),
                ],
              ),
            );
          }
        }
        return result;
      },
    ),
    TopicData(
      key: TopicKey.moduloMath,
      title: Shared.instance.context.l10n.moduloMath,
      path: AssetsImages.images.imageBasicMathematicalThinking,
      generateQuestions: (difficulty, count) {
        final rand = Random();
        List<MathQuestion> result = [];
        for (int i = 0; i < count; i++) {
          int a, b, m;
          if (difficulty == Difficulty.easy) {
            a = rand.nextInt(20) + 1;
            b = rand.nextInt(20) + 1;
            m = rand.nextInt(9) + 2;
            int answer = (a + b) % m;
            result.add(
              MathQuestion(
                //'($a + $b) mod $m = ?',
                Shared.instance.context.l10n.modAdd(
                  a.toString(),
                  b.toString(),
                  m.toString(),
                ),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  ((answer + 1) % m).toString(),
                  ((answer + 2) % m).toString(),
                  ((answer + 3) % m).toString(),
                ],
              ),
            );
          } else if (difficulty == Difficulty.medium) {
            a = rand.nextInt(50) + 20;
            b = rand.nextInt(50) + 20;
            m = rand.nextInt(19) + 2;
            int answer = (a * b) % m;
            result.add(
              MathQuestion(
                //'($a x $b) mod $m = ?',
                Shared.instance.context.l10n.modMul(
                  a.toString(),
                  b.toString(),
                  m.toString(),
                ),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  ((answer + 1) % m).toString(),
                  ((answer + 2) % m).toString(),
                  ((answer + 3) % m).toString(),
                ],
              ),
            );
          } else {
            a = rand.nextInt(10) + 2;
            b = rand.nextInt(5) + 2;
            m = rand.nextInt(29) + 2;
            int answer = pow(a, b).toInt() % m;
            result.add(
              MathQuestion(
                // '($a^$b) mod $m = ?',
                Shared.instance.context.l10n.modPow(
                  a.toString(),
                  b.toString(),
                  m.toString(),
                ),
                answer,
                difficulty: difficulty,
                choicesAnswer: [
                  answer.toString(),
                  ((answer + 1) % m).toString(),
                  ((answer + 2) % m).toString(),
                  ((answer + 3) % m).toString(),
                ],
              ),
            );
          }
        }
        return result;
      },
    ),
  ];
}

int _comb(int n, int k) {
  if (k == 0 || k == n) return 1;
  if (k > n) return 0;
  int res = 1;
  for (int i = 1; i <= k; i++) {
    res = res * (n - i + 1) ~/ i;
  }
  return res;
}

bool _isPrime(int n) {
  if (n < 2) return false;
  for (int i = 2; i <= sqrt(n).toInt(); i++) {
    if (n % i == 0) return false;
  }
  return true;
}

dynamic _nextPrime(int n) {
  int candidate = n + 1;
  while (true) {
    if (_isPrime(candidate)) return candidate;
    candidate++;
  }
}

dynamic _countPrimes(int n) {
  int count = 0;
  for (int i = 2; i < n; i++) {
    if (_isPrime(i)) count++;
  }
  return count;
}

bool _isPerfect(int n) {
  int sum = 0;
  for (int i = 1; i < n; i++) {
    if (n % i == 0) sum += i;
  }
  return sum == n;
}

dynamic _nextPerfect(int n) {
  int candidate = n + 1;
  while (true) {
    if (_isPerfect(candidate)) return candidate;
    candidate++;
    if (candidate > 10000) return 'Không tìm thấy';
  }
}

dynamic _countPerfects(int n) {
  int count = 0;
  for (int i = 2; i < n; i++) {
    if (_isPerfect(i)) count++;
  }
  return count;
}

int _fibo(int n) {
  if (n <= 1) return n;
  int a = 0, b = 1;
  for (int i = 2; i <= n; i++) {
    int temp = a + b;
    a = b;
    b = temp;
  }
  return b;
}

bool _isPalindrome(int n) {
  String s = n.toString();
  return s == s.split('').reversed.join();
}
