import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:to_do/helpers/constants.dart';
import 'package:to_do/helpers/notification_helper.dart';
import 'package:to_do/screens/home.dart';
import 'package:to_do/helpers/task_provider.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  var notifierHelper = NotifyHelper();
  WidgetsFlutterBinding.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  notifierHelper;
  notifierHelper.initializeNotification();
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TaskProvider(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'To-Do List',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: color1),
          useMaterial3: true,
        ),
        home: HomeScreen(),
      ),
    );
  }
}
