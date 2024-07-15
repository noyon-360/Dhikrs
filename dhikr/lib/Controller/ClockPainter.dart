import 'dart:math';

import 'package:flutter/material.dart';

class ClockPainter extends CustomPainter {
  final List<int> numbers;
  final double angleOffset;
  final int selectedNumber;

  ClockPainter(this.numbers, this.angleOffset, this.selectedNumber);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 138, 202, 138)
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    double radius = size.width / 2 - 30;

    double fixedPositionAngle = 0.0;

    int seletedIndex = numbers.indexOf(selectedNumber);
    double selectedNumberAngle = (pi / 6) * seletedIndex - angleOffset;

    double calculatedAngleOffset = fixedPositionAngle - selectedNumberAngle;

    for (int i = 0; i < numbers.length; i++) {
      double angle =
          (pi / 6) * i + pi / 2 + angleOffset + calculatedAngleOffset;
      double x = size.width / 2 + radius * cos(angle);
      double y = size.height / 2 + radius * sin(angle);

      // Create a rect around the text position to handle taps
      Rect rect = Rect.fromCenter(center: Offset(x, y), width: 50, height: 50);

      // Set the paint color based on the selected number
      paint.color = selectedNumber == numbers[i] ? Colors.green : Colors.grey;
      paint.style = PaintingStyle.fill;
      canvas.drawOval(rect, paint);

      // Draw the number text
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: numbers[i].toString(),
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
