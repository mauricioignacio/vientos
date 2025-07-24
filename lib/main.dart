import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(WindApp());
}

class WindApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viento Guacolda',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WindScreen(),
    );
  }
}

class WindScreen extends StatefulWidget {
  @override
  _WindScreenState createState() => _WindScreenState();
}

class _WindScreenState extends State<WindScreen> {
  double windSpeed = 0.0;
  final String apiKey = "9b5f39d9f4ce51d3dd0f43f4047a479d"; // API Key configurada
  final String lat = "-28.5348";
  final String lon = "-71.1783";

  FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _fetchWindSpeed();
    _startHourlyNotification();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings settings = InitializationSettings(android: androidSettings);
    await notificationsPlugin.initialize(settings);
  }

  Future<void> _fetchWindSpeed() async {
    final url = Uri.parse("https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      double speedMS = data['wind']['speed'] ?? 0.0;
      setState(() {
        windSpeed = speedMS * 3.6; // m/s a km/h
      });
    }
  }

  void _startHourlyNotification() {
    Timer.periodic(Duration(hours: 1), (timer) async {
      await _showNotification();
    });
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'wind_channel',
      'Velocidad del Viento',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(
      0,
      'Reporte Guacolda',
      'Velocidad del viento: ${windSpeed.toStringAsFixed(1)} km/h',
      details,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Viento Guacolda')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Velocidad del viento', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('${windSpeed.toStringAsFixed(1)} km/h', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchWindSpeed,
              child: Text('Actualizar ahora'),
            ),
          ],
        ),
      ),
    );
  }
}
