// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get preferredLanguage => 'English';

  @override
  String get newUpdate => 'New Update – A Fresh Look Is Here!';

  @override
  String get newUpdateDescription =>
      'We’ve redesigned your experience from the ground up! Get ready for a sleek, modern, and faster interface that makes everything smoother and more intuitive.';

  @override
  String get updateLater => 'Update Later';

  @override
  String get updateNow => 'Update Now';

  @override
  String get listofTopics => ' List of Topics';

  @override
  String get selectlevelandnumberofquestionsBottomsheetdata =>
      'Select level and number of questions';

  @override
  String get level => 'Level';

  @override
  String get numberOfquestions => 'Number of questions';

  @override
  String get cancel => 'Cancel';

  @override
  String get start => 'Start';

  @override
  String get basicMath => 'Basic Math';

  @override
  String get mathlogic => 'Math Logic';

  @override
  String get funGeometry => 'Fun Geometry';

  @override
  String get advancedArithmetic => 'Advanced arithmetic';

  @override
  String get specialChallenge => 'Special Challenge';

  @override
  String get probabilityMath => 'Probability Math';

  @override
  String get visualLogicMath => 'Visual Logic Math';

  @override
  String get timeMath => 'Time Math';

  @override
  String get sequenceMath => 'Sequence Math';

  @override
  String get deductiveLogicMath => 'Deductive Logic Math';

  @override
  String get divisionMath => 'Division Math';

  @override
  String get comprehensiveArithmetic => 'Comprehensive Arithmetic';

  @override
  String get fractionMath => 'Fraction Math';

  @override
  String get primeNumberMath => 'Prime Number Math';

  @override
  String get perfectNumberMath => 'Perfect Number Math';

  @override
  String get fibonacciMath => 'Fibonacci Math';

  @override
  String get palindromeNumberMath => 'Palindrome Number Math';

  @override
  String get oddEvenNumberMath => 'Odd/Even Number Math';

  @override
  String get powerAndRootMath => 'Power and Root Math';

  @override
  String get moduloMath => 'Modulo Math';

  @override
  String get chooseThecorrectsign => 'Choose the correct sign';

  @override
  String get fillInthemissingnumber => 'Fill in the missing number';

  @override
  String maximumnumber(String numbers) {
    return 'Maximum number among: $numbers is?';
  }

  @override
  String get isItevenorodd => 'Is it even or odd?';

  @override
  String get even => 'Even';

  @override
  String get odd => 'Odd';

  @override
  String ifExpressionresultthenwhatisunknown(
    String expression,
    String result,
    String unknown,
  ) {
    return 'If $expression = $result, then what is $unknown?';
  }

  @override
  String whatShapehassides(String sides) {
    return 'What shape has $sides sides?';
  }

  @override
  String get whatIsthemeasureofarightangle =>
      'What is the measure of a right angle?';

  @override
  String theCircumferenceofacirclewithradiusisrounded(String radius) {
    return 'The circumference of a circle with radius $radius is rounded to the nearest whole number.';
  }

  @override
  String get round => 'Round';

  @override
  String findXAddition(String a, String sum) {
    return 'Find x: x + $a = $sum';
  }

  @override
  String findXSubtraction(String a, String b) {
    return 'Find x: x - $a = $b';
  }

  @override
  String findXMultiplication(String a, String b) {
    return 'Find x: x x $a = $b';
  }

  @override
  String probabilityMarble(String total, String pick) {
    return 'There are $total marbles, pick $pick at random. What is the probability of picking the first marble?';
  }

  @override
  String probabilityCard(String total, String pick) {
    return 'There are $total cards, draw $pick. What is the probability of drawing the first card?';
  }

  @override
  String probabilityStudent(String total, String pick) {
    return 'There are $total students, choose $pick to compete. How many ways to choose?';
  }

  @override
  String shapesTotal(String a, String b) {
    return 'There are $a circles and $b squares. What is the total number of shapes?';
  }

  @override
  String shapesRemove(String a, String b) {
    return 'There are $a triangles, $b squares. If you remove $a triangles, how many shapes are left?';
  }

  @override
  String shapesTotal3(String a, String b, String c) {
    return 'There are $a circles, $b squares, $c triangles. What is the total number of shapes?';
  }

  @override
  String nowIsHour(String h) {
    return 'It is now $h o\'clock. What time will it be in 2 hours?';
  }

  @override
  String nowIsHourMinute(String h, String m) {
    return 'It is now $h hours $m minutes. What time will it be in 45 minutes?';
  }

  @override
  String nowIsHourMinuteAdd(String h, String m, String add) {
    return 'It is now $h hours $m minutes. What time will it be in $add minutes?';
  }

  @override
  String todayIsDay(String a) {
    return 'If today is day $a, what day is tomorrow?';
  }

  @override
  String todayIsDayInDays(String a, String days) {
    return 'If today is day $a, what day will it be in $days days?';
  }

  @override
  String divisionQuestion(String a, String b) {
    return '$a ÷ $b = ?';
  }

  @override
  String multiplicationQuestion(String a, String b) {
    return '$a x $b = ?';
  }

  @override
  String powerQuestion(String a, String b) {
    return '$a^$b = ?';
  }

  @override
  String additionQuestion(String a, String b) {
    return '$a + $b = ?';
  }

  @override
  String compositeAddMul(String a, String b, String c) {
    return '($a + $b) x $c = ?';
  }

  @override
  String compositeAddMulMinus(String a, String b, String c) {
    return '($a + $b) x $c - $a = ?';
  }

  @override
  String subtractionQuestion(String a, String b) {
    return '$a - $b = ?';
  }

  @override
  String fractionAddition(String a, String b, String c, String d) {
    return 'Calculate: $a/$b + $c/$d = ?';
  }

  @override
  String fractionSubtraction(String a, String b, String c, String d) {
    return 'Calculate: $a/$b - $c/$d = ?';
  }

  @override
  String fractionMultiplication(String a, String b, String c, String d) {
    return 'Calculate: ($a/$b) x ($c/$d) = ?';
  }

  @override
  String isPrime(String n) {
    return 'Is $n a prime number?';
  }

  @override
  String nextPrime(String n) {
    return 'What is the next prime number after $n?';
  }

  @override
  String countPrimes(String n) {
    return 'How many prime numbers less than $n?';
  }

  @override
  String isPerfect(String n) {
    return 'Is $n a perfect number?';
  }

  @override
  String nextPerfect(String n) {
    return 'What is the smallest perfect number greater than $n?';
  }

  @override
  String countPerfects(String n) {
    return 'How many perfect numbers less than $n?';
  }

  @override
  String fibonacci(String n) {
    return 'What is the ${n}th Fibonacci number?';
  }

  @override
  String isPalindrome(String n) {
    return 'Is $n a palindrome number?';
  }

  @override
  String evenOdd(String n) {
    return 'Is $n even or odd?';
  }

  @override
  String power(String a, String b) {
    return 'What is $a to the power of $b?';
  }

  @override
  String square(String a) {
    return 'What is the square of $a?';
  }

  @override
  String sqrt(String a) {
    return 'What is the square root of $a (rounded)?';
  }

  @override
  String modAdd(String a, String b, String m) {
    return '($a + $b) mod $m = ?';
  }

  @override
  String modMul(String a, String b, String m) {
    return '($a x $b) mod $m = ?';
  }

  @override
  String modPow(String a, String b, String m) {
    return '($a^$b) mod $m = ?';
  }

  @override
  String squareArea(String a) {
    return 'What is the area of a square with side $a?';
  }

  @override
  String rectangleArea(String a, String b) {
    return 'What is the area of a rectangle $a x $b?';
  }

  @override
  String triangleArea(String a, String h) {
    return 'What is the area of a triangle with base $a and height $h?';
  }

  @override
  String get shapeWithAllEqualSidesAndRightAngles =>
      'Which shape has all sides equal and 4 right angles?';

  @override
  String get shapeWith6Sides => 'Which shape has 6 sides?';

  @override
  String totalAnglesOfShape(String sides) {
    return 'A shape with $sides sides has how many angles in total?';
  }

  @override
  String exteriorAngleRegularPolygon(String s) {
    return 'What is the exterior angle of a regular $s-gon?';
  }

  @override
  String rectanglePerimeter(String a, String b) {
    return 'What is the perimeter of a rectangle with sides $a and $b?';
  }

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get notFound => 'Not found';

  @override
  String get correct => 'Correct!';

  @override
  String get incorrect => 'Incorrect, try again!';

  @override
  String get nextNumberintheSeries => 'Next number in the series';

  @override
  String get save => 'Save';

  @override
  String get maximumNumberamongC => 'Maximum number among';

  @override
  String get evenOddC => 'even or odd';

  @override
  String get enterAnswer => 'Enter answer';

  @override
  String get next => 'Next';

  @override
  String get question => 'Question';

  @override
  String get discription => 'Description';

  @override
  String get discriptionSusgget =>
      'Using a hint will cost 1 coin or require watching an ad, with coins being used first.';

  @override
  String get agree => 'Agree';

  @override
  String get result => 'Result';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get congratulationsDescription =>
      'You have completed all questions in this topic. Keep exploring other topics!';

  @override
  String get dongiveup => 'Don\'t give up!';

  @override
  String get viewDetail => 'View Detail';

  @override
  String get gotoHomepage => 'Go to Homepage';

  @override
  String get keepPracticing => 'Keep Practicing';

  @override
  String get totalQuestions => 'Total Questions';

  @override
  String get settings => 'Settings';

  @override
  String get settingInfoTitle => 'Settings & Information';

  @override
  String get sectionGeneral => 'General Settings';

  @override
  String get sectionStoreInteraction => 'Store & Interaction';

  @override
  String get sectionLegalSupport => 'Legal & Support';

  @override
  String get systemSettings => 'System Settings';

  @override
  String get systemSettingsDescription => 'Sound, notifications & display';

  @override
  String get appInformation => 'App Information';

  @override
  String get appInformationDescription => 'Developer & version';

  @override
  String get home_nav_home => 'Home';

  @override
  String get home_nav_summary => 'Summary';

  @override
  String get recentUsage => 'Recent Usage';

  @override
  String get noRecentUsageLogs => 'No recent usage logs';

  @override
  String get home_nav_store => 'Store';

  @override
  String get home_nav_settings => 'Settings';

  @override
  String get appInfo => 'App Info';

  @override
  String get version => 'Version';

  @override
  String get appName => 'App Name';

  @override
  String get shareAndSupport => 'Share & Support';

  @override
  String get shareApp => 'Share App';

  @override
  String get shareAppDescription => 'Share this app with friends';

  @override
  String get rateApp => 'Rate App';

  @override
  String get rateAppDescription => 'Rate us on App Store';

  @override
  String get feedback => 'Feedback';

  @override
  String get feedbackDescription => 'Send us your feedback';

  @override
  String get legal => 'Legal';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyDescription => 'Read our privacy policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get termsOfServiceDescription => 'Read our terms of service';

  @override
  String get about => 'About';

  @override
  String get help => 'Help';

  @override
  String get helpDescription => 'Get help and support';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get contactUsDescription => 'Get in touch with us';

  @override
  String get developer => 'Developer';

  @override
  String get website => 'Website';

  @override
  String get supportContact => 'Support contact';

  @override
  String get openSourceLicenses => 'Open source licenses';

  @override
  String copyrightNotice(Object year) {
    return '© $year Trường Lâm Profersional .\nAll rights reserved.';
  }

  @override
  String get buyCoins => 'Buy Coins';

  @override
  String get buyCoinsDescription =>
      'Purchase coins to unlock hints and features';

  @override
  String get askParentsBeforePurchase =>
      'Remember to ask your parents before purchasing!';

  @override
  String get starsUnit => 'Stars';

  @override
  String get termsOfConditions => 'Terms of Conditions';

  @override
  String get time => 'Time';

  @override
  String get hour => 'hour';

  @override
  String get minute => 'minute';

  @override
  String get purchaseCoins => 'Purchase Coins';

  @override
  String get purchaseCoinsDescription =>
      'Get more coins to use hints and unlock features';

  @override
  String get coinShop => 'Coin Shop';

  @override
  String findFirstAddend(String sum, String secondAddend) {
    return 'If the sum is $sum and the second addend is $secondAddend, what is the first addend?';
  }

  @override
  String findSecondAddend(String firstAddend, String sum) {
    return 'If the first addend is $firstAddend and the sum is $sum, what is the second addend?';
  }

  @override
  String findMinuend(String difference, String subtrahend) {
    return 'If the difference is $difference and the subtrahend is $subtrahend, what is the minuend?';
  }

  @override
  String findSubtrahend(String minuend, String difference) {
    return 'If the minuend is $minuend and the difference is $difference, what is the subtrahend?';
  }

  @override
  String findMultiplicand(String product, String multiplier) {
    return 'If the product is $product and the multiplier is $multiplier, what is the multiplicand?';
  }

  @override
  String findMultiplier(String multiplicand, String product) {
    return 'If the multiplicand is $multiplicand and the product is $product, what is the multiplier?';
  }

  @override
  String findDividend(String quotient, String divisor) {
    return 'If the quotient is $quotient and the divisor is $divisor, what is the dividend?';
  }

  @override
  String findDivisor(String dividend, String quotient) {
    return 'If the dividend is $dividend and the quotient is $quotient, what is the divisor?';
  }

  @override
  String get checkIndailytoreceive30coins =>
      'Check in daily to receive 2 coins';

  @override
  String get checkIn => 'Check In';

  @override
  String get rollCall => 'Roll Call';

  @override
  String get models => 'Models';

  @override
  String get model => 'Model';

  @override
  String get selectAIModel => 'Select AI Model';

  @override
  String get filters => 'Filters';

  @override
  String get features => 'Features';

  @override
  String get multimodal => 'Multimodal';

  @override
  String get functionCalls => 'Function Calls';

  @override
  String get thinking => 'Thinking';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get sort => 'Sort';

  @override
  String get showing => 'Showing';

  @override
  String get function => 'Function';

  @override
  String get chat => 'Chat';

  @override
  String get aiModelManager => 'AI Model Manager';

  @override
  String get downloadedModels => 'Downloaded Models';

  @override
  String get availableModels => 'Available Models';

  @override
  String get manageModels => 'Manage Models';

  @override
  String get modelManagement => 'Model Management';

  @override
  String get downloadStatus => 'Download Status';

  @override
  String get storageUsed => 'Storage Used';

  @override
  String get totalStorage => 'Total Storage';

  @override
  String get deleteModel => 'Delete Model';

  @override
  String get confirmDeleteModel =>
      'Are you sure you want to delete this model?';

  @override
  String get modelDeleted => 'Model deleted successfully';

  @override
  String get noModelsDownloaded => 'No models downloaded yet';

  @override
  String get refreshModels => 'Refresh Models';

  @override
  String get modelDetails => 'Model Details';

  @override
  String get modelSize => 'Model Size';

  @override
  String get downloadDate => 'Download Date';

  @override
  String get lastUsed => 'Last Used';

  @override
  String get viewAll => 'View All';

  @override
  String get backendType => 'Backend Type';

  @override
  String get cpuBackend => 'CPU Backend';

  @override
  String get gpuBackend => 'GPU Backend';

  @override
  String get modelStatus => 'Model Status';

  @override
  String get ready => 'Ready';

  @override
  String get downloading => 'Downloading';

  @override
  String get failed => 'Failed';

  @override
  String get notDownloaded => 'Not Downloaded';

  @override
  String get aiChat => 'AI Chat';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get aiStatus => 'AI Status';

  @override
  String get thinkingStatus => 'Thinking...';

  @override
  String get readyToChat => 'Ready';

  @override
  String get startConversation => 'Start Conversation';

  @override
  String get askMeAnything =>
      'Ask me anything about mathematics!\nI can help you solve problems, explain concepts...';

  @override
  String get syncMode => 'Sync';

  @override
  String get typeMessage => 'Type your message...';

  @override
  String get addImage => 'Add Image';

  @override
  String get changeImage => 'Change Image';

  @override
  String get removeImage => 'Remove Image';

  @override
  String get sendMessage => 'Send Message';

  @override
  String get addImageDescription => 'Add description to image...';

  @override
  String get selectImageSource => '📷 Select Image Source';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get takeNewPhoto => 'Take New Photo';

  @override
  String get selectFromGallery => 'Select From Gallery';

  @override
  String get image => 'Image';

  @override
  String get aiProcessing => 'AI Processing...';

  @override
  String get composingMessage => 'Composing Message';

  @override
  String get imageNotSupportedOnWeb =>
      'Image selection not supported on web yet';

  @override
  String get imageAddedSuccessfully => 'Image added successfully';

  @override
  String get errorSelectingImage => 'Error selecting image';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get copy => 'Copy';

  @override
  String get initializingModel => '🤖 Initializing AI model...';

  @override
  String get modelInitialized => 'Model ready';

  @override
  String get chatHistory => 'Chat History';

  @override
  String get newChat => 'New Chat';

  @override
  String get continueChat => 'Continue Chat';

  @override
  String get imageSupported => 'Image Supported';

  @override
  String get multimodalSupport => 'Multimodal Support';

  @override
  String get enterYourQuestion => 'Enter your question...';

  @override
  String get aiThinking => '🤖 AI is thinking...';

  @override
  String get retry => 'Retry';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get networkError => 'Network error, please try again';

  @override
  String get modelError => 'AI model error';

  @override
  String get processingImage => 'Processing image...';

  @override
  String get imageProcessed => 'Image processed';

  @override
  String get stopGeneration => 'Stop Generation';

  @override
  String get generatingResponse => 'Generating response...';

  @override
  String get responseGenerated => 'Response generated';

  @override
  String get coinInfo => 'Coin Information';

  @override
  String get costPerChat => 'Cost per chat';

  @override
  String get fiveCoins => '5 Coins';

  @override
  String get note => 'Note';

  @override
  String get coinUsageNote =>
      '• Each message sent will cost 5 coins\n• Coins will be deducted when you send a message\n• Please ensure you have enough coins before chatting';

  @override
  String get understood => 'Understood';

  @override
  String get coinInfoTooltip => 'Coin information';

  @override
  String get webNotSupported => 'Image selection not supported on web yet';

  @override
  String get imageAddedSuccess => 'Image added successfully';

  @override
  String get imageSelectionError => 'Error selecting image';

  @override
  String get enterDiscriptionexplainImage =>
      'Enter description to explain the image';

  @override
  String get entarYourMessage => 'Enter your message';

  @override
  String get insufficientCoins => 'Insufficient Coins';

  @override
  String get notEnoughCoins => 'You don\'t have enough coins';

  @override
  String get needCoinsToSend => 'Need at least 5 coins to send message';

  @override
  String get information => 'Information';

  @override
  String get rechargeCoinsMessage =>
      'Please recharge coins to continue using AI chat service. You can buy coins in the shop.';

  @override
  String get close => 'Close';

  @override
  String get rechargeCoins => 'Recharge Coins';

  @override
  String get addition => 'Addition';

  @override
  String get subtraction => 'Subtraction';

  @override
  String get think => 'Think';

  @override
  String get reflex => 'Reflex';

  @override
  String get game => 'Game';

  @override
  String get home_daily_reward_subtitle => 'Get 10 ⭐ now!';

  @override
  String get home_featured_basic_subtitle =>
      'Get familiar with numbers and basic operations';

  @override
  String get home_card_reflex_title => 'Reflex Math';

  @override
  String get home_card_reflex_subtitle => 'Quick hands and sharp eyes';

  @override
  String get home_card_think_title => 'Thinking Math';

  @override
  String get home_card_think_subtitle => 'Train your logic';

  @override
  String get home_card_ai_title => 'AI Chat';

  @override
  String get home_card_ai_subtitle => 'Fun Q&A';

  @override
  String get home_card_ai_button => 'Chat';

  @override
  String get home_card_game_title => 'Fun Game';

  @override
  String get home_card_game_subtitle => 'Play and learn';

  @override
  String get small_card_play => 'Play';

  @override
  String get startNow => 'Start Now';

  @override
  String get challengeTitle => 'Math Challenge';

  @override
  String get readyTitle => 'Ready?';

  @override
  String get readySubtitle => 'Choose a challenge that suits you!';

  @override
  String get adventurePathTitle => 'Math Adventure';

  @override
  String get chooseQuestionCount => 'Choose number of questions';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get difficultyEasyDesc => 'Start your adventure!';

  @override
  String get difficultyMediumDesc => 'Explore new lands!';

  @override
  String get difficultyHardDesc => 'Conquer the peak!';

  @override
  String get startChallengeSnackbar => 'Starting challenge...';

  @override
  String get topic_list_title => 'Basic Math';

  @override
  String get topic_start_button => 'Start Topic';

  @override
  String get topic_addition_title => 'Addition';

  @override
  String get topic_addition_subtitle =>
      'Get familiar with adding numbers and build a strong foundation.';

  @override
  String get topic_subtraction_title => 'Subtraction';

  @override
  String get topic_subtraction_subtitle =>
      'Learn how to take away from a whole and understand what\'s left.';

  @override
  String get topic_mixed_title => 'Basic Mixed Math';

  @override
  String get topic_mixed_subtitle =>
      'Practice mixed addition and subtraction to improve calculation skills.';

  @override
  String get topic_mul_div_title => 'Multiply & Divide';

  @override
  String get topic_mul_div_subtitle =>
      'Core operations: learn multiplication and division.';

  @override
  String get topic_division_title => 'Division';

  @override
  String get topic_division_subtitle =>
      'Split into equal parts and develop logical thinking.';

  @override
  String get topic_review_title => 'Comprehensive Review';

  @override
  String get topic_review_subtitle =>
      'Combine all four basic operations for full practice.';

  @override
  String get topic_fraction_title => 'Fractions & Decimals';

  @override
  String get topic_fraction_subtitle =>
      'Understand parts of a whole and convert between fractions and decimals.';

  @override
  String get topic_even_odd_title => 'Even & Odd Numbers';

  @override
  String get topic_even_odd_subtitle =>
      'Classify numbers and recognize parity.';

  @override
  String get topic_prime_title => 'Prime Numbers';

  @override
  String get topic_prime_subtitle =>
      'Explore special numbers; learn factors and multiples.';

  @override
  String get topic_power_root_title => 'Powers & Roots';

  @override
  String get topic_power_root_subtitle =>
      'Explore exponents and roots for more advanced operations.';

  @override
  String get topic_modulo_title => 'Modulo / Remainder';

  @override
  String get topic_modulo_subtitle =>
      'Fun modulo math — understand the remainder of division.';

  @override
  String get topic_algebra_subtitle =>
      'Recognize and compare images — quick visual reflex.';

  @override
  String get topic_geometry_subtitle =>
      'Fractions and fast reading — train visual reflex and quick scanning.';

  @override
  String get topic_calculus_subtitle =>
      'Time questions (hours/minutes) — quick-hand speed checks.';

  @override
  String get topic_advanced_probability_subtitle =>
      'Number sequences — quick pattern recognition and short reflex challenges.';

  @override
  String get mathlogic_subtitle =>
      'Puzzles and reasoning problems that strengthen logical thinking.';

  @override
  String get topic_deductive_subtitle =>
      'Practice step-by-step deductive reasoning with logic problems.';

  @override
  String get visualLogicMath2 => 'Visual Logic 2';

  @override
  String get topic_special_challenge_subtitle =>
      'Tough, curated questions to push your limits — take the challenge!';

  @override
  String get practice_challenge => 'Challenge';

  @override
  String get practice_level => 'Level';

  @override
  String get practice_score => 'Score';

  @override
  String get practice_combo => 'Combo';

  @override
  String get practice_skip_question => 'Skip this question';

  @override
  String practice_question_index(int current, int total) {
    return 'Question $current/$total';
  }

  @override
  String practice_time_seconds(String seconds) {
    return '${seconds}s';
  }

  @override
  String practice_points_plus(String points) {
    return '+$points pts';
  }

  @override
  String versionandbuild(String version, String build) {
    return 'Version $version (Build $build)';
  }

  @override
  String get progress_by_topic => 'Progress by topic';

  @override
  String get activity_week => 'Activity this week';

  @override
  String get last_7_days => 'Last 7 days';

  @override
  String get hello => 'Hello';

  @override
  String get baby => 'Baby';

  @override
  String get gamesHeaderTitle => 'Play Corner';

  @override
  String get gamesTitleMain => 'It\'s play time!';

  @override
  String get gamesTitleSubtitle => 'What would you like to play?';

  @override
  String get featuredNew => 'NEW';

  @override
  String get featuredWeekChallengeTitle => 'This week\'s challenge';

  @override
  String get featuredWeekChallengeSub => 'Collect lucky stars!';

  @override
  String get gamePikachuTitle => 'Pikachu Connect';

  @override
  String get gamePikachuSubtitle => 'Train memory';

  @override
  String get gameTetrisTitle => 'Tetris';

  @override
  String get gameTetrisSubtitle => 'Fun block puzzle';

  @override
  String get exit => 'Exit';

  @override
  String get playAgain => 'Play Again';

  @override
  String get gameOver => 'Game Over';

  @override
  String scoreMessage(Object score) {
    return 'Score: $score';
  }

  @override
  String get gamePacmanTitle => 'Pac-men';

  @override
  String get gamePacmanSubtitle => 'Eat points in the maze';

  @override
  String get game2048Title => '2048';

  @override
  String get game2048Subtitle => 'Smart number merge';

  @override
  String get gameWordTitle => 'Word Puzzle';

  @override
  String get gameWordSubtitle => 'Learn words with images';

  @override
  String get gameDuckTitle => 'Duck War';

  @override
  String get gameDuckSubtitle => 'Fun duck shooting';

  @override
  String get latest => 'Latest';

  @override
  String get rectangle => 'Rectangle';

  @override
  String get triangle => 'Triangle';

  @override
  String get circle => 'Circle';

  @override
  String get either => 'either';

  @override
  String get hint => 'Hint';

  @override
  String get hintDescription =>
      'Use a hint to help answer the question. This will cost 1 star.';

  @override
  String get useCoins => 'Use stars';

  @override
  String useCoinDescription(String coins) {
    return 'Using a hint will cost 1 coin. You have $coins stars.';
  }

  @override
  String get coinUnit => 'stars';

  @override
  String get or => 'or';

  @override
  String get watchAd => 'Watch Ad';

  @override
  String get watchAdDescription => 'Watch an ad to get a hint for free.';

  @override
  String get free => 'Free';

  @override
  String get addCoinsToTreasury => 'Add stars to treasury';

  @override
  String get get => 'Get';

  @override
  String get ads_not_ready_please_try_again_later =>
      'Ads not ready, please try again later.';

  @override
  String get gamePackPalTitle => 'Pack Pal';

  @override
  String get gamePackPalSubtitle => 'Help the pack find their way home!';

  @override
  String get gameCircuitTitle => 'Circuit Connect';

  @override
  String get gameCircuitSubtitle =>
      'Connect the circuits to complete the path!';

  @override
  String get gameQuantumTitle => 'Quantum Link';

  @override
  String get gameQuantumSubtitle =>
      'Solve quantum puzzles and link the particles!';

  @override
  String get game2048Header => 'Play 2048';

  @override
  String get scoreCardLabel => 'SCORE';

  @override
  String get bestCardLabel => 'BEST';

  @override
  String get aiHintBubble => 'Try combining two 4 tiles! You can do it!';

  @override
  String get reset => 'Reset';

  @override
  String get aiHint => 'AI Hint';

  @override
  String get featureLockedMessage => 'Feature will be unlocked soon!';

  @override
  String get undo => 'Undo';

  @override
  String get removeAdsTitle => 'Remove Ads';

  @override
  String get premiumActiveMessage =>
      'You are using the Premium version!\nAll ads have been disabled.';

  @override
  String get premiumExpirePrefix => 'Expires: ';

  @override
  String get upgradePremiumMessage =>
      'Upgrade to Premium\nEnjoy a smooth, ad-free experience.';

  @override
  String get subscribeNowPrefix => 'Subscribe now ';

  @override
  String get noSubscriptionPackages =>
      'No subscription packages found. Please check your connection or network configuration.';

  @override
  String get restorePurchases => 'Purchased before? Restore here';

  @override
  String get aiFriendTitle => 'AI Friend';

  @override
  String get onlineStatus => 'Online';

  @override
  String get downloadingOfflineModel => 'Downloading Offline AI Model';

  @override
  String get doNotCloseAppWarning =>
      '⚠️ NOTE: Please DO NOT close the app while downloading. If the app is closed, the download will restart from the beginning.\n\nOnce complete, you can use the AI offline without internet!';

  @override
  String get ramRecommendationTitle => 'Recommended RAM Requirements:';

  @override
  String get ramRecommendationDesc =>
      '📱 3GB  ❌ Prone to crash\n📱 4GB  ⚠️ Very tight\n📱 6GB  ✅ Stable\n📱 8GB+ 🔥 Smooth';

  @override
  String get defaultChatTitle => 'AI Conversation';

  @override
  String get deleteChatTitle => 'Delete conversation';

  @override
  String get deleteChatConfirmContent =>
      'Are you sure you want to delete this chat history?';

  @override
  String get deleteAction => 'Delete';
}
