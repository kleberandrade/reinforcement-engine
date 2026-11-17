import 'dart:math';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'reward_history_data.dart';

String _number(double value) => value.toStringAsFixed(1).replaceFirst('-', '−');

class RewardHistory extends StatefulWidget {
  const RewardHistory(
      {super.key,
      required this.rewards,
      this.algorithm = 'Q-Learning',
      this.comparison = const [],
      this.comparisonAlgorithm = 'SARSA'});
  final List<double> rewards;
  final String algorithm;
  final List<double> comparison;
  final String comparisonAlgorithm;

  @override
  State<RewardHistory> createState() => _RewardHistoryState();
}

class _RewardHistoryState extends State<RewardHistory> {
  int window = 25;
  int? inspected;
  bool showRaw = true;

  @override
  void didUpdateWidget(RewardHistory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.algorithm != oldWidget.algorithm ||
        widget.rewards.length < oldWidget.rewards.length) {
      inspected = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final curves = [
      _Curve(widget.algorithm, widget.rewards, window),
      if (widget.comparison.isNotEmpty)
        _Curve(widget.comparisonAlgorithm, widget.comparison, window),
    ];
    final count = curves.map((c) => c.rewards.length).reduce(max);
    final episode = (inspected ?? count).clamp(1, max(1, count)).toInt();
    final theme = Theme.of(context);
    final axisFontSize = MediaQuery.textScalerOf(context).scale(14);
    final labelWidth = axisFontSize * 3.5;
    final chartHeight = max(220.0, axisFontSize * 8);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Curvas de aprendizado', style: theme.textTheme.titleLarge),
      Text(
          '${widget.rewards.length} episódios registrados · histórico completo'),
      const Text(
          'Use Treinar juntos para comparar Q-Learning e SARSA com a mesma configuração. '
          'Seed, epsilon e Reiniciar limpam as curvas.'),
      const SizedBox(height: 12),
      Wrap(
          spacing: 20,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
                width: 240,
                child: DropdownButton<int>(
                    isExpanded: true,
                    itemHeight: null,
                    value: window,
                    onChanged: (value) => setState(() => window = value!),
                    items: [10, 25, 50, 100]
                        .map((v) => DropdownMenuItem(
                            value: v,
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Text('Média móvel: $v'))))
                        .toList())),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Semantics(
                  label: 'Mostrar retornos por episódio',
                  child: Switch(
                      value: showRaw,
                      onChanged: (value) => setState(() => showRaw = value))),
              const Flexible(child: Text('Retornos por episódio')),
            ]),
          ]),
      const Text('Média dos últimos N episódios, incluindo o atual. '
          'No início, usa apenas os episódios disponíveis.'),
      const SizedBox(height: 12),
      Wrap(spacing: 20, runSpacing: 8, children: [
        for (final curve in curves)
          Text(
              '${curve.label == "SARSA" ? "┄" : "━"} ${curve.label} (${curve.label == widget.algorithm ? 'atual' : 'comparação'}) · ${curve.rewards.length} episódios',
              style: TextStyle(color: curve.color, fontWeight: FontWeight.w600))
      ]),
      const SizedBox(height: 12),
      if (count == 0)
        const SizedBox(
            height: 180,
            child: Center(
                child: Text('Treine para ver a evolução desde o episódio 1.')))
      else ...[
        Text('Episódios 1–$count · retorno por episódio'),
        const SizedBox(height: 8),
        Semantics(
            label: 'Gráfico de recompensas desde o episódio 1 até $count. '
                'Escala comum de menos 200 a mais 3. Use o seletor de episódio para consultar os valores.',
            child: ExcludeSemantics(
                child: SizedBox(
                    height: chartHeight,
                    child: Row(children: [
                      SizedBox(
                          width: labelWidth,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('+3'),
                                Text('−50',
                                    softWrap: false,
                                    style: TextStyle(fontSize: 14)),
                                Text('−100',
                                    softWrap: false,
                                    style: TextStyle(fontSize: 14)),
                                Text('−150',
                                    softWrap: false,
                                    style: TextStyle(fontSize: 14)),
                                Text('−200',
                                    softWrap: false,
                                    style: TextStyle(fontSize: 14))
                              ])),
                      const SizedBox(width: 8),
                      Expanded(
                          child: CustomPaint(
                              size: Size.infinite,
                              painter: _RewardPainter(
                                  curves, count, episode, showRaw))),
                    ])))),
        Padding(
            padding: EdgeInsets.only(left: labelWidth + 8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('1'),
                  if (count > 2) Text('${(count + 1) ~/ 2}'),
                  if (count > 1) Text('$count')
                ])),
        const Text('Linhas fortes: média móvel · linhas suaves: retorno bruto. '
            'SARSA tracejada; Q-Learning contínua. Maior é melhor (máximo +3).'),
        if (count > 1)
          Slider(
              key: const ValueKey('inspect-episode'),
              min: 1,
              max: count.toDouble(),
              divisions: count - 1,
              value: episode.toDouble(),
              label: 'Episódio $episode',
              semanticFormatterCallback: (value) =>
                  'Inspecionar episódio ${value.round()}',
              onChanged: (value) => setState(() => inspected = value.round())),
        Semantics(
            liveRegion: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Episódio $episode', style: theme.textTheme.titleSmall),
                for (final curve in curves)
                  Text(episode > curve.rewards.length
                      ? '${curve.label}: sem episódio $episode'
                      : '${curve.label}: retorno ${_number(curve.rewards[episode - 1])} · média ${_number(curve.means[episode - 1])}')
              ],
            )),
      ],
      const SizedBox(height: 8),
      const Text(
          'Uma execução por algoritmo; mesma seed não significa as mesmas ações. '
          'Este gráfico mostra treino com exploração, não avaliação da política.'),
    ]);
  }
}

class _Curve {
  _Curve(this.label, List<double> rewards, int window)
      : rewards = List.unmodifiable(rewards),
        means = movingAverage(rewards, window);
  final String label;
  final List<double> rewards, means;
  bool get dashed => label == 'SARSA';
  Color get color => dashed ? const Color(0xff71ead5) : const Color(0xffc2b6ff);
}

class _RewardPainter extends CustomPainter {
  _RewardPainter(this.curves, this.count, this.episode, this.showRaw);
  final List<_Curve> curves;
  final int count, episode;
  final bool showRaw;

  Offset point(int index, double value, Size size) => Offset(
      count <= 1 ? 0 : index / (count - 1) * size.width,
      (3 - value) / 203 * size.height);

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xff414657)
      ..strokeWidth = 1;
    for (final value in [3.0, -50.0, -100.0, -150.0, -200.0]) {
      final y = point(0, value, size).dy;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    canvas.drawLine(Offset.zero, Offset(0, size.height), grid);
    final x = point(episode - 1, 3, size).dx;
    canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()
          ..color = const Color(0xff8992aa)
          ..strokeWidth = 1);
    for (final curve in curves) {
      if (showRaw) {
        drawCurve(canvas, size, curve.rewards,
            curve.color.withValues(alpha: .28), false, 1);
      }
      drawCurve(canvas, size, curve.means, curve.color, curve.dashed, 2.5);
      if (episode <= curve.means.length) {
        canvas.drawCircle(point(episode - 1, curve.means[episode - 1], size), 4,
            Paint()..color = curve.color);
      }
    }
  }

  void drawCurve(Canvas canvas, Size size, List<double> values, Color color,
      bool dashed, double width) {
    if (values.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(0, point(0, values.first, size).dy);
    for (var i = 1; i < values.length; i++) {
      final p = point(i, values[i], size);
      path.lineTo(p.dx, p.dy);
    }
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    if (values.length == 1) {
      canvas.drawCircle(
          point(0, values.first, size), 3, Paint()..color = color);
    } else if (dashed) {
      for (final metric in path.computeMetrics()) {
        for (var distance = 0.0; distance < metric.length; distance += 11) {
          canvas.drawPath(
              metric.extractPath(distance, min(distance + 7, metric.length)),
              paint);
        }
      }
    } else {
      canvas.drawPath(path, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RewardPainter oldDelegate) => true;
}
