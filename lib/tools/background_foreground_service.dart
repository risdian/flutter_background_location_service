import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void startBackgroundService() async {
  final service = FlutterBackgroundService();
  // service.startService();
  service.invoke("start");
}

void stopBackgroundService() {
  final service = FlutterBackgroundService();
  service.invoke("stop");
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      autoStart: true,
      onStart: onStart,
      isForegroundMode: false,
      autoStartOnBoot: true,
    ),
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool shouldRun = prefs.getBool('shouldRunService') ?? false;
  if (shouldRun) {
    service.startService();
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool shouldRun = prefs.getBool('shouldRunService') ?? false;

  print("Service started: shouldRunService=$shouldRun");
  // Check if the service should run immediately on start
  if (shouldRun) {
    _startPeriodicTask(true);
  }

  service.on("stop").listen((event) async {
    await prefs.setBool('shouldRunService', false);
    print('stop');
    service.stopSelf(); // Stop the service

    // _startPeriodicTask(false);
  });

  service.on("start").listen((event) async {
    await prefs.setBool('shouldRunService', true);

    print('start');
    _startPeriodicTask(true);
  });
}

// Function to start the periodic task
void _startPeriodicTask(bool shouldRun) {
  if (shouldRun) {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      print("Background service is active at ${DateTime.now()} $shouldRun");
    });
  }
}
