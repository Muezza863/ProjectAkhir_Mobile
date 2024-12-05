import 'package:awesome_notifications/awesome_notifications.dart';

Future<void> scheduleNotifications(DateTime eventTime) async {
  // Notifikasi sehari sebelum
  DateTime oneDayBefore = eventTime.subtract(Duration(days: 1));
  if (oneDayBefore.isAfter(DateTime.now())) {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().microsecondsSinceEpoch.remainder(100000), // ID harus unik
        channelKey: 'basic_channel',
        title: "Remainder: Tomorrow's Vacation Plan!",
        body: "You have a plan tomorrow at ${eventTime.toLocal()}. It's best to prepare all the necessary requirements",
      ),
      schedule: NotificationCalendar.fromDate(date: oneDayBefore),
    );
  }

  // Notifikasi sejam sebelum
  DateTime oneHourBefore = eventTime.subtract(Duration(hours: 1));
  if (oneHourBefore.isAfter(DateTime.now())) {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().microsecondsSinceEpoch.remainder(100000),
        channelKey: 'basic_channel',
        title: 'Remainder: Plan 1 Hour Later!',
        body: 'Your plan is in one hour at ${eventTime.toLocal()}. Is everyone ready to go?',
      ),
      schedule: NotificationCalendar.fromDate(date: oneHourBefore),
    );
  }

  // Notifikasi saat waktu acara
  if (eventTime.isAfter(DateTime.now())) {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().microsecondsSinceEpoch.remainder(100000),
        channelKey: 'basic_channel',
        title: 'Happy Holidays',
        body: 'Enjoy your holiday!',
      ),
      schedule: NotificationCalendar.fromDate(date: eventTime),
    );
  }
}
