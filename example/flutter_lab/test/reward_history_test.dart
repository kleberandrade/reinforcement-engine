// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reinforcement_lab/reward_history.dart';
import 'package:reinforcement_lab/reward_history_data.dart';

void main() {
  test('moving mean includes partial initial windows and drops old samples',
      () {
    expect(movingAverage([-100, -50, 0, 3], 2), [-100, -75, -25, 1.5]);
    expect(movingAverage([-100, -50, 0], 50), [-100, -75, -50]);
    expect(movingAverage([], 25), isEmpty);
    expect(() => movingAverage([1], 0), throwsArgumentError);
  });

  testWidgets('keeps episode one and inspects both curves with a shared scale',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: RewardHistory(
      rewards: [for (var i = 0; i < 100; i++) i == 0 ? -200 : 3],
      algorithm: 'Q-Learning',
      comparison: const [-100, -50, 0],
      comparisonAlgorithm: 'SARSA',
    ))));
    expect(find.text('Episódios 1–100 · retorno por episódio'), findsOneWidget);
    final slider =
        tester.widget<Slider>(find.byKey(const ValueKey('inspect-episode')));
    slider.onChanged!(1);
    await tester.pump();
    expect(find.textContaining('Q-Learning: retorno −200.0 · média −200.0'),
        findsOneWidget);
    expect(find.textContaining('SARSA: retorno −100.0 · média −100.0'),
        findsOneWidget);
    slider.onChanged!(11);
    await tester.pump();
    expect(find.textContaining('Q-Learning: retorno 3.0 · média −15.5'),
        findsOneWidget);
    await tester.tap(find.byType(DropdownButton<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Média móvel: 10').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('Q-Learning: retorno 3.0 · média 3.0'),
        findsOneWidget);
    slider.onChanged!(100);
    await tester.pump();
    expect(find.textContaining('SARSA: sem episódio 100'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('populated comparison fits narrow screens at 200 percent text',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                child: SingleChildScrollView(
                    child: RewardHistory(
                        rewards: List.filled(500, 3),
                        algorithm: 'Q-Learning',
                        comparison: List.filled(250, -20),
                        comparisonAlgorithm: 'SARSA'))))));
    await tester.pumpAndSettle();
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
