import 'language_flags.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'browser_services.dart';
import 'lab_brand.dart';
import 'lab_locale.dart';

const repositoryUrl = 'https://github.com/kleberandrade/reinforcement-engine';
const documentationLabels = [
  'Guia de aprendizado',
  'Algoritmos',
  'Avaliação',
  'Rastros de Watkins',
  'Bandits',
  'Checkpoints'
];
const documentationPaths = [
  'doc/learning_guide.md',
  'doc/algorithms.md',
  'doc/evaluation.md',
  'doc/watkins.md',
  'doc/bandits.md',
  'doc/checkpoints.md'
];

void showLabSection(BuildContext context, int section) {
  LabScope.of(context)?.showSection(section);
  Navigator.of(context).popUntil((route) => route.isFirst);
}

void openDocumentation(BuildContext context, [String? path]) {
  final url = path == null ? repositoryUrl : '$repositoryUrl/blob/main/$path';
  if (openExternal(url)) return;
  showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
              title: const LabText('Documentação / GitHub'),
              content: SelectableText(url),
              actions: [
                TextButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: url));
                      Navigator.pop(dialogContext);
                    },
                    child: const LabText('Copiar link'))
              ]));
}

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = LabScope.of(context);
    final selected = controller?.language ?? LabLanguage.pt;
    return Row(
        key: const ValueKey('language-selector'),
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final language in LabLanguage.values)
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Semantics(
                    selected: language == selected,
                    child: IconButton(
                      key: ValueKey('language-${language.name}'),
                      tooltip: language == LabLanguage.pt
                          ? 'Português (Brasil)'
                          : 'English (United Kingdom)',
                      style: IconButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          padding: const EdgeInsets.all(8),
                          shape: const CircleBorder(),
                          backgroundColor: language == selected
                              ? const Color(0xff243d43)
                              : Colors.transparent,
                          side: BorderSide(
                              color: language == selected
                                  ? const Color(0xff71ead5)
                                  : const Color(0xff41506b),
                              width: language == selected ? 2 : 1)),
                      onPressed: controller == null
                          ? null
                          : () => controller.setLanguage(language),
                      icon: CircularLanguageFlag(language: language),
                    ))),
        ]);
  }
}

class LabTopBar extends StatelessWidget implements PreferredSizeWidget {
  const LabTopBar({super.key, this.back = false});
  final bool back;
  @override
  Size get preferredSize => const Size.fromHeight(80);
  @override
  Widget build(BuildContext context) => Material(
      color: const Color(0xff0a1020),
      child: SafeArea(
          bottom: false,
          child: LayoutBuilder(builder: (context, bounds) {
            final full = bounds.maxWidth >= 1280 &&
                MediaQuery.textScalerOf(context).scale(14) <= 18;
            final current = LabScope.of(context)?.section ?? 0;
            const labels = ['Laboratório', 'Aprender', 'Exemplos'];
            void navigate(int index) => showLabSection(context, index);
            return Container(
                height: 80,
                padding: EdgeInsets.symmetric(
                    horizontal: bounds.maxWidth < 600 ? 12 : 28),
                decoration: const BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Color(0xff29354e)))),
                child: Row(children: [
                  if (back)
                    IconButton(
                        tooltip: tr(context, 'Voltar ao laboratório'),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded)),
                  LabBrand(compact: bounds.maxWidth < 700),
                  const Spacer(),
                  if (full) ...[
                    for (var i = 0; i < labels.length; i++)
                      Semantics(
                          selected: current == i,
                          child: TextButton(
                              onPressed: () => navigate(i),
                              style: TextButton.styleFrom(
                                  foregroundColor: current == i
                                      ? const Color(0xff71ead5)
                                      : const Color(0xffc4cde2)),
                              child: LabText(labels[i]))),
                    TextButton.icon(
                        onPressed: () => openDocumentation(context),
                        icon: const Icon(Icons.open_in_new, size: 15),
                        label: const LabText('GitHub')),
                    const SizedBox(width: 18),
                  ],
                  const LanguageSelector(),
                  if (!full)
                    PopupMenuButton<int>(
                        key: const ValueKey('mobile-navigation'),
                        tooltip: tr(context, 'Navegação'),
                        icon: const Icon(Icons.menu_rounded),
                        onSelected: (value) => value == 3
                            ? openDocumentation(context)
                            : navigate(value),
                        itemBuilder: (_) => [
                              for (var i = 0; i < labels.length; i++)
                                PopupMenuItem(
                                    value: i, child: LabText(labels[i])),
                              const PopupMenuItem(
                                  value: 3,
                                  child: LabText('Documentação / GitHub'))
                            ]),
                ]));
          })));
}
