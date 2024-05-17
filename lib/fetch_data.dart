import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}

FirebaseDatabase database = FirebaseDatabase.instance;
final DatabaseReference ref = FirebaseDatabase.instance.ref('esp');

class SensorData {
  double temp = 0.0;
  double lat = 0.0;
  double lng = 0.0;
  double bpm = 0.0;
}

class Fetch {
  final sensorData = ref.child('temp');
  final sensorData1 = ref.child('lat');
  final sensorData2 = ref.child('lng');
  final sensorData3 = ref.child('heartRate');

  Stream<double> getTemperatureStream() {
    return sensorData.onValue
        .map((event) => (event.snapshot.value as num).toDouble());
  }

  Stream<double> getLatitudeStream() {
    return sensorData1.onValue
        .map((event) => (event.snapshot.value as num).toDouble());
  }

  Stream<double> getLongitudeStream() {
    return sensorData2.onValue
        .map((event) => (event.snapshot.value as num).toDouble());
  }

  Stream<double> getHeartRateStream() {
    return sensorData3.onValue
        .map((event) => (event.snapshot.value as num).toDouble());
  }
}
