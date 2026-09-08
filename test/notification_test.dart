import 'package:flutter_test/flutter_test.dart';
import 'package:sheba_bondhu/services/notification/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        NotificationService.keyNotificationsEnabled: true,
        NotificationService.keyAlert1hEnabled: true,
        NotificationService.keyAlert30mEnabled: true,
        NotificationService.keyAlertAtDueEnabled: true,
      });
    });

    test('Default notification configuration and channel constants', () {
      expect(NotificationService.channelRemindersId, equals('sheba_bondhu_reminders'));
      expect(NotificationService.channelDailyId, equals('sheba_bondhu_daily'));
      expect(NotificationService.keyNotificationsEnabled, equals('pref_notifications_enabled'));
      expect(NotificationService.keyAlert1hEnabled, equals('pref_alert_1h_enabled'));
      expect(NotificationService.keyAlert30mEnabled, equals('pref_alert_30m_enabled'));
    });

    test('Schedule reminders does not throw even with mock channel', () async {
      final now = DateTime.now();
      final futureDue = now.add(const Duration(hours: 2));

      // Should safely complete without unhandled exception
      await NotificationService.instance.scheduleItemReminders(
        itemId: 'task_test_123',
        title: 'টেস্ট কাজ',
        subtitle: 'সাবটাইটেল',
        dueDateTime: futureDue,
      );

      await NotificationService.instance.cancelItemReminders('task_test_123');
    });
  });
}
