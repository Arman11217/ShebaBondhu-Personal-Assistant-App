import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../home_service.dart';

/// Professional Production-Grade Notification Service.
/// Handles high-priority system notifications that trigger whether the app
/// is active (foreground), sleeping (background), or terminated (dead/killed).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  static const String channelRemindersId = 'sheba_bondhu_reminders';
  static const String channelRemindersName = 'জরুরি সেবা ও রিমাইন্ডার';
  static const String channelRemindersDesc =
      'বিল, দেনা-পাওনা, ওষুধ এবং টাস্কের রিমাইন্ডার নোটিফিকেশন';

  static const String channelDailyId = 'sheba_bondhu_daily';
  static const String channelDailyName = 'দৈনিক সকালের ব্রিফিং';
  static const String channelDailyDesc =
      'দিনের শুরুতেই সকল কাজের সারসংক্ষেপ ও আপডেট';

  // Preference keys
  static const String keyNotificationsEnabled = 'pref_notifications_enabled';
  static const String keyDailyBriefingEnabled = 'pref_daily_briefing_enabled';
  static const String keyAlert30mEnabled = 'pref_alert_30m_enabled';
  static const String keyAlert1hEnabled = 'pref_alert_1h_enabled';
  static const String keyAlertAtDueEnabled = 'pref_alert_at_due_enabled';

  /// Initialize notifications and configure system channels.
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize Timezones
      tz.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
      } catch (_) {
        tz.setLocalLocation(tz.local);
      }

      // 2. Android Initialization Settings
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // 3. iOS/Darwin Settings
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // 4. Create High-Priority Notification Channels in Android
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // Reminders Channel (Max importance, pop-up banner, vibration)
        const remindersChannel = AndroidNotificationChannel(
          channelRemindersId,
          channelRemindersName,
          description: channelRemindersDesc,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        );
        await androidPlugin.createNotificationChannel(remindersChannel);

        // Daily Briefing Channel
        const dailyChannel = AndroidNotificationChannel(
          channelDailyId,
          channelDailyName,
          description: channelDailyDesc,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        );
        await androidPlugin.createNotificationChannel(dailyChannel);
      }

      _isInitialized = true;
      debugPrint('✅ [NotificationService] Initialized successfully with timezone: ${tz.local.name}');
    } catch (e, stack) {
      debugPrint('⚠️ [NotificationService Init Error]: $e\n$stack');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 [Notification Tapped] Payload: ${response.payload}');
  }

  /// Request runtime notification permission (Android 13+ and iOS)
  Future<bool> requestPermission() async {
    try {
      // Try Flutter Local Notifications Android plugin
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        if (granted == true) return true;
      }

      // Try permission_handler as fallback
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('⚠️ [Permission Request Error]: $e');
      return false;
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final userToggle = prefs.getBool(keyNotificationsEnabled) ?? true;
    if (!userToggle) return false;

    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Send an instant notification to the notification tray
  Future<void> showInstantNotification({
    int? id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await init();
    final notifyId = id ?? Random().nextInt(1000000);

    const androidDetails = AndroidNotificationDetails(
      channelRemindersId,
      channelRemindersName,
      channelDescription: channelRemindersDesc,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF0F766E),
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(notifyId, title, body, notificationDetails,
        payload: payload);
    debugPrint('📢 [Instant Notification Sent] ID: $notifyId - $title');
  }

  /// Schedules a notification for an exact future date & time.
  /// Works reliably even when the device is asleep or app is dead.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await init();

    // Do not schedule past times
    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint('⏩ [Schedule Skipped] Date is in the past: $scheduledDate');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final isGloballyEnabled = prefs.getBool(keyNotificationsEnabled) ?? true;
    if (!isGloballyEnabled) return;

    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      channelRemindersId,
      channelRemindersName,
      channelDescription: channelRemindersDesc,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF0F766E),
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      debugPrint('⏰ [Notification Scheduled] ID: $id at $tzDateTime: "$title"');
    } catch (e) {
      debugPrint('⚠️ [Scheduling Exact Alarm Fallback]: $e. Retrying inexact...');
      try {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          tzDateTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
      } catch (e2) {
        debugPrint('⚠️ [Notification Schedule Inexact Error]: $e2');
      }
    }
  }

  /// Schedules a full suite of pre-alerts for a single domain item:
  /// - 1 hour before due time
  /// - 30 minutes before due time
  /// - At exact due time
  Future<void> scheduleItemReminders({
    required String itemId,
    required String title,
    required String subtitle,
    required DateTime dueDateTime,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final is1hEnabled = prefs.getBool(keyAlert1hEnabled) ?? true;
      final is30mEnabled = prefs.getBool(keyAlert30mEnabled) ?? true;
      final isAtDueEnabled = prefs.getBool(keyAlertAtDueEnabled) ?? true;

      final baseId = itemId.hashCode.abs() % 500000;

      // 1. 1 hour before alert
      if (is1hEnabled) {
        final oneHourBefore = dueDateTime.subtract(const Duration(hours: 1));
        if (oneHourBefore.isAfter(DateTime.now())) {
          await scheduleNotification(
            id: baseId * 3 + 1,
            title: '⏳ ১ ঘণ্টা বাকি: $title',
            body: subtitle.isNotEmpty
                ? '$subtitle — আর ১ ঘণ্টা পর নির্ধারিত সময়।'
                : 'আপনার নির্ধারিত কাজটির আর মাত্র ১ ঘণ্টা বাকি রয়েছে।',
            scheduledDate: oneHourBefore,
            payload: itemId,
          );
        }
      }

      // 2. 30 minutes before alert
      if (is30mEnabled) {
        final thirtyMinsBefore =
            dueDateTime.subtract(const Duration(minutes: 30));
        if (thirtyMinsBefore.isAfter(DateTime.now())) {
          await scheduleNotification(
            id: baseId * 3 + 2,
            title: '⚠️ ৩০ মিনিট বাকি: $title',
            body: subtitle.isNotEmpty
                ? '$subtitle — আর ৩০ মিনিট পরেই সময় হচ্ছে।'
                : 'আর মাত্র ৩০ মিনিট পর আপনার নির্ধারিত কাজের সময়।',
            scheduledDate: thirtyMinsBefore,
            payload: itemId,
          );
        }
      }

      // 3. At exact due time
      if (isAtDueEnabled) {
        if (dueDateTime.isAfter(DateTime.now())) {
          await scheduleNotification(
            id: baseId * 3 + 3,
            title: '⏰ এখনই সময়: $title',
            body: subtitle.isNotEmpty
                ? subtitle
                : 'আপনার নির্ধারিত রিমাইন্ডারের সময় হয়েছে। বিস্তারিত দেখুন।',
            scheduledDate: dueDateTime,
            payload: itemId,
          );
        }
      }
    } catch (e) {
      debugPrint('⚠️ [NotificationService.scheduleItemReminders Error]: $e');
    }
  }

  /// Cancels all scheduled alerts for a specific item
  Future<void> cancelItemReminders(String itemId) async {
    try {
      final baseId = itemId.hashCode.abs() % 500000;
      await _plugin.cancel(baseId * 3 + 1);
      await _plugin.cancel(baseId * 3 + 2);
      await _plugin.cancel(baseId * 3 + 3);
    } catch (e) {
      debugPrint('⚠️ [NotificationService.cancelItemReminders Error]: $e');
    }
  }

  /// Cancels all pending notifications
  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
      debugPrint('🗑️ [All Notifications Cancelled]');
    } catch (e) {
      debugPrint('⚠️ [NotificationService.cancelAll Error]: $e');
    }
  }

  /// Syncs all upcoming tasks, bills, money entries, medicines from HomeService
  /// and automatically schedules their alerts and the daily morning briefing.
  Future<void> syncAllReminders(HomeService homeService) async {
    await init();
    final items = homeService.getAll();
    final now = DateTime.now();

    int count = 0;
    for (final item in items) {
      if (item.when.isAfter(now)) {
        await scheduleItemReminders(
          itemId: item.id,
          title: item.title,
          subtitle: item.subtitle ?? '',
          dueDateTime: item.when,
        );
        count++;
      }
    }

    debugPrint('🔄 [NotificationService] Synced $count future items into background alarms.');
  }

  /// Triggers an immediate test notification with sound and banner
  Future<void> sendTestNotification() async {
    await showInstantNotification(
      id: 9999,
      title: '🔔 সেবা বন্ধু নোটিফিকেশন সক্রিয়!',
      body:
          'আপনার ব্যাকগ্রাউন্ড ও ডেড-অ্যাপ রিমাইন্ডার সফলভাবে সক্রিয় হয়েছে। যেকোনো কাজের ৩০ মিনিট ও ১ ঘণ্টা আগে তাগাদা পাবেন।',
    );
  }
}
