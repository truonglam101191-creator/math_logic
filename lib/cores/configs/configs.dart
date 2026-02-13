import 'package:uuid/uuid.dart';

class Configs {
  static final Configs _instance = Configs._();
  static Configs get instance => _instance;

  Configs._();

  String generate() {
    return const Uuid().v1();
  }

  final commonRadius = 15.0;
  final commonRadiusMax = 1000.0;
  final commonRadiusBottomSheet = 20.0;
  final commonPadding = 10.0;
  final commonHeightButton = 45.0;
  final commonIconSize = 24.0;
  final commonSpcing = 10.0;
  final duration = Duration(milliseconds: 300);

  static final companyName = 'Lam IT Solution';
  static final emailSupport = 'truonglam10112000@gmail.com';
  static final dateTimeUpdateApp = '14/09/2025';
  static const inappPurchaseId = 'logicmathematics';
}
