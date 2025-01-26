import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tools/background_foreground_service.dart'; // Import your background service logic

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService(); // Initialize background service
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ServiceControlScreen(),
    );
  }
}

class ServiceControlScreen extends StatefulWidget {
  const ServiceControlScreen({super.key});

  @override
  State<ServiceControlScreen> createState() => _ServiceControlScreenState();
}

class _ServiceControlScreenState extends State<ServiceControlScreen> {
  bool isServiceRunning = false;

  @override
  void initState() {
    super.initState();
    _loadServiceState();
  }

  Future<void> _loadServiceState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shouldRun = prefs.getBool('shouldRunService') ?? false;
    setState(() {
      isServiceRunning = shouldRun;
    });
    if (shouldRun) {
      _startService(); // Restart the service if it should be running
    }
  }

  // Start the service
  void _startService() async {
    startBackgroundService();
    await Future.delayed(Duration(seconds: 2)); // Allow service to start
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('shouldRunService', true);
    setState(() {
      isServiceRunning = true;
    });
  }

  // Stop the service
  void _stopService() async {
    stopBackgroundService();
    await Future.delayed(Duration(seconds: 2)); // Allow service to stop
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('shouldRunService', false);
    setState(() {
      isServiceRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Background Service Control')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isServiceRunning.toString()),
            Text(
              isServiceRunning ? "Service is Running" : "Service is Stopped",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isServiceRunning ? _stopService : _startService,
              child: Text(isServiceRunning ? "Stop Service" : "Start Service"),
            ),
          ],
        ),
      ),
    );
  }
}
