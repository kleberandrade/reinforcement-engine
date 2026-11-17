// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'browser_services.dart';
import 'translations.dart';

enum LabLanguage { pt, en }

class LabController extends ChangeNotifier {
  LabController({LabLanguage? initialLanguage})
      : language = initialLanguage ??
            (loadLanguage() == 'en' ? LabLanguage.en : LabLanguage.pt) {
    updateDocumentLanguage(language.name);
  }
  LabLanguage language;
  int section = 0;
  void setLanguage(LabLanguage value) {
    if (language == value) return;
    language = value;
    updateDocumentLanguage(value.name);
    saveLanguage(value.name);
    notifyListeners();
  }

  void showSection(int value) {
    section = value;
    notifyListeners();
  }
}

class LabScope extends InheritedNotifier<LabController> {
  const LabScope(
      {super.key, required LabController controller, required super.child})
      : super(notifier: controller);
  static LabController? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LabScope>()?.notifier;
}

String tr(BuildContext context, String text, [String? english]) =>
    LabScope.of(context)?.language == LabLanguage.en
        ? english ?? translate(text)
        : text;

/// Translation is resolved at paint time, so stored feedback and counters remain
/// language independent and switching never reconstructs a learner or its RNG.
class LabText extends StatelessWidget {
  const LabText(this.data,
      {super.key,
      this.english,
      this.style,
      this.textAlign,
      this.softWrap,
      this.maxLines,
      this.overflow});
  final String data;
  final String? english;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool? softWrap;
  final int? maxLines;
  final TextOverflow? overflow;
  @override
  Widget build(BuildContext context) => Text(tr(context, data, english),
      style: style,
      textAlign: textAlign,
      softWrap: softWrap,
      maxLines: maxLines,
      overflow: overflow);
}
