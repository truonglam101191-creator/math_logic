// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get preferredLanguage => 'Tiếng Việt';

  @override
  String get newUpdate => 'Cập nhật mới – Giao diện hoàn toàn mới!';

  @override
  String get newUpdateDescription =>
      'Chúng tôi đã thiết kế lại trải nghiệm của bạn từ đầu! Hãy sẵn sàng với giao diện hiện đại, mượt mà và nhanh hơn, giúp mọi thao tác trở nên trực quan và dễ dàng hơn.';

  @override
  String get updateLater => 'Cập nhật sau';

  @override
  String get updateNow => 'Cập nhật ngay';

  @override
  String get listofTopics => 'Danh sách chủ đề';

  @override
  String get selectlevelandnumberofquestionsBottomsheetdata =>
      'Chọn cấp độ và số lượng câu hỏi';

  @override
  String get level => 'Cấp độ';

  @override
  String get numberOfquestions => 'Số lượng câu hỏi';

  @override
  String get cancel => 'Hủy';

  @override
  String get start => 'Bắt đầu';

  @override
  String get basicMath => 'Toán tư duy cơ bản';

  @override
  String get mathlogic => 'Toán logic';

  @override
  String get funGeometry => 'Hình học vui';

  @override
  String get advancedArithmetic => 'Số học nâng cao';

  @override
  String get specialChallenge => 'Thử thách đặc biệt';

  @override
  String get probabilityMath => 'Toán xác suất';

  @override
  String get visualLogicMath => 'Toán logic hình ảnh';

  @override
  String get timeMath => 'Toán thời gian';

  @override
  String get sequenceMath => 'Toán dãy số';

  @override
  String get deductiveLogicMath => 'Toán logic suy luận';

  @override
  String get divisionMath => 'Toán phép chia';

  @override
  String get comprehensiveArithmetic => 'Toán số học tổng hợp';

  @override
  String get fractionMath => 'Toán phân số';

  @override
  String get primeNumberMath => 'Toán số nguyên tố';

  @override
  String get perfectNumberMath => 'Toán số hoàn hảo';

  @override
  String get fibonacciMath => 'Toán dãy Fibonacci';

  @override
  String get palindromeNumberMath => 'Toán số đối xứng';

  @override
  String get oddEvenNumberMath => 'Toán số lẻ/chẵn';

  @override
  String get powerAndRootMath => 'Toán số mũ và căn bậc hai';

  @override
  String get moduloMath => 'Toán số học modulo';

  @override
  String get chooseThecorrectsign => 'Chọn dấu đúng';

  @override
  String get fillInthemissingnumber => 'Điền số còn thiếu';

  @override
  String maximumnumber(String numbers) {
    return 'Số lớn nhất trong các số: $numbers là?';
  }

  @override
  String get isItevenorodd => 'Số này là chẵn hay lẻ?';

  @override
  String get even => 'Chẵn';

  @override
  String get odd => 'Lẻ';

  @override
  String ifExpressionresultthenwhatisunknown(
    String expression,
    String result,
    String unknown,
  ) {
    return 'Nếu $expression = $result, thì $unknown là gì?';
  }

  @override
  String whatShapehassides(String sides) {
    return 'Hình nào có $sides cạnh?';
  }

  @override
  String get whatIsthemeasureofarightangle =>
      'Số đo của một góc vuông là bao nhiêu?';

  @override
  String theCircumferenceofacirclewithradiusisrounded(String radius) {
    return 'Chu vi của hình tròn bán kính $radius (làm tròn đến số nguyên gần nhất) là bao nhiêu?';
  }

  @override
  String get round => 'Làm tròn';

  @override
  String findXAddition(String a, String sum) {
    return 'Tìm x: x + $a = $sum';
  }

  @override
  String findXSubtraction(String a, String b) {
    return 'Tìm x: x - $a = $b';
  }

  @override
  String findXMultiplication(String a, String b) {
    return 'Tìm x: x x $a = $b';
  }

  @override
  String probabilityMarble(String total, String pick) {
    return 'Có $total viên bi, lấy ngẫu nhiên $pick viên. Xác suất lấy được viên đầu tiên là bao nhiêu?';
  }

  @override
  String probabilityCard(String total, String pick) {
    return 'Có $total lá bài, rút $pick lá. Xác suất rút được lá đầu là bao nhiêu?';
  }

  @override
  String probabilityStudent(String total, String pick) {
    return 'Có $total học sinh, chọn $pick bạn đi thi. Có bao nhiêu cách chọn?';
  }

  @override
  String shapesTotal(String a, String b) {
    return 'Có $a hình tròn và $b hình vuông. Tổng số hình là?';
  }

  @override
  String shapesRemove(String a, String b) {
    return 'Có $a hình tam giác, $b hình vuông. Nếu bỏ đi $a hình tam giác, còn lại bao nhiêu hình?';
  }

  @override
  String shapesTotal3(String a, String b, String c) {
    return 'Có $a hình tròn, $b hình vuông, $c hình tam giác. Tổng số hình là?';
  }

  @override
  String nowIsHour(String h) {
    return 'Bây giờ là $h giờ. Sau 2 giờ là mấy giờ?';
  }

  @override
  String nowIsHourMinute(String h, String m) {
    return 'Bây giờ là $h giờ $m phút. Sau 45 phút là mấy giờ mấy phút?';
  }

  @override
  String nowIsHourMinuteAdd(String h, String m, String add) {
    return 'Bây giờ là $h giờ $m phút. Sau $add phút là mấy giờ mấy phút?';
  }

  @override
  String todayIsDay(String a) {
    return 'Nếu hôm nay là thứ $a, ngày mai là thứ mấy?';
  }

  @override
  String todayIsDayInDays(String a, String days) {
    return 'Nếu hôm nay là thứ $a, $days ngày nữa là thứ mấy?';
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
    return 'Tính: $a/$b + $c/$d = ?';
  }

  @override
  String fractionSubtraction(String a, String b, String c, String d) {
    return 'Tính: $a/$b - $c/$d = ?';
  }

  @override
  String fractionMultiplication(String a, String b, String c, String d) {
    return 'Tính: ($a/$b) x ($c/$d) = ?';
  }

  @override
  String isPrime(String n) {
    return 'Số $n có phải là số nguyên tố không?';
  }

  @override
  String nextPrime(String n) {
    return 'Số nguyên tố tiếp theo sau $n là số nào?';
  }

  @override
  String countPrimes(String n) {
    return 'Có bao nhiêu số nguyên tố nhỏ hơn $n?';
  }

  @override
  String isPerfect(String n) {
    return 'Số $n có phải là số hoàn hảo không?';
  }

  @override
  String nextPerfect(String n) {
    return 'Số hoàn hảo nhỏ nhất lớn hơn $n là số nào?';
  }

  @override
  String countPerfects(String n) {
    return 'Có bao nhiêu số hoàn hảo nhỏ hơn $n?';
  }

  @override
  String fibonacci(String n) {
    return 'Số Fibonacci thứ $n là?';
  }

  @override
  String isPalindrome(String n) {
    return 'Số $n có phải là số đối xứng không?';
  }

  @override
  String evenOdd(String n) {
    return 'Số $n là số chẵn hay lẻ?';
  }

  @override
  String power(String a, String b) {
    return '$a mũ $b bằng bao nhiêu?';
  }

  @override
  String square(String a) {
    return 'Bình phương của $a là?';
  }

  @override
  String sqrt(String a) {
    return 'Căn bậc hai của $a (làm tròn):';
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
    return 'Diện tích hình vuông cạnh $a là?';
  }

  @override
  String rectangleArea(String a, String b) {
    return 'Diện tích hình chữ nhật $a x $b là?';
  }

  @override
  String triangleArea(String a, String h) {
    return 'Diện tích tam giác đáy $a, chiều cao $h là?';
  }

  @override
  String get shapeWithAllEqualSidesAndRightAngles =>
      'Hình nào có tất cả các cạnh bằng nhau và 4 góc vuông?';

  @override
  String get shapeWith6Sides => 'Hình nào có 6 cạnh?';

  @override
  String totalAnglesOfShape(String sides) {
    return 'Một hình có $sides cạnh thì tổng số góc là?';
  }

  @override
  String exteriorAngleRegularPolygon(String s) {
    return 'Góc ngoài của đa giác đều $s cạnh là bao nhiêu?';
  }

  @override
  String rectanglePerimeter(String a, String b) {
    return 'Chu vi hình chữ nhật có cạnh $a và $b là bao nhiêu?';
  }

  @override
  String get yes => 'Đúng';

  @override
  String get no => 'Sai';

  @override
  String get notFound => 'Không tìm thấy';

  @override
  String get correct => 'Chính xác!';

  @override
  String get incorrect => 'Chưa đúng, thử lại nhé!';

  @override
  String get nextNumberintheSeries => 'Số tiếp theo trong dãy số là';

  @override
  String get save => 'Lưu';

  @override
  String get maximumNumberamongC => 'Số lớn nhất';

  @override
  String get evenOddC => 'chẵn hay lẻ';

  @override
  String get enterAnswer => 'Nhập đáp án';

  @override
  String get next => 'Tiếp theo';

  @override
  String get question => 'Câu';

  @override
  String get discription => 'Mô tả';

  @override
  String get discriptionSusgget =>
      'Sử dụng gợi ý sẽ tốn 1 xu hoặc yêu cầu xem quảng cáo, với xu được sử dụng trước.';

  @override
  String get agree => 'Đồng ý';

  @override
  String get result => 'Kết quả';

  @override
  String get congratulations => 'Chúc mừng!';

  @override
  String get congratulationsDescription =>
      'Bạn đã hoàn thành tất cả câu hỏi trong chủ đề này. Hãy tiếp tục khám phá các chủ đề khác nhé!';

  @override
  String get dongiveup => 'Đừng bỏ cuộc!';

  @override
  String get viewDetail => 'Xem chi tiết';

  @override
  String get gotoHomepage => 'Về trang chủ';

  @override
  String get keepPracticing => 'Tiếp tục luyện tập';

  @override
  String get totalQuestions => 'Tổng số câu hỏi';

  @override
  String get settings => 'Cài đặt';

  @override
  String get settingInfoTitle => 'Cài đặt & Thông tin';

  @override
  String get sectionGeneral => 'CÀI ĐẶT CHUNG';

  @override
  String get sectionStoreInteraction => 'CỬA HÀNG & TƯƠNG TÁC';

  @override
  String get sectionLegalSupport => 'PHÁP LÝ & HỖ TRỢ';

  @override
  String get systemSettings => 'Cài đặt hệ thống';

  @override
  String get systemSettingsDescription => 'Âm thanh, thông báo & hiển thị';

  @override
  String get appInformation => 'Thông tin ứng dụng';

  @override
  String get appInformationDescription => 'Nhà phát triển & phiên bản';

  @override
  String get home_nav_home => 'Trang chủ';

  @override
  String get home_nav_summary => 'Tổng Kết';

  @override
  String get recentUsage => 'Hoạt động gần đây';

  @override
  String get noRecentUsageLogs => 'Không có nhật ký sử dụng gần đây';

  @override
  String get home_nav_store => 'Cửa hàng';

  @override
  String get home_nav_settings => 'Cài Đặt';

  @override
  String get appInfo => 'Thông tin ứng dụng';

  @override
  String get version => 'Phiên bản';

  @override
  String get appName => 'Tên ứng dụng';

  @override
  String get shareAndSupport => 'Chia sẻ & Hỗ trợ';

  @override
  String get shareApp => 'Chia sẻ ứng dụng';

  @override
  String get shareAppDescription => 'Chia sẻ ứng dụng này với bạn bè';

  @override
  String get rateApp => 'Đánh giá ứng dụng';

  @override
  String get rateAppDescription => 'Đánh giá chúng tôi trên App Store';

  @override
  String get feedback => 'Phản hồi';

  @override
  String get feedbackDescription => 'Gửi phản hồi cho chúng tôi';

  @override
  String get legal => 'Pháp lý';

  @override
  String get privacyPolicy => 'Chính sách bảo mật';

  @override
  String get privacyPolicyDescription => 'Đọc chính sách bảo mật của chúng tôi';

  @override
  String get termsOfService => 'Điều khoản dịch vụ';

  @override
  String get termsOfServiceDescription =>
      'Đọc điều khoản dịch vụ của chúng tôi';

  @override
  String get about => 'Thông tin';

  @override
  String get help => 'Trợ giúp';

  @override
  String get helpDescription => 'Nhận trợ giúp và hỗ trợ';

  @override
  String get contactUs => 'Liên hệ chúng tôi';

  @override
  String get contactUsDescription => 'Liên lạc với chúng tôi';

  @override
  String get developer => 'Nhà phát triển';

  @override
  String get website => 'Trang web';

  @override
  String get supportContact => 'Liên hệ hỗ trợ';

  @override
  String get openSourceLicenses => 'Giấy phép nguồn mở';

  @override
  String copyrightNotice(Object year) {
    return '© $year Trường Lâm.\nBảo lưu mọi quyền.';
  }

  @override
  String get buyCoins => 'Mua xu';

  @override
  String get buyCoinsDescription => 'Mua xu để mở khóa gợi ý và tính năng';

  @override
  String get askParentsBeforePurchase =>
      'Nhớ hỏi ý kiến cha mẹ trước khi mua nhé!';

  @override
  String get starsUnit => 'Ngôi Sao';

  @override
  String get termsOfConditions => 'Điều khoản và điều kiện';

  @override
  String get time => 'Thời gian';

  @override
  String get hour => 'giờ';

  @override
  String get minute => 'phút';

  @override
  String get purchaseCoins => 'Mua xu';

  @override
  String get purchaseCoinsDescription =>
      'Nhận thêm xu để sử dụng gợi ý và mở khóa tính năng';

  @override
  String get coinShop => 'Cửa hàng xu';

  @override
  String findFirstAddend(String sum, String secondAddend) {
    return 'Nếu tổng là $sum và số hạng thứ hai là $secondAddend, số hạng thứ nhất là bao nhiêu?';
  }

  @override
  String findSecondAddend(String firstAddend, String sum) {
    return 'Nếu số hạng thứ nhất là $firstAddend và tổng là $sum, số hạng thứ hai là bao nhiêu?';
  }

  @override
  String findMinuend(String difference, String subtrahend) {
    return 'Nếu hiệu là $difference và số trừ là $subtrahend, số bị trừ là bao nhiêu?';
  }

  @override
  String findSubtrahend(String minuend, String difference) {
    return 'Nếu số bị trừ là $minuend và hiệu là $difference, số trừ là bao nhiêu?';
  }

  @override
  String findMultiplicand(String product, String multiplier) {
    return 'Nếu tích là $product và thừa số thứ hai là $multiplier, thừa số thứ nhất là bao nhiêu?';
  }

  @override
  String findMultiplier(String multiplicand, String product) {
    return 'Nếu thừa số thứ nhất là $multiplicand và tích là $product, thừa số thứ hai là bao nhiêu?';
  }

  @override
  String findDividend(String quotient, String divisor) {
    return 'Nếu thương là $quotient và số chia là $divisor, số bị chia là bao nhiêu?';
  }

  @override
  String findDivisor(String dividend, String quotient) {
    return 'Nếu số bị chia là $dividend và thương là $quotient, số chia là bao nhiêu?';
  }

  @override
  String get checkIndailytoreceive30coins =>
      'Điểm danh hàng ngày để nhận 2 đồng';

  @override
  String get checkIn => 'Điểm danh';

  @override
  String get rollCall => 'Điểm danh';

  @override
  String get models => 'Mô hình';

  @override
  String get model => 'Mô hình';

  @override
  String get selectAIModel => 'Chọn mô hình AI';

  @override
  String get filters => 'Bộ lọc';

  @override
  String get features => 'Tính năng';

  @override
  String get multimodal => 'Đa phương thức';

  @override
  String get functionCalls => 'Gọi hàm';

  @override
  String get thinking => 'Suy nghĩ';

  @override
  String get clearFilters => 'Xóa bộ lọc';

  @override
  String get sort => 'Sắp xếp';

  @override
  String get showing => 'Hiển thị';

  @override
  String get function => 'Hàm';

  @override
  String get chat => 'Trò chuyện';

  @override
  String get aiModelManager => 'Quản lý mô hình AI';

  @override
  String get downloadedModels => 'Mô hình đã tải';

  @override
  String get availableModels => 'Mô hình khả dụng';

  @override
  String get manageModels => 'Quản lý mô hình';

  @override
  String get modelManagement => 'Quản lý mô hình';

  @override
  String get downloadStatus => 'Trạng thái tải xuống';

  @override
  String get storageUsed => 'Bộ nhớ đã sử dụng';

  @override
  String get totalStorage => 'Tổng bộ nhớ';

  @override
  String get deleteModel => 'Xóa mô hình';

  @override
  String get confirmDeleteModel => 'Bạn có chắc muốn xóa mô hình này không?';

  @override
  String get modelDeleted => 'Đã xóa mô hình thành công';

  @override
  String get noModelsDownloaded => 'Chưa có mô hình nào được tải xuống';

  @override
  String get refreshModels => 'Làm mới mô hình';

  @override
  String get modelDetails => 'Chi tiết mô hình';

  @override
  String get modelSize => 'Kích thước mô hình';

  @override
  String get downloadDate => 'Ngày tải xuống';

  @override
  String get lastUsed => 'Lần sử dụng cuối';

  @override
  String get viewAll => 'Xem tất cả';

  @override
  String get backendType => 'Loại backend';

  @override
  String get cpuBackend => 'CPU Backend';

  @override
  String get gpuBackend => 'GPU Backend';

  @override
  String get modelStatus => 'Trạng thái mô hình';

  @override
  String get ready => 'Sẵn sàng';

  @override
  String get downloading => 'Đang tải xuống';

  @override
  String get failed => 'Thất bại';

  @override
  String get notDownloaded => 'Chưa tải xuống';

  @override
  String get aiChat => 'Chat AI';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get aiStatus => 'AI Status';

  @override
  String get thinkingStatus => 'Đang suy nghĩ...';

  @override
  String get readyToChat => 'Sẵn sàng';

  @override
  String get startConversation => 'Bắt đầu cuộc trò chuyện';

  @override
  String get askMeAnything =>
      'Hỏi tôi bất cứ điều gì về toán học!\nTôi có thể giúp bạn giải bài tập, giải thích khái niệm...';

  @override
  String get syncMode => 'Sync';

  @override
  String get typeMessage => 'Nhập tin nhắn của bạn...';

  @override
  String get addImage => 'Thêm hình ảnh';

  @override
  String get changeImage => 'Đổi hình ảnh';

  @override
  String get removeImage => 'Xóa hình ảnh';

  @override
  String get sendMessage => 'Gửi tin nhắn';

  @override
  String get addImageDescription => 'Thêm mô tả cho hình ảnh...';

  @override
  String get selectImageSource => '📷 Chọn nguồn hình ảnh';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Thư viện';

  @override
  String get takeNewPhoto => 'Chụp ảnh mới';

  @override
  String get selectFromGallery => 'Chọn từ thư viện';

  @override
  String get image => 'Hình ảnh';

  @override
  String get aiProcessing => 'AI đang xử lý...';

  @override
  String get composingMessage => 'Đang soạn tin nhắn';

  @override
  String get imageNotSupportedOnWeb =>
      'Tính năng chọn ảnh chưa hỗ trợ trên web';

  @override
  String get imageAddedSuccessfully => 'Đã thêm hình ảnh thành công';

  @override
  String get errorSelectingImage => 'Lỗi khi chọn ảnh';

  @override
  String get copiedToClipboard => 'Đã copy vào clipboard';

  @override
  String get copy => 'Copy';

  @override
  String get initializingModel => '🤖 Đang khởi tạo AI model...';

  @override
  String get modelInitialized => 'Model đã sẵn sàng';

  @override
  String get chatHistory => 'Lịch sử chat';

  @override
  String get newChat => 'Chat mới';

  @override
  String get continueChat => 'Tiếp tục chat';

  @override
  String get imageSupported => 'Hỗ trợ hình ảnh';

  @override
  String get multimodalSupport => 'Hỗ trợ đa phương thức';

  @override
  String get enterYourQuestion => 'Nhập câu hỏi của bạn...';

  @override
  String get aiThinking => '🤖 AI đang suy nghĩ...';

  @override
  String get retry => 'Thử lại';

  @override
  String get errorOccurred => 'Đã xảy ra lỗi';

  @override
  String get networkError => 'Lỗi mạng, vui lòng thử lại';

  @override
  String get modelError => 'Lỗi model AI';

  @override
  String get processingImage => 'Đang xử lý hình ảnh...';

  @override
  String get imageProcessed => 'Đã xử lý hình ảnh';

  @override
  String get stopGeneration => 'Dừng tạo';

  @override
  String get generatingResponse => 'Đang tạo phản hồi...';

  @override
  String get responseGenerated => 'Đã tạo phản hồi';

  @override
  String get coinInfo => 'Thông tin Coin';

  @override
  String get costPerChat => 'Chi phí mỗi lần chat';

  @override
  String get fiveCoins => '5 Coins';

  @override
  String get note => 'Lưu ý';

  @override
  String get coinUsageNote =>
      '• Mỗi tin nhắn gửi đi sẽ tiêu tốn 5 coins\n• Coin sẽ được trừ khi bạn nhấn gửi tin nhắn\n• Hãy đảm bảo có đủ coin trước khi chat';

  @override
  String get understood => 'Đã hiểu';

  @override
  String get coinInfoTooltip => 'Thông tin về coin';

  @override
  String get webNotSupported => 'Tính năng chọn ảnh chưa hỗ trợ trên web';

  @override
  String get imageAddedSuccess => 'Đã thêm hình ảnh thành công';

  @override
  String get imageSelectionError => 'Lỗi khi chọn ảnh';

  @override
  String get enterDiscriptionexplainImage => 'Thêm mô tả cho hình ảnh';

  @override
  String get entarYourMessage => 'Nhập tin nhắn của bạn';

  @override
  String get insufficientCoins => 'Không đủ Coin';

  @override
  String get notEnoughCoins => 'Bạn không đủ coin';

  @override
  String get needCoinsToSend => 'Cần ít nhất 5 coins để gửi tin nhắn';

  @override
  String get information => 'Thông tin';

  @override
  String get rechargeCoinsMessage =>
      'Vui lòng nạp thêm coin để tiếp tục sử dụng dịch vụ chat AI. Bạn có thể mua coin trong cửa hàng.';

  @override
  String get close => 'Đóng';

  @override
  String get rechargeCoins => 'Nạp Coin';

  @override
  String get addition => 'Phép cộng';

  @override
  String get subtraction => 'Phép trừ';

  @override
  String get think => 'Suy nghĩ';

  @override
  String get reflex => 'Phản xạ';

  @override
  String get game => 'Trò chơi';

  @override
  String get home_daily_reward_subtitle => 'Nhận ngay 10 ⭐';

  @override
  String get home_featured_basic_subtitle => 'Làm quen với số và phép tính';

  @override
  String get home_card_reflex_title => 'Toán Phản Xạ';

  @override
  String get home_card_reflex_subtitle => 'Nhanh tay lẹ mắt';

  @override
  String get home_card_think_title => 'Toán Tư Duy';

  @override
  String get home_card_think_subtitle => 'Rèn luyện logic';

  @override
  String get home_card_ai_title => 'Trò chuyện AI';

  @override
  String get home_card_ai_subtitle => 'Hỏi đáp vui vẻ';

  @override
  String get home_card_ai_button => 'trò chuyện';

  @override
  String get home_card_game_title => 'Game Giải Trí';

  @override
  String get home_card_game_subtitle => 'Vừa chơi vừa học';

  @override
  String get small_card_play => 'Chơi';

  @override
  String get startNow => 'Bắt đầu thôi';

  @override
  String get challengeTitle => 'Thử thách Toán học';

  @override
  String get readyTitle => 'Sẵn sàng chưa?';

  @override
  String get readySubtitle => 'Hãy chọn thử thách phù hợp với bạn!';

  @override
  String get adventurePathTitle => 'Đường phiêu lưu Toán học';

  @override
  String get chooseQuestionCount => 'Chọn số lượng câu hỏi';

  @override
  String get difficultyEasy => 'Dễ';

  @override
  String get difficultyMedium => 'Trung bình';

  @override
  String get difficultyHard => 'Khó';

  @override
  String get difficultyEasyDesc => 'Bắt đầu cuộc phiêu lưu của bạn!';

  @override
  String get difficultyMediumDesc => 'Khám phá vùng đất mới!';

  @override
  String get difficultyHardDesc => 'Chinh phục đỉnh cao!';

  @override
  String get startChallengeSnackbar => 'Bắt đầu thử thách';

  @override
  String get topic_list_title => 'Toán Cơ Bản';

  @override
  String get topic_start_button => 'Bắt đầu chủ đề';

  @override
  String get topic_addition_title => 'Phép Cộng';

  @override
  String get topic_addition_subtitle =>
      'Làm quen với việc thêm các con số và xây dựng nền tảng vững chắc.';

  @override
  String get topic_subtraction_title => 'Phép Trừ';

  @override
  String get topic_subtraction_subtitle =>
      'Học cách bớt đi từ một tổng thể, hiểu khái niệm còn lại.';

  @override
  String get topic_mixed_title => 'Toán Cơ Bản Tổng Hợp';

  @override
  String get topic_mixed_subtitle =>
      'Thực hành hỗn hợp cộng và trừ, nâng cao kỹ năng tính toán.';

  @override
  String get topic_mul_div_title => 'Nhân & Chia';

  @override
  String get topic_mul_div_subtitle =>
      'Phép tính cơ bản nâng cao: học cách nhân và chia.';

  @override
  String get topic_division_title => 'Phép Chia';

  @override
  String get topic_division_subtitle =>
      'Chia đều các phần bằng nhau, phát triển tư duy logic.';

  @override
  String get topic_review_title => 'Ôn Tập Tổng Hợp';

  @override
  String get topic_review_subtitle =>
      'Kết hợp cả 4 phép tính cơ bản để luyện tập tổng thể.';

  @override
  String get topic_fraction_title => 'Phân Số & Thập Phân';

  @override
  String get topic_fraction_subtitle =>
      'Hiểu về một phần của tổng thể và chuyển đổi giữa phân số và thập phân.';

  @override
  String get topic_even_odd_title => 'Số Chẵn & Lẻ';

  @override
  String get topic_even_odd_subtitle =>
      'Phân loại các con số và nhận biết tính chẵn lẻ.';

  @override
  String get topic_prime_title => 'Số Nguyên Tố';

  @override
  String get topic_prime_subtitle =>
      'Khám phá những con số đặc biệt; học về ước số và bội số.';

  @override
  String get topic_power_root_title => 'Lũy Thừa & Căn';

  @override
  String get topic_power_root_subtitle =>
      'Khám phá số mũ và căn cho các phép toán nâng cao.';

  @override
  String get topic_modulo_title => 'Phép Chia Dư';

  @override
  String get topic_modulo_subtitle =>
      'Toán modulo vui — hiểu về phần dư của phép chia.';

  @override
  String get topic_algebra_subtitle =>
      'Nhận diện, so sánh hình ảnh — nhanh mắt, luyện phản xạ thị giác.';

  @override
  String get topic_geometry_subtitle =>
      'Phân số/nhanh đọc — luyện phản xạ thị giác và đọc nhanh.';

  @override
  String get topic_calculus_subtitle =>
      'Câu hỏi về giờ/phút — kiểm tra phản xạ nhanh tay.';

  @override
  String get topic_advanced_probability_subtitle =>
      'Dãy số — nhận dạng mẫu nhanh, thử thách phản xạ ngắn.';

  @override
  String get mathlogic_subtitle =>
      'Các câu đố và bài toán suy luận giúp củng cố tư duy logic.';

  @override
  String get topic_deductive_subtitle =>
      'Luyện tư duy suy luận theo bước qua các bài toán logic.';

  @override
  String get visualLogicMath2 => 'Toán logic hình ảnh 2';

  @override
  String get topic_special_challenge_subtitle =>
      'Những câu hỏi khó được tuyển chọn để thử thách giới hạn của bạn — sẵn sàng chưa?';

  @override
  String get practice_challenge => 'Thử thách';

  @override
  String get practice_level => 'Cấp độ';

  @override
  String get practice_score => 'Điểm';

  @override
  String get practice_combo => 'Chuỗi';

  @override
  String get practice_skip_question => 'Bỏ qua câu hỏi này';

  @override
  String practice_question_index(int current, int total) {
    return 'Câu $current/$total';
  }

  @override
  String practice_time_seconds(String seconds) {
    return '${seconds}s';
  }

  @override
  String practice_points_plus(String points) {
    return '+$points điểm';
  }

  @override
  String versionandbuild(String version, String build) {
    return 'Phiên bản $version (Bản dựng $build)';
  }

  @override
  String get progress_by_topic => 'Tiến độ theo chủ đề';

  @override
  String get activity_week => 'Hoạt động tuần qua';

  @override
  String get last_7_days => '7 ngày gần nhất';

  @override
  String get hello => 'Xin chào';

  @override
  String get baby => 'Bé cưng';

  @override
  String get gamesHeaderTitle => 'Góc Vui Chơi';

  @override
  String get gamesTitleMain => 'Giờ giải trí đến rồi!';

  @override
  String get gamesTitleSubtitle => 'Bé muốn chơi trò gì nào?';

  @override
  String get featuredNew => 'MỚI NHẤT';

  @override
  String get featuredWeekChallengeTitle => 'Thử thách tuần này';

  @override
  String get featuredWeekChallengeSub => 'Sưu tập ngôi sao may mắn!';

  @override
  String get gamePikachuTitle => 'Nối Hình';

  @override
  String get gamePikachuSubtitle => 'Rèn luyện trí nhớ';

  @override
  String get gameTetrisTitle => 'Xếp Gạch';

  @override
  String get gameTetrisSubtitle => 'Xếp hình vui nhộn';

  @override
  String get exit => 'Thoát';

  @override
  String get playAgain => 'Chơi lại';

  @override
  String get gameOver => 'Trò chơi kết thúc';

  @override
  String scoreMessage(Object score) {
    return 'Điểm số: $score';
  }

  @override
  String get gamePacmanTitle => 'Pac-men';

  @override
  String get gamePacmanSubtitle => 'Ăn điểm mê cung';

  @override
  String get game2048Title => '2048';

  @override
  String get game2048Subtitle => 'Ghép số thông minh';

  @override
  String get gameWordTitle => 'Đoán Chữ';

  @override
  String get gameWordSubtitle => 'Học từ vựng tiếng Anh & Việt qua hình ảnh';

  @override
  String get gameDuckTitle => 'Vịt Trời';

  @override
  String get gameDuckSubtitle => 'Bắn vịt vui nhộn';

  @override
  String get latest => 'MỚI NHẤT';

  @override
  String get rectangle => 'Chữ Nhật';

  @override
  String get triangle => 'Tam Giác';

  @override
  String get circle => 'Hình Tròn';

  @override
  String get either => 'Cả Hai';

  @override
  String get hint => 'Gợi Ý';

  @override
  String get hintDescription =>
      'Dùng 1 star để nhận gợi ý để giúp bạn trả lời câu hỏi này.';

  @override
  String get useCoins => 'Dùng stars';

  @override
  String useCoinDescription(String coins) {
    return 'Dùng $coins stars để nhận gợi ý cho câu hỏi này.';
  }

  @override
  String get coinUnit => 'stars';

  @override
  String get or => 'hoặc';

  @override
  String get watchAd => 'Xem Quảng Cáo';

  @override
  String get watchAdDescription =>
      'Xem quảng cáo để nhận gợi ý miễn phí cho câu hỏi này.';

  @override
  String get free => 'Miễn Phí';

  @override
  String get addCoinsToTreasury => 'Thêm stars vào kho';

  @override
  String get get => 'Nhận';

  @override
  String get ads_not_ready_please_try_again_later =>
      'Quảng cáo chưa sẵn sàng, vui lòng thử lại sau.';

  @override
  String get gamePackPalTitle => 'Pack Pal';

  @override
  String get gamePackPalSubtitle => 'Giúp các bạn trong đàn tìm đường về nhà!';

  @override
  String get gameCircuitTitle => 'Kết Nối Mạch';

  @override
  String get gameCircuitSubtitle => 'Kết nối các mạch để hoàn thành đường đi!';

  @override
  String get gameQuantumTitle => 'Liên Kết Lượng Tử';

  @override
  String get gameQuantumSubtitle =>
      'Giải các câu đố lượng tử và liên kết các hạt!';

  @override
  String get game2048Header => 'Trò chơi 2048';

  @override
  String get scoreCardLabel => 'ĐIỂM SỐ';

  @override
  String get bestCardLabel => 'KỶ LỤC';

  @override
  String get aiHintBubble => 'Bé ơi, thử kết hợp hai số 4 nhé! Cố lên!';

  @override
  String get reset => 'Làm lại';

  @override
  String get aiHint => 'Gợi ý AI';

  @override
  String get featureLockedMessage => 'Tính năng sắp mở khóa!';

  @override
  String get undo => 'Hoàn tác';
}
