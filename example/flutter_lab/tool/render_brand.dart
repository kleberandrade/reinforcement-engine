import 'dart:io';
import 'dart:ui' as ui;
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reinforcement_lab/lab_brand.dart';

/// Run explicitly with `flutter test tool/render_brand.dart` after changing the
/// native vector mark. These PNGs are original derivatives for manifest/iOS use.
void main() {
  testWidgets('render original brand assets', (tester) async {
    await tester.binding.setSurfaceSize(const Size(512, 512));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final size in [32, 192, 512]) {
      final key = GlobalKey();
      await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
              child: RepaintBoundary(
                  key: key, child: LabMark(size: size.toDouble())))));
      await tester.pump();
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final bytes = await tester.runAsync(() async {
        final image = await boundary.toImage();
        final data = (await image.toByteData(format: ui.ImageByteFormat.png))!;
        image.dispose();
        return data;
      });
      final paths = size == 32
          ? ['web/favicon.png']
          : ['web/icons/Icon-$size.png', 'web/icons/Icon-maskable-$size.png'];
      for (final path in paths) {
        File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
      }
    }
  });
}
