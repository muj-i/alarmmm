import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:alarmmm/app.dart';
import 'package:alarmmm/controller/home_controller.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_notification/local_notification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initPlatformState();
  await GetStorage.init();
  runApp(const App());
}

// class LocalNotification2 {
//   static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

// static Future<void> init(String channelId, BuildContext context) async {
//   const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'my_foreground', // Channel ID
//     'My Foreground Service', // Channel name
//     description: 'This channel is used for foreground service notifications',
//     importance: Importance.high,
//   );

//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('notification_icon'); // Default app icon
//   const DarwinInitializationSettings initializationSettingsIOS =
//       DarwinInitializationSettings();

//   await flutterLocalNotificationsPlugin.initialize(
//     const InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     ),
//   );

//     final androidNotificationPlugin =
//         flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>();

//     await androidNotificationPlugin?.createNotificationChannel(channel);
//   }

//   static void showLocalNotification(int id, String title, String body) {
//     flutterLocalNotificationsPlugin.show(
//       id,
//       title,
//       body,
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'my_foreground', // Channel ID
//           'My Foreground Service', // Channel name
//           channelDescription: 'This is a foreground notification',
//           icon: 'ic_launcher', // Replace with a valid icon in drawable
//           ongoing: true,
//         ),
//       ),
//     );
//   }
// }

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // Initialize notifications
  if (Platform.isAndroid || Platform.isIOS) {
    await LocalNotification.init(
      channelId: 'my_foreground',
      channelName: 'My Foreground Service',
      channelDescription:
          'This channel is used for foreground service notifications',
    );
  }

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: '',
      initialNotificationContent: '',
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [AndroidForegroundType.mediaPlayback],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Timer.periodic(const Duration(seconds: 1), (timer) async {
  if (service is AndroidServiceInstance) {
    if (await service.isForegroundService()) {
      //       LocalNotification2.showLocalNotification(
      //         888,
      //         'COOL SERVICE',
      //         'Awesome ${DateTime.now()}',
      //       );
      // playAudio(setVolume: 200.0);
      // final HomeController c = HomeController();
      onInit();
      log('Service is running in the foreground');
      startAlarmListener();
      log('Service is running in the foregroundx');
      // playAudio(setVolume: 200.0);
    }
    service.setForegroundNotificationInfo(
      title: 'A L A R M M M M M......',
      content: 'Running for background service',
    );
    //     }
  }

  debugPrint('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

  final deviceInfo = DeviceInfoPlugin();
  String? device;
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    device = androidInfo.model;
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    device = iosInfo.model;
  }

  service.invoke(
    'update',
    {
      "current_date": DateTime.now().toIso8601String(),
      "device": device,
    },
  );
}
