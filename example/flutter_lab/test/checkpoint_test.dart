// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reinforcement_lab/checkpoint_page.dart';

void main() {
  testWidgets('exports, resets, restores, continues and rejects invalid JSON',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: CheckpointPage()));
    await tester.tap(find.text('Treinar +100'));
    for (var i = 0; i < 22; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(find.text('Episódios salvos e novos: 100'), findsOneWidget);
    await tester.tap(find.text('Exportar JSON'));
    await tester.pump();
    final saved =
        tester.widget<TextField>(find.byType(TextField)).controller!.text;
    expect(saved, contains('newRandomStream'));
    await tester.tap(find.text('Novo agente'));
    await tester.pump();
    expect(find.text('Episódios salvos e novos: 0'), findsOneWidget);
    await tester.tap(find.text('Importar JSON'));
    await tester.pump();
    expect(find.text('Episódios salvos e novos: 100'), findsOneWidget);
    expect(find.textContaining('Ao importar:'), findsOneWidget);
    await tester.tap(find.text('Treinar +100'));
    for (var i = 0; i < 22; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(find.text('Episódios salvos e novos: 200'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '{invalid');
    await tester.tap(find.text('Importar JSON'));
    await tester.pump();
    expect(find.text('JSON inválido ou incompatível. Agente preservado.'),
        findsOneWidget);
    expect(find.text('Episódios salvos e novos: 200'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
