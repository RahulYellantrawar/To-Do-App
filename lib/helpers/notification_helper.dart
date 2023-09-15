import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:to_do/helpers/task.dart';

class NotifyHelper {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  initializeNotification() async {
    _configureLocalTimezone();
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("appicon");

    const InitializationSettings initializationSettings =
        InitializationSettings(
      iOS: initializationSettingsIOS,
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  scheduledNotification(TimeOfDay selectedTime, Task task) async {
    print('${task.date} ${task.time}');
    DateTime date = DateFormat('MM/dd/yyyy').parse(task.date);
    print(date);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'You have an incomplete task',
      task.subject,
      _convertTime(date.year, date.month, date.day, selectedTime.hour,
          selectedTime.minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description',
          priority: Priority.high,
          actions: [markAsCompletedAction],
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'markAsCompleted',
      matchDateTimeComponents: DateTimeComponents.dateAndTime, //repeat
    );
  }

  AndroidNotificationAction markAsCompletedAction =
      const AndroidNotificationAction(
    'markAsCompleted',
    'Mark as Completed',
  );

  tz.TZDateTime _convertTime(
      int year, int month, int day, int hour, int minutes) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleDate =
        tz.TZDateTime(tz.local, year, month, day, hour, minutes);
    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }
    return scheduleDate;
  }

  Future<void> _configureLocalTimezone() async {
    tz.initializeTimeZones();
    const String timezone = 'Asia/Kolkata';
    print(timezone);
    tz.setLocalLocation(tz.getLocation(timezone));
  }

  Future displayNotification(
      {required String title, required String body}) async {
    print("doing test");
    try {
      var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
          'your channel id', 'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high);

      var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );
      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
        payload: 'It could be anything you pass',
      );
      print('Showing notification');
    } catch (error) {
      print(error);
    }
  }
}
