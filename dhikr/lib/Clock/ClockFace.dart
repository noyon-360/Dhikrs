import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dhikr/Controller/ClockPainter.dart';
import 'package:dhikr/Controller/Provider/TimerProvider.dart';
import 'package:dhikr/Helper/Color.dart';
import 'package:dhikr/Screens/ListOfDhikrs.dart';

class ClockFace extends StatefulWidget {
  const ClockFace({super.key});

  @override
  _ClockFaceState createState() => _ClockFaceState();
}

class _ClockFaceState extends State<ClockFace> {
  final List<int> numbers = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60];
  Offset lastPosition = Offset.zero;


  @override
  void initState() {
    super.initState();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    Offset center = const Offset(150, 150);
    Offset newPosition = details.localPosition;
    double newAngle =
        atan2(newPosition.dy - center.dy, newPosition.dx - center.dx);
    double lastAngle =
        atan2(lastPosition.dy - center.dy, lastPosition.dx - center.dx);
    double angleDiff = newAngle - lastAngle;

    context.read<TimerProvider>().updateAngle(angleDiff);
    lastPosition = newPosition;
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanStart: (details) {
        lastPosition = details.localPosition;
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                CustomPaint(
                  size: const Size(300, 300),
                  painter: ClockPainter(
                    numbers,
                    timerProvider.angleOffset,
                    timerProvider.selectedNumber,
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Stack(
                      children: List.generate(numbers.length, (index) {
                        double fixedPositionAngle = 0.0;

                        int selectedIndex =
                            numbers.indexOf(timerProvider.selectedNumber);
                        double selectedNumberAngle = (pi / 6) * selectedIndex -
                            timerProvider.angleOffset;

                        double calculatedAngleOffset =
                            fixedPositionAngle - selectedNumberAngle;
                        double angle = (pi / 6) * index +
                            pi / 2 +
                            timerProvider.angleOffset +
                            calculatedAngleOffset;
                        double radius = 120;
                        double x = 150 + radius * cos(angle);
                        double y = 150 + radius * sin(angle);

                        return Positioned(
                          left: x - 25,
                          top: y - 25,
                          width: 50,
                          height: 50,
                          child: GestureDetector(
                            onTap: () =>
                                timerProvider.selectNumber(numbers[index]),
                            child: Container(
                              color: Colors.transparent,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ClipPath(
                    clipper: TopHalfClipper(),
                    child: Container(
                      height: 150,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 80,
                            child: Image.asset("Assets/Images/Dhikr Logo.png"),
                          ),
                          const Text(
                            "Dhikr",
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "أَلَا بِذِكْرِ ٱللَّهِ تَطْمَئِنُّ ٱلْقُلُوبُ",
                            style: TextStyle(
                              fontFamily: 'ArabicFont',
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 142,
                  child: Container(
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black12,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: const Divider(
                      color: Colors.green,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          "${timerProvider.selectedNumber} Minute",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () => timerProvider.toggleTimer(context),
                          iconSize: 38,
                          icon: Icon(
                            timerProvider.isTimerRunning
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (Platform.isAndroid || Platform.isIOS)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      // color: Colors.green, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        // side: BorderSide(color: Colors.green),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Listofdhikrs()));
                    },
                    child: const Text(
                      "List of Dhikr's",
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600),
                    )),
              ),
          ],
        ),
      ),
    );
  }
}

class TopHalfClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
