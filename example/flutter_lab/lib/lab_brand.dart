// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'lab_locale.dart';

/// Original mark: branching action paths converge on a diamond-shaped reward.
/// Coordinates match web/brand.svg; no external logo or font is used.
class LabBrand extends StatelessWidget {
  const LabBrand({super.key, this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) => Semantics(
      label: 'Reinforcement Engine Lab',
      image: true,
      child: ExcludeSemantics(
          child: Row(mainAxisSize: MainAxisSize.min, children: [
        const LabMark(),
        const SizedBox(width: 10),
        LabText(compact ? 'RL' : 'REINFORCEMENT / LAB',
            style: const TextStyle(
                color: Color(0xffd7def1),
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4)),
      ])));
}

class LabMark extends StatelessWidget {
  const LabMark({super.key, this.size = 36});
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: size, height: size, child: const CustomPaint(painter: _Mark()));
}

class _Mark extends CustomPainter {
  const _Mark();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 64, size.height / 64);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(0, 0, 64, 64), const Radius.circular(16)),
        Paint()..color = const Color(0xff17243a));
    final line = Paint()
      ..color = const Color(0xff71ead5)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
        Path()
          ..moveTo(13, 46)
          ..lineTo(29, 30)
          ..lineTo(47, 30)
          ..moveTo(13, 17)
          ..lineTo(29, 30),
        line);
    for (final p in [const Offset(13, 46), const Offset(13, 17)]) {
      canvas.drawCircle(p, 5, Paint()..color = const Color(0xff71ead5));
    }
    canvas.drawPath(
        Path()
          ..moveTo(48, 18)
          ..lineTo(60, 30)
          ..lineTo(48, 42)
          ..lineTo(36, 30)
          ..close(),
        Paint()..color = const Color(0xffb9a6ff));
    canvas.drawCircle(
        const Offset(29, 30), 4, Paint()..color = const Color(0xff0a1020));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _Mark oldDelegate) => false;
}
