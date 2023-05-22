import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors/sensors.dart';
import 'body.dart';
import 'widget.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const AccidentDetector());
}



class AccidentDetector extends StatefulWidget {
  const AccidentDetector({super.key});

  @override
  _AccidentDetectorState createState() => _AccidentDetectorState();
}

class _AccidentDetectorState extends State<AccidentDetector> {
  List<double>? _accelerometerValues;
  DateTime? _startTime;
  double _accelerationDifference = 0;
  bool _isCalculating = false;
  bool _accidentOccurred = false;
  double _distance = 0.0;
  Position? _previousPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  final Stopwatch _stopwatch = Stopwatch();


  @override
  void initState() {
    super.initState();
    requestLocationPermissio();


    _accelerometerValues = <double>[0, 0, 0];
  }

  @override
  void dispose() {
    super.dispose();
    stopLocationTracking();
  }


  Future<void> requestLocationPermissio() async {
    final permissionStatus = await Geolocator.requestPermission();
    if (permissionStatus == LocationPermission.denied) {
      setState(() {});
    } else if (permissionStatus == LocationPermission.deniedForever) {
      setState(() {});
    } else {
      setState(() {
      });
      startLocationTracking();
    }
  }

  void startLocationTracking() {
    _positionStreamSubscription = Geolocator.getPositionStream().listen(
          (Position position) {
        setState(() {
          if (_previousPosition != null) {
            final double distanceInMeters = Geolocator.distanceBetween(
              _previousPosition!.latitude,
              _previousPosition!.longitude,
              position.latitude,
              position.longitude,
            );
            _distance += distanceInMeters;
          }
          _previousPosition = position;
        });
      },
    );
    _stopwatch.start();
  }

  void stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    _stopwatch.stop();
  }

  void pauseLocationTracking() {
    if (_positionStreamSubscription != null && _stopwatch.isRunning) {
      _stopwatch.stop();
    }
  }

  void resetTracking() {
    setState(() {
      _distance = 0.0;
      _previousPosition = null;
      _stopwatch.reset();
    });
  }


  void _startMyApp() async {
    setState(() {
      _isCalculating = true;
    });

    accelerometerEvents.listen((AccelerometerEvent event) {
      double currentAcceleration =
          (event.x * event.x) + (event.y * event.y) + (event.z * event.z);
      double previousAcceleration =
          (_accelerometerValues![0] * _accelerometerValues![0]) +
              (_accelerometerValues![1] * _accelerometerValues![1]) +
              (_accelerometerValues![2] * _accelerometerValues![2]);
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
        _accelerationDifference =
            (((currentAcceleration - previousAcceleration).abs()) / 1000)
                .toDouble();

        if (_accelerationDifference > 1) {
          _startTime = DateTime.now();
          _accidentOccurred = true;
          _isCalculating = false;
        }
      });
    });

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home:  _accidentOccurred
            ? AccidentOccurredWidget(
          startTime: _startTime,
          accelerometerValues: _accelerometerValues,
          distance: _distance,
        )
            : AccidentDetectorBody(
          isCalculating: _isCalculating,
          accelerometerValues: _accelerometerValues,
          accelerationDifference: _accelerationDifference,
          startTime: _startTime,
          startMyApp: _startMyApp,
          distance: _distance,
        ),);
  }
}


