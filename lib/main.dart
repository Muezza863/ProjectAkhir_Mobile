import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisata/Pages/login_page.dart';
import 'package:wisata/Pages/signup_page.dart';
import 'package:timezone/data/latest.dart' as tz; // Untuk timezone
import 'Pages/home_page.dart';
import 'Pages/splash_page.dart';
import 'model/itinerary.dart';
import 'model/plan.dart';
import 'model/travelhistory.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(PlanAdapter());
  Hive.registerAdapter(TravelHistoryAdapter());

  await Hive.openBox<Plan>('plans');
  await Hive.openBox<TravelHistory>('travel_history');

  AwesomeNotifications().initialize(
    'resource://drawable/ic_notification', // Ikon notifikasi
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
      )
    ],
    debug: true,
  );

  // Meminta izin notifikasi
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // final storage = FlutterSecureStorage();

  MyApp({super.key});
  static final GlobalKey<NavigatorState>
  navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _checkLogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return snapshot.data == true ? Home() : SplashPage();
          }
        },
      ),
    );


        // return MaterialApp(
        //   title: 'Flutter Demo',
        //   debugShowCheckedModeBanner: false,
        //   theme: ThemeData(
        //     colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        //     useMaterial3: true,
        //   ),
        //   home: SplashPage(),
        // );
    }
  Future<bool> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }
  }

