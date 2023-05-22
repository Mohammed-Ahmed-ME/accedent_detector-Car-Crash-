import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:async';

class AccidentDetectorBody extends StatefulWidget {
  final bool isCalculating;
  final List<double>? accelerometerValues;
  final double accelerationDifference;
  final DateTime? startTime;
  final Function() startMyApp;
  final double distance;

  const AccidentDetectorBody({
    Key? key,
    required this.isCalculating,
    required this.accelerometerValues,
    required this.accelerationDifference,
    required this.startTime,
    required this.startMyApp,
    required this.distance,
  }) : super(key: key);

  @override
  _AccidentDetectorBodyState createState() => _AccidentDetectorBodyState();
}

class _AccidentDetectorBodyState extends State<AccidentDetectorBody> {
  Timer? _timer;
  int _minutes = 0;
  int _seconds = 0;
  double _updatedDistance = 0.0;
  double _updatedSpeed = 0.0;
  @override
  void initState() {

    super.initState();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if(widget.isCalculating)
        {
        _seconds++;
        if (_seconds == 60) {
          _seconds = 0;
          _minutes++;
        }
        }
      });
    });

  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

    void resetTracking() {
    setState(() {
      _minutes = 0;
      _seconds = 0;
    });
  }

  String getFormattedTime() {
    String hoursStr = (_minutes ~/ 60).toString().padLeft(2, '0');
    String minutesStr = (_minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (_seconds % 60).toString().padLeft(2, '0');
    return '$hoursStr:$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.black,
        title:  Text('Accident Detector',
        style: GoogleFonts.cairo(fontSize: 25,fontWeight: FontWeight.bold , color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
Container(
  margin: const EdgeInsets.only(top: 20),
  child:   Text(
                  widget.isCalculating
                      ? 'Accident Detecting...'
                      : 'Please click the button below to get started',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(fontSize: 25,color: widget.isCalculating ? Colors.black :   Colors.blue),
                ),
),
              Container(
                margin: const EdgeInsets.only(),
                child: Text(
                  getFormattedTime(),
                  textAlign: TextAlign.center,
                  style:  GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,fontSize: 35,color: widget.isCalculating ? Colors.blue :   Colors.white),
                ),
              ),

              const SizedBox(height: 16),
              if (widget.accelerometerValues != null)
                Column(
                  children: [
                    Text(
                      'X: ${widget.accelerometerValues![0].toStringAsFixed(2)} , Y: ${widget.accelerometerValues![1].toStringAsFixed(2)} , Z: ${widget.accelerometerValues![2].toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,fontSize: 20,color: widget.isCalculating ? Colors.white :   Colors.blue),
                    ),


                    AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height*0.335,
                              child: Image.asset( widget.accelerationDifference < 0.01 ? 'images/carStop.jpg' : 'images/car.gif',
                                fit: BoxFit.cover,
                              ),
                            ),
                            Text(
                          widget.accelerationDifference < 0.01 ? 'Your Car is Parked!' : 'Your Speed is Normal!',
                          textAlign: TextAlign.center,
                          style:
                              GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,color:widget.accelerationDifference < 0.01 ? Colors.green : Colors.blue, fontSize: 25),
                        ),
                        ],
                      ),
                    ),



                  ],
                ),
              const SizedBox(height: 16),
                            Column(
                children: [

                  Slider(
                    min: 0.0,
                    max: 200.0,
                    value: _updatedDistance != 0.0 ? _updatedDistance : widget.distance,
                    onChanged: (value) {
                      setState(() {
                        _updatedDistance = value;
                      });
                    },
                    divisions: 10,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey,
                    label: 'Distance',
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Distance: ',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,fontSize: 23,color: Colors.black),
                      ),
                      Text(
                        _updatedDistance != 0.0
                            ? _updatedDistance.toStringAsFixed(2)
                            : widget.distance.toStringAsFixed(2),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,fontSize: 23,color: Colors.blue),
                      ),
                      Text(
                        ' m ',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,fontSize: 23,color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),

                            FutureBuilder<Position>(
                future: Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    double latitude = snapshot.data!.latitude;
                    double longitude = snapshot.data!.longitude;
                    return Column(
                      children: [
                                                Column(
                          children: [

                            Slider(
                              min: 0.0,
                              max: 5.0,
                              value: _updatedSpeed != 0.0 ? _updatedSpeed : snapshot.data!.speed,
                              onChanged: (value) {
                                setState(() {
                                  _updatedSpeed = value;
                                });
                              },
                              divisions: 10,
                              activeColor: Colors.blue,
                              inactiveColor: Colors.grey,
                              label: 'Speed',
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Speed: ',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,
                                      fontSize: 23,color:Colors.black),
                                ),
                                Text(
                                  _updatedSpeed != 0.0
                                      ? _updatedSpeed.toStringAsFixed(3)
                                      : snapshot.data!.speed.toStringAsFixed(3),                              textAlign: TextAlign.center,
                              style:  GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,
                                  fontSize: 23, color: Colors.blue),
                            ),
                              Text(
                              ' m/s',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,
                                  fontSize: 23 ,color:Colors.black),
                            ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
        Text(
                    'Acceleration Difference: ',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500, fontSize: 23,color:Colors.black),
                  ),
Text(
                    widget.accelerationDifference.toStringAsFixed(2),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500, fontSize: 23,color: Colors.blue),
                  ),
  ],
),
              const SizedBox(height: 16),

                        Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Location: ',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.zillaSlab
(fontSize: 22, color: Colors.black),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Lat:  ',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.zillaSlab
(
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  '$latitude',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.zillaSlab
(
                                    fontSize: 18,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  '  ,  ',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.zillaSlab
(fontSize: 24 , color: Colors.black),
                                ),
                                Text(
                                  '   Lon:  ',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.zillaSlab
(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ), Text(
                                  '$longitude',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.zillaSlab
(
                                    fontSize: 18,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                      'Error retrieving location',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,color: Colors.red,fontSize: 23),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              const SizedBox(height: 16),

              Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: ElevatedButton(
                          onPressed:widget.startMyApp,

                          style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              backgroundColor: Colors.blue,
                              ),
                          child:  Container(
                            padding:  EdgeInsets.symmetric(vertical: widget.isCalculating ? 10 : 15,horizontal: widget.isCalculating ? 90 :40),
                            child: widget.isCalculating ? const CircularProgressIndicator(color: Colors.black,strokeWidth: 4,)
                            : Text('Start Detecting',style: GoogleFonts.rye(fontSize: 18,color: Colors.black),))
                        ),
                  ),

            ],
          ),
        ),
      ),
    );
  }
}
