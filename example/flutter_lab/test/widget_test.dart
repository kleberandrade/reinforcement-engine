// Keep compatibility with Flutter versions before the material_ui split.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reinforcement_lab/main.dart';

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
    await tester.tap(find.text('Avaliar ×50'));
    await tester.pump();
    expect(find.textContaining('100% de sucesso, 8.0 passos'), findsOneWidget);
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
  for (final name in [
    'Expected SARSA',
    'Double Q-Learning',
    'SARSA(λ)',
    'Watkins Q(λ)'
  ]) {
    testWidgets('trains and evaluates $name', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const LearningLab());
      await tester.tap(find.byType(DropdownButton<LabAlgorithm>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(name).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Treinar +500'));
      for (var i = 0; i < 55; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.tap(find.text('Avaliar ×50'));
      await tester.pump();
      expect(
          find.textContaining('100% de sucesso, 8.0 passos'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('continuing task learns the maintenance cycle', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const LearningLab());
    await tester.tap(find.text('Tarefa contínua'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Treinar +10.000'));
    for (var i = 0; i < 105; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.tap(find.text('Avaliar política'));
    await tester.pump();
    expect(find.textContaining('Recompensa média: 1.50'), findsOneWidget);
    await tester.tap(find.text('Reiniciar'));
    await tester.pump();
    expect(find.text('Passos: 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('changing algorithm resets training', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const LearningLab());
    await tester.tap(find.byType(DropdownButton<LabAlgorithm>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SARSA').last);
    await tester.pumpAndSettle();
    expect(find.text('Episódios: 0'), findsOneWidget);
    expect(find.text('SARSA'), findsOneWidget);
  });
}
