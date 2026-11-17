import 'lab_locale.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:reinforcement_engine/reinforcement_engine.dart';

const labMuted = Color(0xffa8b2c9);
const labCyan = Color(0xff71ead5);

class LabPanel extends StatelessWidget {
  const LabPanel({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Semantics(
      container: true,
      explicitChildNodes: true,
      child: Container(
          padding:
              EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 18 : 24),
          decoration: BoxDecoration(
              color: const Color(0xff131c30),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xff29354e))),
          child: child));
}

class LabHeading extends StatelessWidget {
  const LabHeading(this.step, this.title, this.subtitle, {super.key});
  final String step, title, subtitle;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LabText(step,
            style: const TextStyle(
                color: labCyan,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2)),
        const SizedBox(height: 8),
        LabText(title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        LabText(subtitle, style: const TextStyle(color: labMuted)),
        const SizedBox(height: 20),
      ]);
}

class LabBadge extends StatelessWidget {
  const LabBadge(this.label, {super.key, this.color = labCyan});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          border: Border.all(color: color.withValues(alpha: .25)),
          borderRadius: BorderRadius.circular(30)),
      child: LabText(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)));
}

class LabMetric extends StatelessWidget {
  const LabMetric(this.label,
      {super.key, required this.value, this.color = Colors.white});
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xff0d1526),
          borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LabText(label, style: const TextStyle(color: labMuted, fontSize: 12)),
        const SizedBox(height: 6),
        LabText(value,
            style: TextStyle(
                color: color, fontSize: 19, fontWeight: FontWeight.w700)),
      ]));
}

class MazeGrid extends StatelessWidget {
  const MazeGrid(
      {super.key,
      required this.world,
      required this.position,
      required this.visited,
      required this.trained,
      required this.policyAt});
  final GridWorld world;
  final int position;
  final Set<int> visited;
  final bool trained;
  final String Function(int) policyAt;

  @override
  Widget build(BuildContext context) => AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: world.width * world.height,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: world.width,
              crossAxisSpacing: 7,
              mainAxisSpacing: 7),
          itemBuilder: (context, cell) {
            final wall = world.walls.contains(cell),
                here = position == cell,
                goal = cell == world.goal;
            final color = here
                ? const Color(0xff8875ff)
                : goal
                    ? const Color(0xff124f4b)
                    : wall
                        ? const Color(0xff2e384d)
                        : visited.contains(cell)
                            ? const Color(0xff302b59)
                            : const Color(0xff1c2940);
            return Semantics(
                label: tr(
                    context,
                    'Célula $cell, ${wall ? "parede" : goal ? "objetivo" : here ? "agente" : "livre"}'
                    '${!wall && !goal && trained ? ", política ${policyAt(cell)}" : ""}'),
                child: ExcludeSemantics(
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: here
                                    ? const Color(0xffc2b6ff)
                                    : goal
                                        ? labCyan.withValues(alpha: .4)
                                        : const Color(0xff30405b))),
                        child: Center(
                            child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: here
                                      ? const Icon(Icons.smart_toy_outlined,
                                          color: Colors.white, size: 28)
                                      : goal
                                          ? const Icon(Icons.flag_rounded,
                                              color: labCyan, size: 28)
                                          : wall
                                              ? const Icon(Icons.block_rounded,
                                                  color: labMuted, size: 24)
                                              : LabText(
                                                  trained
                                                      ? policyAt(cell)
                                                      : '$cell',
                                                  style: TextStyle(
                                                      fontSize:
                                                          trained ? 23 : 14,
                                                      color: trained
                                                          ? const Color(
                                                              0xffdbe4ff)
                                                          : labMuted)),
                                ))))));
          }));
}
