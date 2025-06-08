import "package:flutter/material.dart";

class CircularOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6);
    final clearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    canvas.drawRect(Offset.zero & size, paint);
    canvas.drawCircle(center, radius, clearPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
