// Keep compatibility with Flutter versions before the material_ui split.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reinforcement_lab/main.dart';
import 'package:reinforcement_engine/reinforcement_engine.dart';

void main() {
  testWidgets('trains and executes learned policy', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const LearningLab());
    expect(find.text('Episódios: 0'), findsOneWidget);
    await tester.tap(find.text('Treinar +500'));
    for (var i = 0; i < 55; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(find.text('Episódios: 500'), findsOneWidget);
    await tester.tap(find.text('Executar'));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 220));
    }
    expect(find.text('Objetivo alcançado em 8 movimentos!'), findsOneWidget);
    await tester.tap(find.text('Reiniciar'));
    await tester.pump();
    expect(find.text('Episódios: 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('changing algorithm resets training', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const LearningLab());
    await tester.tap(find.byType(DropdownButton<LearningAlgorithm>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SARSA').last);
    await tester.pumpAndSettle();
    expect(find.text('Episódios: 0'), findsOneWidget);
    expect(find.text('SARSA'), findsOneWidget);
  });
}
