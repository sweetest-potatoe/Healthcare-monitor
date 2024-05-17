import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:telephony/telephony.dart';
import 'fetch_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: 'API-KEY',
    appId: 'APP_ID',
    messagingSenderId: 'MESSAGING_SENDER_ID',
    projectId: 'PROJECT_ID',
    storageBucket: 'STORAGE_BUCKET',
  ));
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _message = "";
  final telephony = Telephony.instance;
  final fetch = Fetch();
  double temp = 0;
  double lat = 0;
  double lng = 0;
  double bpm = 0;

  @override
  void initState() {
    super.initState();
    final fetch = Fetch();
    fetch.getTemperatureStream().listen((temperature) {
      setState(() {
        temp = temperature;
      });
    });
    fetch.getLatitudeStream().listen((latitude) {
      setState(() {
        lat = latitude;
      });
    });
    fetch.getLongitudeStream().listen((longitude) {
      setState(() {
        lng = longitude;
      });
    });
    fetch.getHeartRateStream().listen((heartRate) {
      setState(() {
        bpm = heartRate;
        ;
      });
    });
  }

  onSendStatus(SendStatus status) {
    setState(() {
      _message = status == SendStatus.SENT ? "sent" : "delivered";
    });
  }

  Future<void> initPlatformState() async {
    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {}
    if (!mounted) return;
  }

  Future<void> sendEmergencySMS(String smsMessage) async {
    // Request permissions if not already granted
    final bool? result = await telephony.requestPhoneAndSmsPermissions;
    if (result != null && !result) {
      debugPrint('SMS permissions not granted. Cannot send message.');
      return; // Exit if permissions not granted
    }

    final String message = smsMessage;

    try {
      await telephony.sendSms(to: "0000000000", message: message);
      debugPrint('SMS sent successfully!');
    } catch (error) {
      debugPrint('Error sending SMS: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Healthcare Monitor'),
        ),
        body: Center(
            child: ListView(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            CircularPercentIndicator(
              radius: 110.0,
              lineWidth: 20.0,
              animation: true,
              animationDuration: 700,
              circularStrokeCap: CircularStrokeCap.round,
              percent: 0.4,
              center: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.thermostat_outlined,
                      size: 80.0,
                      color: Colors.cyan[300],
                    ),
                    SizedBox(
                      width: 0.0,
                    ),
                    Text(
                      "${temp.toStringAsFixed(1)} °C",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 25.0),
                    )
                  ]),
              progressColor: Colors.cyan[300],
            ),
            SizedBox(
              height: 20,
            ),
            CircularPercentIndicator(
              radius: 110.0,
              animation: true,
              animationDuration: 1200,
              lineWidth: 20.0,
              percent: 0.8,
              center: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.monitor_heart_outlined,
                    size: 80.0,
                    color: Colors.redAccent,
                  ),
                  Text(
                    "${bpm.toStringAsFixed(0)}\nBPM",
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 25.0),
                  ),
                ],
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.redAccent,
            ),
            SizedBox(
              height: 20,
            ),
          ],
        )),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.emergency_rounded),
          onPressed: () => sendEmergencySMS(
              "Alert:\nlocation:(latitude: $lat, longitude: $lng)"),
        ),
      ),
    );
  }
}
