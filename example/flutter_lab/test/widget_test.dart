// Keep compatibility with Flutter versions before the material_ui split.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reinforcement_lab/main.dart';

void main() {
  testWidgets('trains and executes learned policy', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1800));
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
  testWidgets('pauses, resumes and cancels training', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1100, 1500));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const LearningLab());
    await tester.tap(find.text('Treinar +500'));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.tap(find.text('Pausar'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Episódios: 10'), findsOneWidget);
    await tester.tap(find.text('Continuar'));
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.text('Episódios: 20'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Episódios: 20'), findsOneWidget);
    expect(find.textContaining('20 episódios registrados'), findsOneWidget);
    await tester.tap(find.text('Reiniciar'));
    await tester.pump();
    expect(find.text('Episódios: 0'), findsOneWidget);
    expect(find.textContaining('0 episódios registrados'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('pauses playback and reset cancels active work', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const LearningLab());
    await tester.tap(find.text('Treinar +500'));
    for (var i = 0; i < 55; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.tap(find.text('Executar'));
    await tester.pump(const Duration(milliseconds: 220));
    await tester.tap(find.text('Pausar'));
    await tester.pump();
    expect(find.textContaining('Pausado.'), findsOneWidget);
    await tester.tap(find.text('Continuar'));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 220));
    }
    expect(find.text('Objetivo alcançado em 8 movimentos!'), findsOneWidget);
    await tester.tap(find.text('Treinar +500'));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.tap(find.text('Reiniciar'));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Episódios: 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('compares Q-Learning and SARSA and clears incompatible runs',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const LearningLab());
    Future<void> train() async {
      await tester.tap(find.text('Treinar +500'));
      for (var i = 0; i < 55; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    }

    await train();
    final first = List<double>.of(
        tester.widget<RewardHistory>(find.byType(RewardHistory)).rewards);
    await tester.tap(find.byType(DropdownButton<LabAlgorithm>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SARSA').last);
    await tester.pumpAndSettle();
    await train();
    var chart = tester.widget<RewardHistory>(find.byType(RewardHistory));
    expect(chart.algorithm, 'SARSA');
    expect(chart.rewards, hasLength(500));
    expect(chart.comparison, first);
    expect(chart.comparisonAlgorithm, 'Q-Learning');
    await tester.tap(find.byType(DropdownButton<int>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Seed 7').last);
    await tester.pumpAndSettle();
    chart = tester.widget<RewardHistory>(find.byType(RewardHistory));
    expect(chart.rewards, isEmpty);
    expect(chart.comparison, isEmpty);
    await train();
    await tester.tap(find.text('Reiniciar'));
    await tester.pump();
    chart = tester.widget<RewardHistory>(find.byType(RewardHistory));
    expect(chart.rewards, isEmpty);
    expect(chart.comparison, isEmpty);
  });
  testWidgets(
      'trains both agents with one action and pauses cancels and resets both',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const LearningLab());
    await tester.tap(find.text('Treinar juntos'));
    await tester.pump(const Duration(milliseconds: 16));
    var chart = tester.widget<RewardHistory>(find.byType(RewardHistory));
    expect(chart.rewards, hasLength(10));
    expect(chart.comparison, hasLength(10));
    await tester.tap(find.text('Pausar'));
    await tester.pump(const Duration(seconds: 2));
    expect(tester.widget<RewardHistory>(find.byType(RewardHistory)).comparison,
        hasLength(10));
    await tester.tap(find.text('Continuar'));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.tap(find.text('Cancelar'));
    await tester.pump(const Duration(seconds: 2));
    chart = tester.widget<RewardHistory>(find.byType(RewardHistory));
    expect(chart.rewards, hasLength(20));
    expect(chart.comparison, hasLength(20));
    await tester.tap(find.text('Treinar juntos'));
    for (var i = 0; i < 55; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    chart = tester.widget<RewardHistory>(find.byType(RewardHistory));
    expect(chart.rewards, hasLength(500));
    expect(chart.comparison, hasLength(500));
    final first = List<double>.of(chart.rewards);
    final second = List<double>.of(chart.comparison);
    await tester.tap(find.text('Treinar juntos'));
    for (var i = 0; i < 55; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    chart = tester.widget<RewardHistory>(find.byType(RewardHistory));
    expect(chart.rewards, first);
    expect(chart.comparison, second);
    await tester.tap(find.text('Treinar +500'));
    for (var i = 0; i < 55; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    chart = tester.widget<RewardHistory>(find.byType(RewardHistory));
    expect(chart.rewards, hasLength(1000));
    expect(chart.comparison, second);
    await tester.tap(find.text('Reiniciar'));
    await tester.pump(const Duration(seconds: 2));
    chart = tester.widget<RewardHistory>(find.byType(RewardHistory));
    expect(chart.rewards, isEmpty);
    expect(chart.comparison, isEmpty);
    expect(tester.takeException(), isNull);
  });
  testWidgets('fits narrow screens with large text', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(
        home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2)),
            child: MazePage())));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('observation does not change the next training run',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    Future<void> trainBatch() async {
      await tester.tap(find.text('Treinar +500'));
      for (var i = 0; i < 55; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    }

    await tester.pumpWidget(const LearningLab(key: ValueKey('observed')));
    await trainBatch();
    await tester.tap(find.text('Avaliar ×50'));
    await tester.pump();
    await tester.tap(find.text('Executar'));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 220));
    }
    await trainBatch();
    final observed = List<double>.of(
        tester.widget<RewardHistory>(find.byType(RewardHistory)).rewards);
    await tester.pumpWidget(const LearningLab(key: ValueKey('baseline')));
    await trainBatch();
    await trainBatch();
    expect(tester.widget<RewardHistory>(find.byType(RewardHistory)).rewards,
        observed);
  });
  testWidgets('controls have labels and accessible target sizes',
      (tester) async {
    final semantics = tester.ensureSemantics();

    await tester.binding.setSurfaceSize(const Size(1000, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const LearningLab());
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await tester.tap(find.text('Treinar juntos'));
    await tester.pump(const Duration(milliseconds: 16));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await tester.tap(find.text('Reiniciar'));
    await tester.pump();
    semantics.dispose();
  });
  for (final name in [
    'SARSA',
    'Expected SARSA',
    'Double Q-Learning',
    'SARSA(λ)',
    'Watkins Q(λ)'
  ]) {
    testWidgets('trains and evaluates $name', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 1800));
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
    await tester.binding.setSurfaceSize(const Size(1000, 1800));
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
    await tester.binding.setSurfaceSize(const Size(1000, 1800));
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
