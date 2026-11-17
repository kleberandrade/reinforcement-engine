// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'lab_locale.dart';

/// Local geometric flag renditions, drawn in the project's MIT-licensed source.
/// Circular clipping is part of the asset, not a square emoji or runtime image.
class CircularLanguageFlag extends StatelessWidget {
  const CircularLanguageFlag({super.key, required this.language});
  final LabLanguage language;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
      child: SizedBox(
          width: 28, height: 28, child: CustomPaint(painter: _Flag(language))));
}

class _Flag extends CustomPainter {
  const _Flag(this.language);
  final LabLanguage language;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipPath(Path()..addOval(Offset.zero & size));
    canvas.scale(size.width, size.height);
    if (language == LabLanguage.pt) {
      canvas.drawRect(const Rect.fromLTWH(0, 0, 1, 1),
          Paint()..color = const Color(0xff009b3a));
      canvas.drawPath(
          Path()
            ..moveTo(.5, .12)
            ..lineTo(.94, .5)
            ..lineTo(.5, .88)
            ..lineTo(.06, .5)
            ..close(),
          Paint()..color = const Color(0xffffdf00));
      canvas.drawCircle(
          const Offset(.5, .5), .22, Paint()..color = const Color(0xff002776));
      canvas.drawPath(
          Path()
            ..moveTo(.30, .45)
            ..quadraticBezierTo(.51, .42, .70, .56),
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = .05);
    } else {
      canvas.drawRect(const Rect.fromLTWH(0, 0, 1, 1),
          Paint()..color = const Color(0xff012169));
      final diagonals = Path()
        ..moveTo(0, 0)
        ..lineTo(1, 1)
        ..moveTo(1, 0)
        ..lineTo(0, 1);
      canvas.drawPath(
          diagonals,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = .18);
      canvas.drawPath(
          diagonals,
          Paint()
            ..color = const Color(0xffc8102e)
            ..style = PaintingStyle.stroke
            ..strokeWidth = .07);
      canvas.drawRect(
          const Rect.fromLTWH(.34, 0, .32, 1), Paint()..color = Colors.white);
      canvas.drawRect(
          const Rect.fromLTWH(0, .34, 1, .32), Paint()..color = Colors.white);
      canvas.drawRect(const Rect.fromLTWH(.41, 0, .18, 1),
          Paint()..color = const Color(0xffc8102e));
      canvas.drawRect(const Rect.fromLTWH(0, .41, 1, .18),
          Paint()..color = const Color(0xffc8102e));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _Flag oldDelegate) =>
      oldDelegate.language != language;
}
