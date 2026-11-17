import 'dart:io';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reinforcement_lab/main.dart';
import 'package:reinforcement_lab/lab_locale.dart';
import 'package:reinforcement_lab/lab_navigation.dart';
import 'package:reinforcement_lab/learning_content.dart';
import 'package:reinforcement_lab/translations.dart';
import 'package:reinforcement_lab/bandits_page.dart';
import 'package:reinforcement_lab/checkpoint_page.dart';
import 'package:reinforcement_lab/continuing_page.dart';

void main() {
  test('lesson references and version match checked-in source documents', () {
    for (final path in documentationPaths) {
      expect(File('../../$path').existsSync(), isTrue, reason: path);
      expect(
          File('../../${path.replaceFirst('.md', '.pt-BR.md')}').existsSync(),
          isTrue);
    }
    expect(File('../../pubspec.yaml').readAsStringSync(),
        contains('version: $learningSourceVersion'));
  });

  test('dynamic feedback and semantic labels translate without changing data',
      () {
    expect(translate('Episódios: 500'), 'Episodes: 500');
    expect(
        translate(
            'Avaliação: 100% de sucesso, 8.0 passos em média. Tabela e exploração preservadas.'),
        'Evaluation: 100% success, 8.0 mean steps. Values and exploration preserved.');
    expect(
        translate('Célula 0, agente, política →'), 'Cell 0, agent, policy →');
    expect(translate('Célula 7, parede'), 'Cell 7, wall');
    expect(
        translate(
            'Q-Learning + SARSA · 500 episódios cada.\nInicia uma comparação nova, desde o zero.'),
        'Q-Learning + SARSA · 500 episodes each.\nStarts a fresh comparison from zero.');
    expect(translate('Depois de continuar: 100% sucesso; 8.0 passos'),
        'After continuing: 100% success; 8.0 steps');
    expect(labExercises, hasLength(5));
    expect(
        labExercises.every((e) =>
            e.goalPt.isNotEmpty &&
            e.goalEn.isNotEmpty &&
            e.donePt.isNotEmpty &&
            e.doneEn.isNotEmpty),
        isTrue);
  });

  testWidgets(
      'language and educational navigation preserve a paused paired experiment',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const LearningLab());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Treinar juntos'));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.tap(find.text('Pausar'));
    await tester.pump();
    var chart = tester.widget<RewardHistory>(find.byType(RewardHistory));
    final q = List<double>.of(chart.rewards),
        sarsa = List<double>.of(chart.comparison);
    await tester.tap(find.byKey(const ValueKey('language-en')));
    await tester.pumpAndSettle();
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Paused. Resume or cancel the run.'), findsOneWidget);
    await tester.tap(find.text('Learn').first);
    await tester.pumpAndSettle();
    expect(find.text('From rewards to a policy.'), findsOneWidget);
    chart = tester
        .widget<RewardHistory>(find.byType(RewardHistory, skipOffstage: false));
    expect(chart.rewards, q);
    expect(chart.comparison, sarsa);
    await tester.tap(find.text('Laboratory').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resume'));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.tap(find.text('Pause'));
    await tester.pump();
    chart = tester.widget<RewardHistory>(find.byType(RewardHistory));
    expect(chart.rewards.length, q.length + 10);
    expect(chart.comparison.length, sarsa.length + 10);
    await tester.tap(find.text('Examples').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('preset-q-exploration')));
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.text('Seed 7'), findsOneWidget);
    expect(find.text('Initial epsilon: 0.20'), findsOneWidget);
    chart = tester.widget<RewardHistory>(find.byType(RewardHistory));
    expect(chart.rewards, hasLength(10));
    expect(chart.comparison, isEmpty);
    await tester.tap(find.text('Reset'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile menu supports keyboard and 200 percent text',
      (tester) async {
    final controller = LabController(initialLanguage: LabLanguage.pt);
    addTearDown(controller.dispose);
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(LabScope(
        controller: controller,
        child: MaterialApp(
            home: const MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(2)),
                child: Scaffold(appBar: LabTopBar(), body: SizedBox())))));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(controller.language, LabLanguage.en);
    await tester.tap(find.byKey(const ValueKey('mobile-navigation')));
    await tester.pumpAndSettle();
    expect(find.text('Learn'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(controller.section, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('auxiliary labs translate controls and feedback', (tester) async {
    final controller = LabController(initialLanguage: LabLanguage.en);
    addTearDown(controller.dispose);
    await tester.binding.setSurfaceSize(const Size(1000, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    Future<void> open(Widget page) async {
      await tester.pumpWidget(LabScope(
          controller: controller,
          child: MaterialApp(key: ValueKey(page.runtimeType), home: page)));
      await tester.pumpAndSettle();
    }

    await open(const BanditsPage());
    await tester.tap(find.text('Try +1,000'));
    for (var i = 0; i < 52; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(find.text('Decisions: 1000'), findsOneWidget);
    controller.setLanguage(LabLanguage.pt);
    await tester.pumpAndSettle();
    expect(find.text('Decisões: 1000'), findsOneWidget);
    controller.setLanguage(LabLanguage.en);
    await tester.pumpAndSettle();
    expect(find.text('Decisions: 1000'), findsOneWidget);
    await open(const CheckpointPage());
    await tester.enterText(find.byType(TextField), '{}');
    await tester.tap(find.text('Import JSON'));
    await tester.pump();
    expect(find.text('Invalid or incompatible JSON. Agent preserved.'),
        findsOneWidget);
    await open(const ContinuingPage());
    await tester.tap(find.text('Train +10,000'));
    for (var i = 0; i < 105; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.tap(find.text('Evaluate policy'));
    await tester.pump();
    expect(find.textContaining('Mean reward: 1.50 over 1,000 steps'),
        findsOneWidget);
    controller.setLanguage(LabLanguage.pt);
    await tester.pumpAndSettle();
    expect(find.text('Passos: 10000'), findsOneWidget);
    expect(find.textContaining('Recompensa média: 1.50'), findsOneWidget);
    controller.setLanguage(LabLanguage.en);
    await tester.pumpAndSettle();
    expect(find.textContaining('Mean reward: 1.50'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
