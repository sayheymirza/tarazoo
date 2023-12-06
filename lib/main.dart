import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // white statusbar and navigationbar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'Tarazoo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool onGround = false;
  String weight = '0.0';
  Color color = Color(0xffFE8F36);

  @override
  void initState() {
    super.initState();

    detectGround();
  }

  void detectGround() {
    accelerometerEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    ).listen((event) {
      if (event.z > 9.5) {
        if (onGround) {
          return;
        }

        print('on ground');

        setState(() {
          onGround = true;
        });

        startFindingWeight();
      } else {
        if (!onGround) {
          return;
        }

        print('not on ground');

        setState(() {
          onGround = false;
        });
      }
    });
  }

  void startFindingWeight() async {
    double value = generateRandomWeight();

    print(value);

    // increment weight from 0 to value for 5 times with 1 second delay
    for (int i = 5; i > 0; i--) {
      await Future.delayed(
        const Duration(seconds: 1),
        () {
          setState(() {
            weight = (value / i).toStringAsFixed(2);
          });
        },
      );
    }
  }

  double generateRandomWeight({
    int min = 30,
    int max = 150,
  }) {
    return (min + (max - min) * Random().nextDouble());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 120),
            onGround
                ? Text(
                    weight,
                    style: TextStyle(
                      fontSize: 65,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.orbitron().fontFamily,
                      // yellow color
                      color: color,
                      // neon shadow effect
                      shadows: [
                        Shadow(
                          color: color,
                          blurRadius: 140,
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      const Icon(
                        Icons.edgesensor_low,
                        size: 200,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 32,
                        ),
                        child: SizedBox(
                          width: 300,
                          child: Text(
                            "دستگاه را روی زمین قرار دهید",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.vazirmatn().fontFamily,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
            const Spacer(),
            Text(
              'Made in Iran',
              style: TextStyle(
                fontFamily: GoogleFonts.orbitron().fontFamily,
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
