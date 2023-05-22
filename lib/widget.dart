import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';
import 'package:google_fonts/google_fonts.dart';

class AccidentOccurredWidget extends StatefulWidget {
  final List<double>? accelerometerValues;
  final DateTime? startTime;
  final double distance;

  const AccidentOccurredWidget({
    Key? key,
    required this.accelerometerValues,
    required this.startTime,
    required this.distance,
  }) : super(key: key);

  @override
  _AccidentOccurredWidgetState createState() => _AccidentOccurredWidgetState();
}

class _AccidentOccurredWidgetState extends State<AccidentOccurredWidget> {
  void _makeEmergencyCall() async {
    final Uri phoneLaunchUri = Uri(scheme: 'tel', path: '911');
    if (await launchUrl(phoneLaunchUri)) {
      await launchUrl(phoneLaunchUri);
    } else {
      throw 'Could not launch 911';
    }
  }

  void _shareLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    String latitude = position.latitude.toString();
    String longitude = position.longitude.toString();
    String message = 'I have had an accident Please Help, Accident location : $latitude, $longitude';
    final Uri shareLocationUri = Uri(
      scheme: 'sms',
      path: '01020737211',
      queryParameters: {'body': message},
    );
    if (await launchUrl(shareLocationUri)) {
      await launchUrl(shareLocationUri);
    } else {
      throw 'Could not share location';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: ((context) => const AccidentDetector())),
                  (route) => false,
            );
          },
        ),
        title: Text(
          '   Accident Detected!!',
          style: GoogleFonts.cairo(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.335,
              margin: const EdgeInsets.only(top: 0),
              child: Image.asset(
                'images/Car_Crash.png',
                width: 300,
                height: 300,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'An accident has occurred!',
              textAlign: TextAlign.center,
              style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,color: Colors.red, fontSize: 30,),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Text(
                  'Time:',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,fontSize: 24, color: Colors.black),
                ),
                Text(
                  widget.startTime.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,fontSize: 18, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Distance:   ',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,fontSize: 22, color: Colors.black),
                ),
                Text(
                  widget.distance.toStringAsFixed(2),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,fontSize: 18, color: Colors.blue),
                ),
                Text(
                  ' m',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,fontSize: 20, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<Position>(
              future: Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  double latitude = snapshot.data!.latitude;
                  double longitude = snapshot.data!.longitude;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Location: ',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,fontSize: 24, color: Colors.black),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Lat:  ',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '$latitude',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            '  ,  ',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,fontSize: 24 , color: Colors.black),
                          ),
                          Text(
                            '   Lon:  ',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ), Text(
                            '$longitude',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text(
                    'Error retrieving location',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,color: Colors.red, fontSize: 24),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.05),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.blue,
                ),
                onPressed: _makeEmergencyCall,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  child: Text(
                    'Call Emergency !!',
                    style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,fontSize: 18, color: Colors.black),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.blue,
                ),
                onPressed: _shareLocation,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  child: Text(
                    'Share Location',
                    style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w500,fontSize: 18, color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
