import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart'; // + for PlatformException
import 'package:shared_preferences/shared_preferences.dart';

// Top-level background callback required by flutter_local_notifications.
// Must be a static or top-level function and marked as a VM entry point.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse details) {
  // Do minimal work here (no UI). Initialize services if needed.
  debugPrint(
    'Background Notification Tapped: ${details.payload} '
    '(id=${details.id}, actionId=${details.actionId})',
  );
}

class LocalNotificationService {
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _timezoneConfigured = false;

  // Android notification channel (must exist before scheduling)
  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
        'default_reminder_channel', // id
        'Reminders', // name
        description: 'Reminder notifications',
        importance: Importance.high,
        playSound: true,
      );

  Future<void> initialize() async {
    // Initialization settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialization settings for iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    // Initialization settings for both platforms
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        pecessNotificationPayload(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Create Android channel
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_defaultChannel);

    await _configureLocalTimeZone();

    handleAppLaunchFromNotification();
  }

  void handleAppLaunchFromNotification() async {
    _flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails().then((
      value,
    ) async {
      if (value?.didNotificationLaunchApp ?? false) {
        final payload = value?.notificationResponse?.payload;
        pecessNotificationPayload(payload);
      }
    });
  }

  void pecessNotificationPayload(String? payload) async {
    final data = jsonDecode(payload ?? '{}');
  }

  Future<void> _configureLocalTimeZone() async {
    if (_timezoneConfigured) return;
    if (kIsWeb || Platform.isLinux || Platform.isWindows) return;
    tz.initializeTimeZones();
    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    _timezoneConfigured = true;
  }

  Future<bool> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return true;
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      final bool? grantedNotificationPermission = await androidImplementation
          ?.requestNotificationsPermission();
      return grantedNotificationPermission ?? false;
    }
    return false;
  }

  // Ensure the scheduled time is strictly in the future
  tz.TZDateTime _nextValidTime(
    tz.TZDateTime t, {
    Duration buffer = const Duration(seconds: 3),
  }) {
    final now = tz.TZDateTime.now(tz.local);
    final min = now.add(buffer);
    return t.isAfter(min) ? t : min;
  }

  Future<void> zonedScheduleNotification({
    required String title,
    required String body,
    required Duration scheduledDuration,
    String? payload,
    int? id,
  }) async {
    await _configureLocalTimeZone();

    // Guard against past or immediate times
    final safeDuration = scheduledDuration.isNegative
        ? const Duration(seconds: 3)
        : scheduledDuration;

    final androidDetails = AndroidNotificationDetails(
      _defaultChannel.id,
      _defaultChannel.name,
      channelDescription: _defaultChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      ticker: 'Reminder',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final rawScheduleTime = tz.TZDateTime.now(tz.local).add(safeDuration);
    final scheduleTime = _nextValidTime(rawScheduleTime);

    final notificationId =
        id ?? DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);

    // Try exact first, then fall back to inexact if not permitted
    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        scheduleTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
        matchDateTimeComponents: null,
      );
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permitted') {
        debugPrint('Exact alarms not permitted. Falling back to inexact.');
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          title,
          body,
          scheduleTime,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: payload,
          matchDateTimeComponents: null,
        );
      } else {
        rethrow;
      }
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // --- Persistent scheduling helpers -------------------------------------
  static const String _kScheduledDateKey = 'scheduled_notification_date';

  String _formatDateKey(tz.TZDateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  }

  Future<bool> _hasScheduledForDateKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kScheduledDateKey);
    return stored == key;
  }

  Future<void> _markScheduledForDateKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kScheduledDateKey, key);
  }

  /// Public entry: call this on app start (or when app becomes active).
  ///
  /// Behavior:
  /// - Determines next day's date in local timezone.
  /// - If we've already scheduled for that date (persisted in SharedPreferences), do nothing.
  /// - Otherwise schedule a local notification at 07:00 local time on the next day
  ///   and persist the scheduled date so it won't be scheduled twice.
  Future<void> scheduleDailyReminderIfNeeded() async {
    await _configureLocalTimeZone();

    if (await Permission.notification.status != PermissionStatus.granted) {
      return;
    }

    final now = tz.TZDateTime.now(tz.local);

    // Target is always next day at 07:00 local time.
    final nextDay = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    final scheduledTime = tz.TZDateTime(
      tz.local,
      nextDay.year,
      nextDay.month,
      nextDay.day,
      7,
      0,
      0,
    );

    final key = _formatDateKey(scheduledTime);

    // If already scheduled for that date, do nothing.
    if (await _hasScheduledForDateKey(key)) return;

    // Ensure scheduled time is in the future (should be, since it's next day)
    final duration = scheduledTime.difference(now);

    // Schedule the notification. Use a stable id (so there is at most one
    // reminder notification scheduled by this logic). If you prefer multiple
    // distinct notifications, generate unique IDs instead.
    const reminderId = 200001;

    final notifications = [
      {
        "key": "notif_01",
        "vi": {
          "title": "Bắt đầu học thôi!",
          "subtitle": "Chỉ 5 phút hôm nay cũng giúp bạn tiến bộ hơn.",
        },
        "en": {
          "title": "Let’s start learning!",
          "subtitle": "Just 5 minutes today can make you better.",
        },
      },
      {
        "key": "notif_02",
        "vi": {
          "title": "Đến giờ học rồi!",
          "subtitle": "Một bài ngắn để khởi động não bộ nhé.",
        },
        "en": {
          "title": "It’s study time!",
          "subtitle": "A short lesson to warm up your brain.",
        },
      },
      {
        "key": "notif_03",
        "vi": {
          "title": "Học chút nha 👋",
          "subtitle": "Kiến thức nhỏ hôm nay, khác biệt lớn ngày mai.",
        },
        "en": {
          "title": "Let’s learn a bit 👋",
          "subtitle": "Small knowledge today, big difference tomorrow.",
        },
      },
      {
        "key": "notif_04",
        "vi": {
          "title": "Cùng học nào!",
          "subtitle": "Mỗi ngày một chút, bạn sẽ giỏi lên rất nhanh.",
        },
        "en": {
          "title": "Let’s study together!",
          "subtitle": "A little every day makes you better fast.",
        },
      },
      {
        "key": "notif_05",
        "vi": {
          "title": "Đừng bỏ lỡ hôm nay!",
          "subtitle": "Giữ thói quen học mỗi ngày nhé 🔥",
        },
        "en": {
          "title": "Don’t miss today!",
          "subtitle": "Keep your daily learning streak 🔥",
        },
      },
      {
        "key": "notif_06",
        "vi": {
          "title": "Sáng rồi, học thôi! ☀️",
          "subtitle": "Bắt đầu ngày mới bằng một bài học nhỏ.",
        },
        "en": {
          "title": "Good morning, time to learn! ☀️",
          "subtitle": "Start your day with a small lesson.",
        },
      },
      {
        "key": "notif_07",
        "vi": {
          "title": "Nhiệm vụ hôm nay 🎯",
          "subtitle": "Hoàn thành bài học để giữ streak của bạn.",
        },
        "en": {
          "title": "Today’s mission 🎯",
          "subtitle": "Complete a lesson to keep your streak.",
        },
      },
      {
        "key": "notif_08",
        "vi": {
          "title": "Mở app học nhé 📚",
          "subtitle": "Chỉ vài phút thôi, không tốn nhiều thời gian đâu.",
        },
        "en": {
          "title": "Open the app and learn 📚",
          "subtitle": "Just a few minutes, it won’t take long.",
        },
      },
      {
        "key": "notif_09",
        "vi": {
          "title": "Hôm nay học gì?",
          "subtitle": "App đã chuẩn bị sẵn cho bạn rồi đó 😉",
        },
        "en": {
          "title": "What will you learn today?",
          "subtitle": "The app is ready for you 😉",
        },
      },
      {
        "key": "notif_10",
        "vi": {
          "title": "Tiến bộ mỗi ngày 🚀",
          "subtitle": "Học đều đặn là bí quyết để giỏi hơn.",
        },
        "en": {
          "title": "Improve every day 🚀",
          "subtitle": "Consistent learning is the key to success.",
        },
      },
    ];

    final randomNotification =
        (notifications..shuffle()).first; // Pick a random notification

    final languageCode = PlatformDispatcher.instance.locale.languageCode;
    final vi = randomNotification['vi'] as Map<String, dynamic>?;
    final en = randomNotification['en'] as Map<String, dynamic>?;

    final title = languageCode == 'vi'
        ? (vi?['title'] as String? ?? en?['title'] as String? ?? 'We miss you!')
        : (en?['title'] as String? ??
              vi?['title'] as String? ??
              'We miss you!');

    final body = languageCode == 'vi'
        ? (vi?['subtitle'] as String? ?? en?['subtitle'] as String? ?? '')
        : (en?['subtitle'] as String? ?? vi?['subtitle'] as String? ?? '');

    await zonedScheduleNotification(
      id: reminderId,
      title: title,
      body: body,
      scheduledDuration: duration,
      payload: jsonEncode({'type': 'daily_reminder', 'date': key}),
    );

    // Persist that we scheduled for this date so we won't reschedule it.
    await _markScheduledForDateKey(key);
  }
}
