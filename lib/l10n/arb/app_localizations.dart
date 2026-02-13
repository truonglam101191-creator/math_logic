import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get preferredLanguage;

  /// No description provided for @newUpdate.
  ///
  /// In en, this message translates to:
  /// **'New Update – A Fresh Look Is Here!'**
  String get newUpdate;

  /// No description provided for @newUpdateDescription.
  ///
  /// In en, this message translates to:
  /// **'We’ve redesigned your experience from the ground up! Get ready for a sleek, modern, and faster interface that makes everything smoother and more intuitive.'**
  String get newUpdateDescription;

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Update Later'**
  String get updateLater;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @listofTopics.
  ///
  /// In en, this message translates to:
  /// **' List of Topics'**
  String get listofTopics;

  /// No description provided for @selectlevelandnumberofquestionsBottomsheetdata.
  ///
  /// In en, this message translates to:
  /// **'Select level and number of questions'**
  String get selectlevelandnumberofquestionsBottomsheetdata;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @numberOfquestions.
  ///
  /// In en, this message translates to:
  /// **'Number of questions'**
  String get numberOfquestions;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @basicMath.
  ///
  /// In en, this message translates to:
  /// **'Basic Math'**
  String get basicMath;

  /// No description provided for @mathlogic.
  ///
  /// In en, this message translates to:
  /// **'Math Logic'**
  String get mathlogic;

  /// No description provided for @funGeometry.
  ///
  /// In en, this message translates to:
  /// **'Fun Geometry'**
  String get funGeometry;

  /// No description provided for @advancedArithmetic.
  ///
  /// In en, this message translates to:
  /// **'Advanced arithmetic'**
  String get advancedArithmetic;

  /// No description provided for @specialChallenge.
  ///
  /// In en, this message translates to:
  /// **'Special Challenge'**
  String get specialChallenge;

  /// No description provided for @probabilityMath.
  ///
  /// In en, this message translates to:
  /// **'Probability Math'**
  String get probabilityMath;

  /// No description provided for @visualLogicMath.
  ///
  /// In en, this message translates to:
  /// **'Visual Logic Math'**
  String get visualLogicMath;

  /// No description provided for @timeMath.
  ///
  /// In en, this message translates to:
  /// **'Time Math'**
  String get timeMath;

  /// No description provided for @sequenceMath.
  ///
  /// In en, this message translates to:
  /// **'Sequence Math'**
  String get sequenceMath;

  /// No description provided for @deductiveLogicMath.
  ///
  /// In en, this message translates to:
  /// **'Deductive Logic Math'**
  String get deductiveLogicMath;

  /// No description provided for @divisionMath.
  ///
  /// In en, this message translates to:
  /// **'Division Math'**
  String get divisionMath;

  /// No description provided for @comprehensiveArithmetic.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive Arithmetic'**
  String get comprehensiveArithmetic;

  /// No description provided for @fractionMath.
  ///
  /// In en, this message translates to:
  /// **'Fraction Math'**
  String get fractionMath;

  /// No description provided for @primeNumberMath.
  ///
  /// In en, this message translates to:
  /// **'Prime Number Math'**
  String get primeNumberMath;

  /// No description provided for @perfectNumberMath.
  ///
  /// In en, this message translates to:
  /// **'Perfect Number Math'**
  String get perfectNumberMath;

  /// No description provided for @fibonacciMath.
  ///
  /// In en, this message translates to:
  /// **'Fibonacci Math'**
  String get fibonacciMath;

  /// No description provided for @palindromeNumberMath.
  ///
  /// In en, this message translates to:
  /// **'Palindrome Number Math'**
  String get palindromeNumberMath;

  /// No description provided for @oddEvenNumberMath.
  ///
  /// In en, this message translates to:
  /// **'Odd/Even Number Math'**
  String get oddEvenNumberMath;

  /// No description provided for @powerAndRootMath.
  ///
  /// In en, this message translates to:
  /// **'Power and Root Math'**
  String get powerAndRootMath;

  /// No description provided for @moduloMath.
  ///
  /// In en, this message translates to:
  /// **'Modulo Math'**
  String get moduloMath;

  /// No description provided for @chooseThecorrectsign.
  ///
  /// In en, this message translates to:
  /// **'Choose the correct sign'**
  String get chooseThecorrectsign;

  /// No description provided for @fillInthemissingnumber.
  ///
  /// In en, this message translates to:
  /// **'Fill in the missing number'**
  String get fillInthemissingnumber;

  /// Question template for finding the maximum number
  ///
  /// In en, this message translates to:
  /// **'Maximum number among: {numbers} is?'**
  String maximumnumber(String numbers);

  /// No description provided for @isItevenorodd.
  ///
  /// In en, this message translates to:
  /// **'Is it even or odd?'**
  String get isItevenorodd;

  /// No description provided for @even.
  ///
  /// In en, this message translates to:
  /// **'Even'**
  String get even;

  /// No description provided for @odd.
  ///
  /// In en, this message translates to:
  /// **'Odd'**
  String get odd;

  /// Template for a question asking for the unknown value in an equation
  ///
  /// In en, this message translates to:
  /// **'If {expression} = {result}, then what is {unknown}?'**
  String ifExpressionresultthenwhatisunknown(
    String expression,
    String result,
    String unknown,
  );

  /// Question template for identifying a shape by its number of sides
  ///
  /// In en, this message translates to:
  /// **'What shape has {sides} sides?'**
  String whatShapehassides(String sides);

  /// No description provided for @whatIsthemeasureofarightangle.
  ///
  /// In en, this message translates to:
  /// **'What is the measure of a right angle?'**
  String get whatIsthemeasureofarightangle;

  /// Question about the circumference of a circle
  ///
  /// In en, this message translates to:
  /// **'The circumference of a circle with radius {radius} is rounded to the nearest whole number.'**
  String theCircumferenceofacirclewithradiusisrounded(String radius);

  /// No description provided for @round.
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get round;

  /// Find x in addition equation
  ///
  /// In en, this message translates to:
  /// **'Find x: x + {a} = {sum}'**
  String findXAddition(String a, String sum);

  /// Find x in subtraction equation
  ///
  /// In en, this message translates to:
  /// **'Find x: x - {a} = {b}'**
  String findXSubtraction(String a, String b);

  /// Find x in multiplication equation
  ///
  /// In en, this message translates to:
  /// **'Find x: x x {a} = {b}'**
  String findXMultiplication(String a, String b);

  /// Probability question about drawing marbles
  ///
  /// In en, this message translates to:
  /// **'There are {total} marbles, pick {pick} at random. What is the probability of picking the first marble?'**
  String probabilityMarble(String total, String pick);

  /// Probability question about drawing cards
  ///
  /// In en, this message translates to:
  /// **'There are {total} cards, draw {pick}. What is the probability of drawing the first card?'**
  String probabilityCard(String total, String pick);

  /// Probability question about choosing students
  ///
  /// In en, this message translates to:
  /// **'There are {total} students, choose {pick} to compete. How many ways to choose?'**
  String probabilityStudent(String total, String pick);

  /// Total number of circles and squares
  ///
  /// In en, this message translates to:
  /// **'There are {a} circles and {b} squares. What is the total number of shapes?'**
  String shapesTotal(String a, String b);

  /// Number of shapes left after removing triangles
  ///
  /// In en, this message translates to:
  /// **'There are {a} triangles, {b} squares. If you remove {a} triangles, how many shapes are left?'**
  String shapesRemove(String a, String b);

  /// Total number of circles, squares, triangles
  ///
  /// In en, this message translates to:
  /// **'There are {a} circles, {b} squares, {c} triangles. What is the total number of shapes?'**
  String shapesTotal3(String a, String b, String c);

  /// Time after 2 hours
  ///
  /// In en, this message translates to:
  /// **'It is now {h} o\'clock. What time will it be in 2 hours?'**
  String nowIsHour(String h);

  /// Time after 45 minutes
  ///
  /// In en, this message translates to:
  /// **'It is now {h} hours {m} minutes. What time will it be in 45 minutes?'**
  String nowIsHourMinute(String h, String m);

  /// Time after any minutes
  ///
  /// In en, this message translates to:
  /// **'It is now {h} hours {m} minutes. What time will it be in {add} minutes?'**
  String nowIsHourMinuteAdd(String h, String m, String add);

  /// Day of week after 1 day
  ///
  /// In en, this message translates to:
  /// **'If today is day {a}, what day is tomorrow?'**
  String todayIsDay(String a);

  /// Day of week after n days
  ///
  /// In en, this message translates to:
  /// **'If today is day {a}, what day will it be in {days} days?'**
  String todayIsDayInDays(String a, String days);

  /// No description provided for @divisionQuestion.
  ///
  /// In en, this message translates to:
  /// **'{a} ÷ {b} = ?'**
  String divisionQuestion(String a, String b);

  /// No description provided for @multiplicationQuestion.
  ///
  /// In en, this message translates to:
  /// **'{a} x {b} = ?'**
  String multiplicationQuestion(String a, String b);

  /// No description provided for @powerQuestion.
  ///
  /// In en, this message translates to:
  /// **'{a}^{b} = ?'**
  String powerQuestion(String a, String b);

  /// No description provided for @additionQuestion.
  ///
  /// In en, this message translates to:
  /// **'{a} + {b} = ?'**
  String additionQuestion(String a, String b);

  /// No description provided for @compositeAddMul.
  ///
  /// In en, this message translates to:
  /// **'({a} + {b}) x {c} = ?'**
  String compositeAddMul(String a, String b, String c);

  /// No description provided for @compositeAddMulMinus.
  ///
  /// In en, this message translates to:
  /// **'({a} + {b}) x {c} - {a} = ?'**
  String compositeAddMulMinus(String a, String b, String c);

  /// Subtraction question
  ///
  /// In en, this message translates to:
  /// **'{a} - {b} = ?'**
  String subtractionQuestion(String a, String b);

  /// Fraction addition question
  ///
  /// In en, this message translates to:
  /// **'Calculate: {a}/{b} + {c}/{d} = ?'**
  String fractionAddition(String a, String b, String c, String d);

  /// Fraction subtraction question
  ///
  /// In en, this message translates to:
  /// **'Calculate: {a}/{b} - {c}/{d} = ?'**
  String fractionSubtraction(String a, String b, String c, String d);

  /// Fraction multiplication question
  ///
  /// In en, this message translates to:
  /// **'Calculate: ({a}/{b}) x ({c}/{d}) = ?'**
  String fractionMultiplication(String a, String b, String c, String d);

  /// Prime number question
  ///
  /// In en, this message translates to:
  /// **'Is {n} a prime number?'**
  String isPrime(String n);

  /// Next prime number question
  ///
  /// In en, this message translates to:
  /// **'What is the next prime number after {n}?'**
  String nextPrime(String n);

  /// Count primes question
  ///
  /// In en, this message translates to:
  /// **'How many prime numbers less than {n}?'**
  String countPrimes(String n);

  /// Perfect number question
  ///
  /// In en, this message translates to:
  /// **'Is {n} a perfect number?'**
  String isPerfect(String n);

  /// Next perfect number question
  ///
  /// In en, this message translates to:
  /// **'What is the smallest perfect number greater than {n}?'**
  String nextPerfect(String n);

  /// Count perfect numbers question
  ///
  /// In en, this message translates to:
  /// **'How many perfect numbers less than {n}?'**
  String countPerfects(String n);

  /// Fibonacci number question
  ///
  /// In en, this message translates to:
  /// **'What is the {n}th Fibonacci number?'**
  String fibonacci(String n);

  /// Palindrome number question
  ///
  /// In en, this message translates to:
  /// **'Is {n} a palindrome number?'**
  String isPalindrome(String n);

  /// Even or odd question
  ///
  /// In en, this message translates to:
  /// **'Is {n} even or odd?'**
  String evenOdd(String n);

  /// Power question
  ///
  /// In en, this message translates to:
  /// **'What is {a} to the power of {b}?'**
  String power(String a, String b);

  /// Square question
  ///
  /// In en, this message translates to:
  /// **'What is the square of {a}?'**
  String square(String a);

  /// Square root question
  ///
  /// In en, this message translates to:
  /// **'What is the square root of {a} (rounded)?'**
  String sqrt(String a);

  /// Modulo addition question
  ///
  /// In en, this message translates to:
  /// **'({a} + {b}) mod {m} = ?'**
  String modAdd(String a, String b, String m);

  /// Modulo multiplication question
  ///
  /// In en, this message translates to:
  /// **'({a} x {b}) mod {m} = ?'**
  String modMul(String a, String b, String m);

  /// Modulo power question
  ///
  /// In en, this message translates to:
  /// **'({a}^{b}) mod {m} = ?'**
  String modPow(String a, String b, String m);

  /// Area of square question
  ///
  /// In en, this message translates to:
  /// **'What is the area of a square with side {a}?'**
  String squareArea(String a);

  /// Area of rectangle question
  ///
  /// In en, this message translates to:
  /// **'What is the area of a rectangle {a} x {b}?'**
  String rectangleArea(String a, String b);

  /// Area of triangle question
  ///
  /// In en, this message translates to:
  /// **'What is the area of a triangle with base {a} and height {h}?'**
  String triangleArea(String a, String h);

  /// Identify square question
  ///
  /// In en, this message translates to:
  /// **'Which shape has all sides equal and 4 right angles?'**
  String get shapeWithAllEqualSidesAndRightAngles;

  /// Identify hexagon question
  ///
  /// In en, this message translates to:
  /// **'Which shape has 6 sides?'**
  String get shapeWith6Sides;

  /// Total angles of shape question
  ///
  /// In en, this message translates to:
  /// **'A shape with {sides} sides has how many angles in total?'**
  String totalAnglesOfShape(String sides);

  /// No description provided for @exteriorAngleRegularPolygon.
  ///
  /// In en, this message translates to:
  /// **'What is the exterior angle of a regular {s}-gon?'**
  String exteriorAngleRegularPolygon(String s);

  /// No description provided for @rectanglePerimeter.
  ///
  /// In en, this message translates to:
  /// **'What is the perimeter of a rectangle with sides {a} and {b}?'**
  String rectanglePerimeter(String a, String b);

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get notFound;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect, try again!'**
  String get incorrect;

  /// No description provided for @nextNumberintheSeries.
  ///
  /// In en, this message translates to:
  /// **'Next number in the series'**
  String get nextNumberintheSeries;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @maximumNumberamongC.
  ///
  /// In en, this message translates to:
  /// **'Maximum number among'**
  String get maximumNumberamongC;

  /// No description provided for @evenOddC.
  ///
  /// In en, this message translates to:
  /// **'even or odd'**
  String get evenOddC;

  /// No description provided for @enterAnswer.
  ///
  /// In en, this message translates to:
  /// **'Enter answer'**
  String get enterAnswer;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @discription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get discription;

  /// No description provided for @discriptionSusgget.
  ///
  /// In en, this message translates to:
  /// **'Using a hint will cost 1 coin or require watching an ad, with coins being used first.'**
  String get discriptionSusgget;

  /// No description provided for @agree.
  ///
  /// In en, this message translates to:
  /// **'Agree'**
  String get agree;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @congratulationsDescription.
  ///
  /// In en, this message translates to:
  /// **'You have completed all questions in this topic. Keep exploring other topics!'**
  String get congratulationsDescription;

  /// No description provided for @dongiveup.
  ///
  /// In en, this message translates to:
  /// **'Don\'t give up!'**
  String get dongiveup;

  /// No description provided for @viewDetail.
  ///
  /// In en, this message translates to:
  /// **'View Detail'**
  String get viewDetail;

  /// No description provided for @gotoHomepage.
  ///
  /// In en, this message translates to:
  /// **'Go to Homepage'**
  String get gotoHomepage;

  /// No description provided for @keepPracticing.
  ///
  /// In en, this message translates to:
  /// **'Keep Practicing'**
  String get keepPracticing;

  /// No description provided for @totalQuestions.
  ///
  /// In en, this message translates to:
  /// **'Total Questions'**
  String get totalQuestions;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings & Information'**
  String get settingInfoTitle;

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get sectionGeneral;

  /// No description provided for @sectionStoreInteraction.
  ///
  /// In en, this message translates to:
  /// **'Store & Interaction'**
  String get sectionStoreInteraction;

  /// No description provided for @sectionLegalSupport.
  ///
  /// In en, this message translates to:
  /// **'Legal & Support'**
  String get sectionLegalSupport;

  /// No description provided for @systemSettings.
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get systemSettings;

  /// No description provided for @systemSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Sound, notifications & display'**
  String get systemSettingsDescription;

  /// No description provided for @appInformation.
  ///
  /// In en, this message translates to:
  /// **'App Information'**
  String get appInformation;

  /// No description provided for @appInformationDescription.
  ///
  /// In en, this message translates to:
  /// **'Developer & version'**
  String get appInformationDescription;

  /// No description provided for @home_nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home_nav_home;

  /// No description provided for @home_nav_summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get home_nav_summary;

  /// No description provided for @recentUsage.
  ///
  /// In en, this message translates to:
  /// **'Recent Usage'**
  String get recentUsage;

  /// No description provided for @noRecentUsageLogs.
  ///
  /// In en, this message translates to:
  /// **'No recent usage logs'**
  String get noRecentUsageLogs;

  /// No description provided for @home_nav_store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get home_nav_store;

  /// No description provided for @home_nav_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get home_nav_settings;

  /// No description provided for @appInfo.
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get appInfo;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'App Name'**
  String get appName;

  /// No description provided for @shareAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Share & Support'**
  String get shareAndSupport;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @shareAppDescription.
  ///
  /// In en, this message translates to:
  /// **'Share this app with friends'**
  String get shareAppDescription;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @rateAppDescription.
  ///
  /// In en, this message translates to:
  /// **'Rate us on App Store'**
  String get rateAppDescription;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @feedbackDescription.
  ///
  /// In en, this message translates to:
  /// **'Send us your feedback'**
  String get feedbackDescription;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyDescription.
  ///
  /// In en, this message translates to:
  /// **'Read our privacy policy'**
  String get privacyPolicyDescription;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @termsOfServiceDescription.
  ///
  /// In en, this message translates to:
  /// **'Read our terms of service'**
  String get termsOfServiceDescription;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @helpDescription.
  ///
  /// In en, this message translates to:
  /// **'Get help and support'**
  String get helpDescription;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @contactUsDescription.
  ///
  /// In en, this message translates to:
  /// **'Get in touch with us'**
  String get contactUsDescription;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @supportContact.
  ///
  /// In en, this message translates to:
  /// **'Support contact'**
  String get supportContact;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get openSourceLicenses;

  /// Copyright notice with year placeholder
  ///
  /// In en, this message translates to:
  /// **'© {year} Trường Lâm Profersional .\nAll rights reserved.'**
  String copyrightNotice(Object year);

  /// No description provided for @buyCoins.
  ///
  /// In en, this message translates to:
  /// **'Buy Coins'**
  String get buyCoins;

  /// No description provided for @buyCoinsDescription.
  ///
  /// In en, this message translates to:
  /// **'Purchase coins to unlock hints and features'**
  String get buyCoinsDescription;

  /// Parental consent reminder shown on purchase screen
  ///
  /// In en, this message translates to:
  /// **'Remember to ask your parents before purchasing!'**
  String get askParentsBeforePurchase;

  /// Label for coin unit shown on sticker cards
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get starsUnit;

  /// No description provided for @termsOfConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms of Conditions'**
  String get termsOfConditions;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'minute'**
  String get minute;

  /// No description provided for @purchaseCoins.
  ///
  /// In en, this message translates to:
  /// **'Purchase Coins'**
  String get purchaseCoins;

  /// No description provided for @purchaseCoinsDescription.
  ///
  /// In en, this message translates to:
  /// **'Get more coins to use hints and unlock features'**
  String get purchaseCoinsDescription;

  /// No description provided for @coinShop.
  ///
  /// In en, this message translates to:
  /// **'Coin Shop'**
  String get coinShop;

  /// No description provided for @findFirstAddend.
  ///
  /// In en, this message translates to:
  /// **'If the sum is {sum} and the second addend is {secondAddend}, what is the first addend?'**
  String findFirstAddend(String sum, String secondAddend);

  /// No description provided for @findSecondAddend.
  ///
  /// In en, this message translates to:
  /// **'If the first addend is {firstAddend} and the sum is {sum}, what is the second addend?'**
  String findSecondAddend(String firstAddend, String sum);

  /// No description provided for @findMinuend.
  ///
  /// In en, this message translates to:
  /// **'If the difference is {difference} and the subtrahend is {subtrahend}, what is the minuend?'**
  String findMinuend(String difference, String subtrahend);

  /// No description provided for @findSubtrahend.
  ///
  /// In en, this message translates to:
  /// **'If the minuend is {minuend} and the difference is {difference}, what is the subtrahend?'**
  String findSubtrahend(String minuend, String difference);

  /// No description provided for @findMultiplicand.
  ///
  /// In en, this message translates to:
  /// **'If the product is {product} and the multiplier is {multiplier}, what is the multiplicand?'**
  String findMultiplicand(String product, String multiplier);

  /// No description provided for @findMultiplier.
  ///
  /// In en, this message translates to:
  /// **'If the multiplicand is {multiplicand} and the product is {product}, what is the multiplier?'**
  String findMultiplier(String multiplicand, String product);

  /// No description provided for @findDividend.
  ///
  /// In en, this message translates to:
  /// **'If the quotient is {quotient} and the divisor is {divisor}, what is the dividend?'**
  String findDividend(String quotient, String divisor);

  /// No description provided for @findDivisor.
  ///
  /// In en, this message translates to:
  /// **'If the dividend is {dividend} and the quotient is {quotient}, what is the divisor?'**
  String findDivisor(String dividend, String quotient);

  /// No description provided for @checkIndailytoreceive30coins.
  ///
  /// In en, this message translates to:
  /// **'Check in daily to receive 2 coins'**
  String get checkIndailytoreceive30coins;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check In'**
  String get checkIn;

  /// No description provided for @rollCall.
  ///
  /// In en, this message translates to:
  /// **'Roll Call'**
  String get rollCall;

  /// No description provided for @models.
  ///
  /// In en, this message translates to:
  /// **'Models'**
  String get models;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @selectAIModel.
  ///
  /// In en, this message translates to:
  /// **'Select AI Model'**
  String get selectAIModel;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @multimodal.
  ///
  /// In en, this message translates to:
  /// **'Multimodal'**
  String get multimodal;

  /// No description provided for @functionCalls.
  ///
  /// In en, this message translates to:
  /// **'Function Calls'**
  String get functionCalls;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get thinking;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @showing.
  ///
  /// In en, this message translates to:
  /// **'Showing'**
  String get showing;

  /// No description provided for @function.
  ///
  /// In en, this message translates to:
  /// **'Function'**
  String get function;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @aiModelManager.
  ///
  /// In en, this message translates to:
  /// **'AI Model Manager'**
  String get aiModelManager;

  /// No description provided for @downloadedModels.
  ///
  /// In en, this message translates to:
  /// **'Downloaded Models'**
  String get downloadedModels;

  /// No description provided for @availableModels.
  ///
  /// In en, this message translates to:
  /// **'Available Models'**
  String get availableModels;

  /// No description provided for @manageModels.
  ///
  /// In en, this message translates to:
  /// **'Manage Models'**
  String get manageModels;

  /// No description provided for @modelManagement.
  ///
  /// In en, this message translates to:
  /// **'Model Management'**
  String get modelManagement;

  /// No description provided for @downloadStatus.
  ///
  /// In en, this message translates to:
  /// **'Download Status'**
  String get downloadStatus;

  /// No description provided for @storageUsed.
  ///
  /// In en, this message translates to:
  /// **'Storage Used'**
  String get storageUsed;

  /// No description provided for @totalStorage.
  ///
  /// In en, this message translates to:
  /// **'Total Storage'**
  String get totalStorage;

  /// No description provided for @deleteModel.
  ///
  /// In en, this message translates to:
  /// **'Delete Model'**
  String get deleteModel;

  /// No description provided for @confirmDeleteModel.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this model?'**
  String get confirmDeleteModel;

  /// No description provided for @modelDeleted.
  ///
  /// In en, this message translates to:
  /// **'Model deleted successfully'**
  String get modelDeleted;

  /// No description provided for @noModelsDownloaded.
  ///
  /// In en, this message translates to:
  /// **'No models downloaded yet'**
  String get noModelsDownloaded;

  /// No description provided for @refreshModels.
  ///
  /// In en, this message translates to:
  /// **'Refresh Models'**
  String get refreshModels;

  /// No description provided for @modelDetails.
  ///
  /// In en, this message translates to:
  /// **'Model Details'**
  String get modelDetails;

  /// No description provided for @modelSize.
  ///
  /// In en, this message translates to:
  /// **'Model Size'**
  String get modelSize;

  /// No description provided for @downloadDate.
  ///
  /// In en, this message translates to:
  /// **'Download Date'**
  String get downloadDate;

  /// No description provided for @lastUsed.
  ///
  /// In en, this message translates to:
  /// **'Last Used'**
  String get lastUsed;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @backendType.
  ///
  /// In en, this message translates to:
  /// **'Backend Type'**
  String get backendType;

  /// No description provided for @cpuBackend.
  ///
  /// In en, this message translates to:
  /// **'CPU Backend'**
  String get cpuBackend;

  /// No description provided for @gpuBackend.
  ///
  /// In en, this message translates to:
  /// **'GPU Backend'**
  String get gpuBackend;

  /// No description provided for @modelStatus.
  ///
  /// In en, this message translates to:
  /// **'Model Status'**
  String get modelStatus;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get downloading;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @notDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Not Downloaded'**
  String get notDownloaded;

  /// No description provided for @aiChat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get aiChat;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @aiStatus.
  ///
  /// In en, this message translates to:
  /// **'AI Status'**
  String get aiStatus;

  /// No description provided for @thinkingStatus.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get thinkingStatus;

  /// No description provided for @readyToChat.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get readyToChat;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start Conversation'**
  String get startConversation;

  /// No description provided for @askMeAnything.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about mathematics!\nI can help you solve problems, explain concepts...'**
  String get askMeAnything;

  /// No description provided for @syncMode.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncMode;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeMessage;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get addImage;

  /// No description provided for @changeImage.
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get changeImage;

  /// No description provided for @removeImage.
  ///
  /// In en, this message translates to:
  /// **'Remove Image'**
  String get removeImage;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @addImageDescription.
  ///
  /// In en, this message translates to:
  /// **'Add description to image...'**
  String get addImageDescription;

  /// No description provided for @selectImageSource.
  ///
  /// In en, this message translates to:
  /// **'📷 Select Image Source'**
  String get selectImageSource;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @takeNewPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take New Photo'**
  String get takeNewPhoto;

  /// No description provided for @selectFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select From Gallery'**
  String get selectFromGallery;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @aiProcessing.
  ///
  /// In en, this message translates to:
  /// **'AI Processing...'**
  String get aiProcessing;

  /// No description provided for @composingMessage.
  ///
  /// In en, this message translates to:
  /// **'Composing Message'**
  String get composingMessage;

  /// No description provided for @imageNotSupportedOnWeb.
  ///
  /// In en, this message translates to:
  /// **'Image selection not supported on web yet'**
  String get imageNotSupportedOnWeb;

  /// No description provided for @imageAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Image added successfully'**
  String get imageAddedSuccessfully;

  /// No description provided for @errorSelectingImage.
  ///
  /// In en, this message translates to:
  /// **'Error selecting image'**
  String get errorSelectingImage;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @initializingModel.
  ///
  /// In en, this message translates to:
  /// **'🤖 Initializing AI model...'**
  String get initializingModel;

  /// No description provided for @modelInitialized.
  ///
  /// In en, this message translates to:
  /// **'Model ready'**
  String get modelInitialized;

  /// No description provided for @chatHistory.
  ///
  /// In en, this message translates to:
  /// **'Chat History'**
  String get chatHistory;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newChat;

  /// No description provided for @continueChat.
  ///
  /// In en, this message translates to:
  /// **'Continue Chat'**
  String get continueChat;

  /// No description provided for @imageSupported.
  ///
  /// In en, this message translates to:
  /// **'Image Supported'**
  String get imageSupported;

  /// No description provided for @multimodalSupport.
  ///
  /// In en, this message translates to:
  /// **'Multimodal Support'**
  String get multimodalSupport;

  /// No description provided for @enterYourQuestion.
  ///
  /// In en, this message translates to:
  /// **'Enter your question...'**
  String get enterYourQuestion;

  /// No description provided for @aiThinking.
  ///
  /// In en, this message translates to:
  /// **'🤖 AI is thinking...'**
  String get aiThinking;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error, please try again'**
  String get networkError;

  /// No description provided for @modelError.
  ///
  /// In en, this message translates to:
  /// **'AI model error'**
  String get modelError;

  /// No description provided for @processingImage.
  ///
  /// In en, this message translates to:
  /// **'Processing image...'**
  String get processingImage;

  /// No description provided for @imageProcessed.
  ///
  /// In en, this message translates to:
  /// **'Image processed'**
  String get imageProcessed;

  /// No description provided for @stopGeneration.
  ///
  /// In en, this message translates to:
  /// **'Stop Generation'**
  String get stopGeneration;

  /// No description provided for @generatingResponse.
  ///
  /// In en, this message translates to:
  /// **'Generating response...'**
  String get generatingResponse;

  /// No description provided for @responseGenerated.
  ///
  /// In en, this message translates to:
  /// **'Response generated'**
  String get responseGenerated;

  /// No description provided for @coinInfo.
  ///
  /// In en, this message translates to:
  /// **'Coin Information'**
  String get coinInfo;

  /// No description provided for @costPerChat.
  ///
  /// In en, this message translates to:
  /// **'Cost per chat'**
  String get costPerChat;

  /// No description provided for @fiveCoins.
  ///
  /// In en, this message translates to:
  /// **'5 Coins'**
  String get fiveCoins;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @coinUsageNote.
  ///
  /// In en, this message translates to:
  /// **'• Each message sent will cost 5 coins\n• Coins will be deducted when you send a message\n• Please ensure you have enough coins before chatting'**
  String get coinUsageNote;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// No description provided for @coinInfoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Coin information'**
  String get coinInfoTooltip;

  /// No description provided for @webNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Image selection not supported on web yet'**
  String get webNotSupported;

  /// No description provided for @imageAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Image added successfully'**
  String get imageAddedSuccess;

  /// No description provided for @imageSelectionError.
  ///
  /// In en, this message translates to:
  /// **'Error selecting image'**
  String get imageSelectionError;

  /// No description provided for @enterDiscriptionexplainImage.
  ///
  /// In en, this message translates to:
  /// **'Enter description to explain the image'**
  String get enterDiscriptionexplainImage;

  /// No description provided for @entarYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter your message'**
  String get entarYourMessage;

  /// No description provided for @insufficientCoins.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Coins'**
  String get insufficientCoins;

  /// No description provided for @notEnoughCoins.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have enough coins'**
  String get notEnoughCoins;

  /// No description provided for @needCoinsToSend.
  ///
  /// In en, this message translates to:
  /// **'Need at least 5 coins to send message'**
  String get needCoinsToSend;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @rechargeCoinsMessage.
  ///
  /// In en, this message translates to:
  /// **'Please recharge coins to continue using AI chat service. You can buy coins in the shop.'**
  String get rechargeCoinsMessage;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @rechargeCoins.
  ///
  /// In en, this message translates to:
  /// **'Recharge Coins'**
  String get rechargeCoins;

  /// No description provided for @addition.
  ///
  /// In en, this message translates to:
  /// **'Addition'**
  String get addition;

  /// No description provided for @subtraction.
  ///
  /// In en, this message translates to:
  /// **'Subtraction'**
  String get subtraction;

  /// No description provided for @think.
  ///
  /// In en, this message translates to:
  /// **'Think'**
  String get think;

  /// No description provided for @reflex.
  ///
  /// In en, this message translates to:
  /// **'Reflex'**
  String get reflex;

  /// No description provided for @game.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get game;

  /// No description provided for @home_daily_reward_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Get 10 ⭐ now!'**
  String get home_daily_reward_subtitle;

  /// No description provided for @home_featured_basic_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Get familiar with numbers and basic operations'**
  String get home_featured_basic_subtitle;

  /// No description provided for @home_card_reflex_title.
  ///
  /// In en, this message translates to:
  /// **'Reflex Math'**
  String get home_card_reflex_title;

  /// No description provided for @home_card_reflex_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick hands and sharp eyes'**
  String get home_card_reflex_subtitle;

  /// No description provided for @home_card_think_title.
  ///
  /// In en, this message translates to:
  /// **'Thinking Math'**
  String get home_card_think_title;

  /// No description provided for @home_card_think_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Train your logic'**
  String get home_card_think_subtitle;

  /// No description provided for @home_card_ai_title.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get home_card_ai_title;

  /// No description provided for @home_card_ai_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Fun Q&A'**
  String get home_card_ai_subtitle;

  /// No description provided for @home_card_ai_button.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get home_card_ai_button;

  /// No description provided for @home_card_game_title.
  ///
  /// In en, this message translates to:
  /// **'Fun Game'**
  String get home_card_game_title;

  /// No description provided for @home_card_game_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Play and learn'**
  String get home_card_game_subtitle;

  /// No description provided for @small_card_play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get small_card_play;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get startNow;

  /// No description provided for @challengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Math Challenge'**
  String get challengeTitle;

  /// No description provided for @readyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready?'**
  String get readyTitle;

  /// No description provided for @readySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a challenge that suits you!'**
  String get readySubtitle;

  /// No description provided for @adventurePathTitle.
  ///
  /// In en, this message translates to:
  /// **'Math Adventure'**
  String get adventurePathTitle;

  /// No description provided for @chooseQuestionCount.
  ///
  /// In en, this message translates to:
  /// **'Choose number of questions'**
  String get chooseQuestionCount;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @difficultyEasyDesc.
  ///
  /// In en, this message translates to:
  /// **'Start your adventure!'**
  String get difficultyEasyDesc;

  /// No description provided for @difficultyMediumDesc.
  ///
  /// In en, this message translates to:
  /// **'Explore new lands!'**
  String get difficultyMediumDesc;

  /// No description provided for @difficultyHardDesc.
  ///
  /// In en, this message translates to:
  /// **'Conquer the peak!'**
  String get difficultyHardDesc;

  /// No description provided for @startChallengeSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Starting challenge...'**
  String get startChallengeSnackbar;

  /// No description provided for @topic_list_title.
  ///
  /// In en, this message translates to:
  /// **'Basic Math'**
  String get topic_list_title;

  /// No description provided for @topic_start_button.
  ///
  /// In en, this message translates to:
  /// **'Start Topic'**
  String get topic_start_button;

  /// No description provided for @topic_addition_title.
  ///
  /// In en, this message translates to:
  /// **'Addition'**
  String get topic_addition_title;

  /// No description provided for @topic_addition_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Get familiar with adding numbers and build a strong foundation.'**
  String get topic_addition_subtitle;

  /// No description provided for @topic_subtraction_title.
  ///
  /// In en, this message translates to:
  /// **'Subtraction'**
  String get topic_subtraction_title;

  /// No description provided for @topic_subtraction_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn how to take away from a whole and understand what\'s left.'**
  String get topic_subtraction_subtitle;

  /// No description provided for @topic_mixed_title.
  ///
  /// In en, this message translates to:
  /// **'Basic Mixed Math'**
  String get topic_mixed_title;

  /// No description provided for @topic_mixed_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Practice mixed addition and subtraction to improve calculation skills.'**
  String get topic_mixed_subtitle;

  /// No description provided for @topic_mul_div_title.
  ///
  /// In en, this message translates to:
  /// **'Multiply & Divide'**
  String get topic_mul_div_title;

  /// No description provided for @topic_mul_div_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Core operations: learn multiplication and division.'**
  String get topic_mul_div_subtitle;

  /// No description provided for @topic_division_title.
  ///
  /// In en, this message translates to:
  /// **'Division'**
  String get topic_division_title;

  /// No description provided for @topic_division_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Split into equal parts and develop logical thinking.'**
  String get topic_division_subtitle;

  /// No description provided for @topic_review_title.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive Review'**
  String get topic_review_title;

  /// No description provided for @topic_review_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Combine all four basic operations for full practice.'**
  String get topic_review_subtitle;

  /// No description provided for @topic_fraction_title.
  ///
  /// In en, this message translates to:
  /// **'Fractions & Decimals'**
  String get topic_fraction_title;

  /// No description provided for @topic_fraction_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Understand parts of a whole and convert between fractions and decimals.'**
  String get topic_fraction_subtitle;

  /// No description provided for @topic_even_odd_title.
  ///
  /// In en, this message translates to:
  /// **'Even & Odd Numbers'**
  String get topic_even_odd_title;

  /// No description provided for @topic_even_odd_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Classify numbers and recognize parity.'**
  String get topic_even_odd_subtitle;

  /// No description provided for @topic_prime_title.
  ///
  /// In en, this message translates to:
  /// **'Prime Numbers'**
  String get topic_prime_title;

  /// No description provided for @topic_prime_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore special numbers; learn factors and multiples.'**
  String get topic_prime_subtitle;

  /// No description provided for @topic_power_root_title.
  ///
  /// In en, this message translates to:
  /// **'Powers & Roots'**
  String get topic_power_root_title;

  /// No description provided for @topic_power_root_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore exponents and roots for more advanced operations.'**
  String get topic_power_root_subtitle;

  /// No description provided for @topic_modulo_title.
  ///
  /// In en, this message translates to:
  /// **'Modulo / Remainder'**
  String get topic_modulo_title;

  /// No description provided for @topic_modulo_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Fun modulo math — understand the remainder of division.'**
  String get topic_modulo_subtitle;

  /// No description provided for @topic_algebra_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Recognize and compare images — quick visual reflex.'**
  String get topic_algebra_subtitle;

  /// No description provided for @topic_geometry_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Fractions and fast reading — train visual reflex and quick scanning.'**
  String get topic_geometry_subtitle;

  /// No description provided for @topic_calculus_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Time questions (hours/minutes) — quick-hand speed checks.'**
  String get topic_calculus_subtitle;

  /// No description provided for @topic_advanced_probability_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Number sequences — quick pattern recognition and short reflex challenges.'**
  String get topic_advanced_probability_subtitle;

  /// Subtitle for the Math Logic topic
  ///
  /// In en, this message translates to:
  /// **'Puzzles and reasoning problems that strengthen logical thinking.'**
  String get mathlogic_subtitle;

  /// Subtitle for the Deductive Logic topic
  ///
  /// In en, this message translates to:
  /// **'Practice step-by-step deductive reasoning with logic problems.'**
  String get topic_deductive_subtitle;

  /// Alternate visual logic topic title
  ///
  /// In en, this message translates to:
  /// **'Visual Logic 2'**
  String get visualLogicMath2;

  /// Subtitle for the Special Challenge topic
  ///
  /// In en, this message translates to:
  /// **'Tough, curated questions to push your limits — take the challenge!'**
  String get topic_special_challenge_subtitle;

  /// No description provided for @practice_challenge.
  ///
  /// In en, this message translates to:
  /// **'Challenge'**
  String get practice_challenge;

  /// No description provided for @practice_level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get practice_level;

  /// No description provided for @practice_score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get practice_score;

  /// No description provided for @practice_combo.
  ///
  /// In en, this message translates to:
  /// **'Combo'**
  String get practice_combo;

  /// No description provided for @practice_skip_question.
  ///
  /// In en, this message translates to:
  /// **'Skip this question'**
  String get practice_skip_question;

  /// Question index on practice screen
  ///
  /// In en, this message translates to:
  /// **'Question {current}/{total}'**
  String practice_question_index(int current, int total);

  /// Formatted seconds for timer
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String practice_time_seconds(String seconds);

  /// Points gained display
  ///
  /// In en, this message translates to:
  /// **'+{points} pts'**
  String practice_points_plus(String points);

  /// App version and build number
  ///
  /// In en, this message translates to:
  /// **'Version {version} (Build {build})'**
  String versionandbuild(String version, String build);

  /// No description provided for @progress_by_topic.
  ///
  /// In en, this message translates to:
  /// **'Progress by topic'**
  String get progress_by_topic;

  /// No description provided for @activity_week.
  ///
  /// In en, this message translates to:
  /// **'Activity this week'**
  String get activity_week;

  /// No description provided for @last_7_days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last_7_days;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @baby.
  ///
  /// In en, this message translates to:
  /// **'Baby'**
  String get baby;

  /// No description provided for @gamesHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Play Corner'**
  String get gamesHeaderTitle;

  /// No description provided for @gamesTitleMain.
  ///
  /// In en, this message translates to:
  /// **'It\'s play time!'**
  String get gamesTitleMain;

  /// No description provided for @gamesTitleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What would you like to play?'**
  String get gamesTitleSubtitle;

  /// No description provided for @featuredNew.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get featuredNew;

  /// No description provided for @featuredWeekChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'This week\'s challenge'**
  String get featuredWeekChallengeTitle;

  /// No description provided for @featuredWeekChallengeSub.
  ///
  /// In en, this message translates to:
  /// **'Collect lucky stars!'**
  String get featuredWeekChallengeSub;

  /// No description provided for @gamePikachuTitle.
  ///
  /// In en, this message translates to:
  /// **'Pikachu Connect'**
  String get gamePikachuTitle;

  /// No description provided for @gamePikachuSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Train memory'**
  String get gamePikachuSubtitle;

  /// No description provided for @gameTetrisTitle.
  ///
  /// In en, this message translates to:
  /// **'Tetris'**
  String get gameTetrisTitle;

  /// No description provided for @gameTetrisSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fun block puzzle'**
  String get gameTetrisSubtitle;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOver;

  /// Score message shown in game over dialog with placeholder {score}
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String scoreMessage(Object score);

  /// No description provided for @gamePacmanTitle.
  ///
  /// In en, this message translates to:
  /// **'Pac-men'**
  String get gamePacmanTitle;

  /// No description provided for @gamePacmanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Eat points in the maze'**
  String get gamePacmanSubtitle;

  /// No description provided for @game2048Title.
  ///
  /// In en, this message translates to:
  /// **'2048'**
  String get game2048Title;

  /// No description provided for @game2048Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Smart number merge'**
  String get game2048Subtitle;

  /// No description provided for @gameWordTitle.
  ///
  /// In en, this message translates to:
  /// **'Word Puzzle'**
  String get gameWordTitle;

  /// No description provided for @gameWordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn words with images'**
  String get gameWordSubtitle;

  /// No description provided for @gameDuckTitle.
  ///
  /// In en, this message translates to:
  /// **'Duck War'**
  String get gameDuckTitle;

  /// No description provided for @gameDuckSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fun duck shooting'**
  String get gameDuckSubtitle;

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// No description provided for @rectangle.
  ///
  /// In en, this message translates to:
  /// **'Rectangle'**
  String get rectangle;

  /// No description provided for @triangle.
  ///
  /// In en, this message translates to:
  /// **'Triangle'**
  String get triangle;

  /// No description provided for @circle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get circle;

  /// No description provided for @either.
  ///
  /// In en, this message translates to:
  /// **'either'**
  String get either;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// No description provided for @hintDescription.
  ///
  /// In en, this message translates to:
  /// **'Use a hint to help answer the question. This will cost 1 star.'**
  String get hintDescription;

  /// No description provided for @useCoins.
  ///
  /// In en, this message translates to:
  /// **'Use stars'**
  String get useCoins;

  /// Description for using coins for hints
  ///
  /// In en, this message translates to:
  /// **'Using a hint will cost 1 coin. You have {coins} stars.'**
  String useCoinDescription(String coins);

  /// No description provided for @coinUnit.
  ///
  /// In en, this message translates to:
  /// **'stars'**
  String get coinUnit;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @watchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad'**
  String get watchAd;

  /// No description provided for @watchAdDescription.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad to get a hint for free.'**
  String get watchAdDescription;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @addCoinsToTreasury.
  ///
  /// In en, this message translates to:
  /// **'Add stars to treasury'**
  String get addCoinsToTreasury;

  /// No description provided for @get.
  ///
  /// In en, this message translates to:
  /// **'Get'**
  String get get;

  /// No description provided for @ads_not_ready_please_try_again_later.
  ///
  /// In en, this message translates to:
  /// **'Ads not ready, please try again later.'**
  String get ads_not_ready_please_try_again_later;

  /// No description provided for @gamePackPalTitle.
  ///
  /// In en, this message translates to:
  /// **'Pack Pal'**
  String get gamePackPalTitle;

  /// No description provided for @gamePackPalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help the pack find their way home!'**
  String get gamePackPalSubtitle;

  /// No description provided for @gameCircuitTitle.
  ///
  /// In en, this message translates to:
  /// **'Circuit Connect'**
  String get gameCircuitTitle;

  /// No description provided for @gameCircuitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect the circuits to complete the path!'**
  String get gameCircuitSubtitle;

  /// No description provided for @gameQuantumTitle.
  ///
  /// In en, this message translates to:
  /// **'Quantum Link'**
  String get gameQuantumTitle;

  /// No description provided for @gameQuantumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Solve quantum puzzles and link the particles!'**
  String get gameQuantumSubtitle;

  /// No description provided for @game2048Header.
  ///
  /// In en, this message translates to:
  /// **'Play 2048'**
  String get game2048Header;

  /// No description provided for @scoreCardLabel.
  ///
  /// In en, this message translates to:
  /// **'SCORE'**
  String get scoreCardLabel;

  /// No description provided for @bestCardLabel.
  ///
  /// In en, this message translates to:
  /// **'BEST'**
  String get bestCardLabel;

  /// No description provided for @aiHintBubble.
  ///
  /// In en, this message translates to:
  /// **'Try combining two 4 tiles! You can do it!'**
  String get aiHintBubble;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @aiHint.
  ///
  /// In en, this message translates to:
  /// **'AI Hint'**
  String get aiHint;

  /// No description provided for @featureLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Feature will be unlocked soon!'**
  String get featureLockedMessage;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
