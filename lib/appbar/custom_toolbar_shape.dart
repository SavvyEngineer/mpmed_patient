import 'package:flutter/material.dart';

class CustomToolbarShape extends CustomPainter {
  final Color lineColor;

  const CustomToolbarShape({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
Paint paint = Paint();

//First oval
Path path = Path();
Rect pathGradientRect = new Rect.fromCircle(
  center: new Offset(size.width / 4, 0),
  radius: size.width/1.4,
);

Gradient gradient = new LinearGradient(
  colors: <Color>[
    Color.fromRGBO(221, 221, 221, 1).withOpacity(1),
    Color.fromRGBO(245, 245, 245,1).withOpacity(1),
  ],
  stops: [
    0.3,
    1.0,
  ],
);

path.lineTo(-size.width / 1.4, 0);
path.quadraticBezierTo(
    size.width / 2, size.height * 2, size.width + size.width / 1.4, 0);

paint.color = Color(0xFFc4c4c4);
paint.shader = gradient.createShader(pathGradientRect);
paint.strokeWidth = 40;
path.close();

canvas.drawPath(path, paint);

//Second oval
Rect secondOvalRect = new Rect.fromPoints(
  Offset(-size.width / 2.5, -size.height),
  Offset(size.width * 1.4, size.height / 1.5),
);

gradient = new LinearGradient(
  colors: <Color>[
    Color.fromRGBO(225, 255, 255, 1).withOpacity(0.1),
    Color.fromRGBO(172, 172, 172, 1).withOpacity(0.2),
  ],
  stops: [
    0.0,
    1.0,
  ],
);
Paint secondOvalPaint = Paint()
  ..color = Color(0xFFdddddd)
  ..shader = gradient.createShader(secondOvalRect);

canvas.drawOval(secondOvalRect, secondOvalPaint);

//Third oval
Rect thirdOvalRect = new Rect.fromPoints(
  Offset(-size.width / 2.5, -size.height),
  Offset(size.width * 1.4, size.height / 2.7),
);

gradient = new LinearGradient(
  colors: <Color>[
    Color.fromRGBO(225, 255, 255, 1).withOpacity(0.05),
    Color.fromRGBO(147, 147, 147, 1).withOpacity(0.2),
  ],
  stops: [
    0.0,
    1.0,
  ],
);
Paint thirdOvalPaint = Paint()
  ..color = Color(0xFFf5f5f5)
  ..shader = gradient.createShader(thirdOvalRect);

canvas.drawOval(thirdOvalRect, thirdOvalPaint);

//Fourth oval
Rect fourthOvalRect = new Rect.fromPoints(
  Offset(-size.width / 2.4, -size.width/1.875),
  Offset(size.width / 1.34, size.height / 1.14),
);

gradient = new LinearGradient(
  colors: <Color>[
    Colors.white.withOpacity(0.9),
    Color.fromRGBO(147, 147, 147, 1).withOpacity(0.3),
  ],
  stops: [
    0.3,
    1.0,
  ],
);
Paint fourthOvalPaint = Paint()
  ..color = Color(0xFFf5f5f5)
  ..shader = gradient.createShader(fourthOvalRect);

  canvas.drawOval(fourthOvalRect, fourthOvalPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}