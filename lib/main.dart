import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool hasPermission = false;

  void fetchPermissionStatus() async {
    final status = await Permission.locationWhenInUse.status;
    setState(() {
      hasPermission = status == PermissionStatus.granted;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchPermissionStatus();
  }

  Widget buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        double? direction = snapshot.data?.heading;
        if (direction == null) {
          return Text("This device does not have a compass sensor!");
        }
        return Center(
          child: Transform.rotate(
            angle: (direction * (pi / 180) * -1),
            child: Image.asset(
              "assets/images/1.png",
              height: 350,
              width: 350,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget buildRequestPermission() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Request location permission
          Permission.locationWhenInUse.request().then((status) {
            setState(() {
              hasPermission = status == PermissionStatus.granted;
            });
          });
        },
        child: Text('Request Permission'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.redAccent,
        body: Builder(
          builder: (context) {
            if (hasPermission) {
              return buildCompass();
            } else {
              return buildRequestPermission();
            }
          },
        ),
      ),
    );
  }
}