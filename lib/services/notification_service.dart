// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// class NotificationService {
//   static final NotificationService _notificationService = NotificationService._internal();

//   factory NotificationService() {
//     return _notificationService;
//   }

//   NotificationService._internal();

//   final _flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();

//   Future<void> init() async {
//     //Initialization Settings for Android
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/logo');

//     //Initialization Settings for iOS
//     const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
//       requestSoundPermission: false,
//       requestBadgePermission: false,
//       requestAlertPermission: false,
//     );

//     //Initializing settings for both platforms (Android & iOS)
//     const InitializationSettings initializationSettings = InitializationSettings(
//         android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

//     tz.initializeTimeZones();

//     try {
//       await _flutterLocalNotificationPlugin.initialize(
//         initializationSettings,
//         onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
//         onDidReceiveBackgroundNotificationResponse: onDidRecieveBackgroundNotificationResponse,
//       );
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future<void> requestIOSPermissions() async {
//     var isGranted = await _flutterLocalNotificationPlugin
//         .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
//         ?.requestPermissions(
//           alert: true,
//           badge: true,
//           sound: true,
//         );

//     print('[IOSFlutterLocalNotificationsPermission - $isGranted]');
//   }

//   static onDidReceiveNotificationResponse(NotificationResponse response) async {
//     print(response.id);
//   }

//   static onDidRecieveBackgroundNotificationResponse(NotificationResponse response) async {
//     print(response.payload);
//   }

//   Future<void> showNotifications(
//       {required int id, required String title, required String body, dynamic payload}) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
//         'your channel id', 'LE Teams App',
//         channelDescription: 'Literature evangelist companion app',
//         importance: Importance.max,
//         priority: Priority.high,
//         ticker: 'ticker');
//     const NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);
//     try {
//       await _flutterLocalNotificationPlugin.show(id, title, body, platformChannelSpecifics,
//           payload: payload);
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future<void> scheduleNotification(
//       {required int id,
//       required String title,
//       required String body,
//       required DateTime time}) async {
//     try {
//       await _flutterLocalNotificationPlugin.zonedSchedule(
//         id,
//         title,
//         body,
//         tz.TZDateTime.from(time, tz.local),
//         const NotificationDetails(
//             android: AndroidNotificationDetails('your channel id', 'LE Teams App',
//                 channelDescription: 'Literature evangelist companion app')),
//         androidScheduleMode: AndroidScheduleMode.alarmClock,
//         uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
//       );
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future<void> deleteNotification(int notifID) async {
//     try {
//       await _flutterLocalNotificationPlugin.cancel(notifID);
//     } catch (e) {
//       print('Delete notification error: $e');
//     }
//   }

//   Future<void> deleteAllNotification() async {
//     await _flutterLocalNotificationPlugin.cancelAll();
//   }
// }
