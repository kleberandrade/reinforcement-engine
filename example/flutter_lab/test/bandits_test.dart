// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reinforcement_lab/bandits_page.dart';

void main() {
  testWidgets('bandit simulation updates counts and resets when policy changes',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: BanditsPage()));
    await tester.tap(find.text('Experimentar +1.000'));
    for (var i = 0; i < 52; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(find.text('Decisões: 1000'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNWidgets(3));
    await tester.tap(find.byType(DropdownButton<bool>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Epsilon-greedy').last);
    await tester.pumpAndSettle();
    expect(find.text('Decisões: 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
