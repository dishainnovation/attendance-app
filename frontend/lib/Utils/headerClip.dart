import 'package:flutter/material.dart';

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Layer 1

    Paint paintFill0 = Paint()
      ..color = const Color.fromARGB(255, 22, 139, 57)
      ..style = PaintingStyle.fill
      ..strokeWidth = size.width * 0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    Path path_0 = Path();
    path_0.moveTo(size.width * 0.0005556, size.height * -0.0100000);
    path_0.lineTo(size.width, size.height * -0.0057000);
    path_0.lineTo(size.width * 1.0005000, size.height * 1.0027000);
    path_0.quadraticBezierTo(size.width * 0.9995648, size.height * 0.7765500,
        size.width * 0.9539907, size.height * 0.7706000);
    path_0.cubicTo(
        size.width * 0.7341019,
        size.height * 0.7681000,
        size.width * 0.2663681,
        size.height * 0.7585000,
        size.width * 0.0464815,
        size.height * 0.7560000);
    path_0.quadraticBezierTo(size.width * 0.0016111, size.height * 0.7698500,
        size.width * 0.0005556, size.height * 1.0010000);

    canvas.drawPath(path_0, paintFill0);

    // Layer 1

    Paint paintStroke0 = Paint()
      ..color = const Color.fromARGB(255, 33, 150, 243)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    canvas.drawPath(path_0, paintStroke0);

    // Background shapes

    // Paint paintCircle = Paint()
    //   ..color = Colors.lightGreenAccent.withOpacity(0.1)
    //   ..style = PaintingStyle.fill;

    // canvas.drawCircle(
    //     Offset(size.width * 0.15, size.height * 0.25), 50, paintCircle);

    Paint paintCircle1 = Paint()
      ..color = Colors.green.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.2),
        size.height * 0.6, paintCircle1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
