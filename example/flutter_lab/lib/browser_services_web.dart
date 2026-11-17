import 'dart:js_interop';

@JS('window.localStorage.getItem')
external JSString? _read(JSString key);
@JS('window.localStorage.setItem')
external void _write(JSString key, JSString value);
@JS('window.open')
external JSAny? _open(JSString url, JSString target, JSString features);

const _key = 'reinforcement-lab.language.v1';
String? loadLanguage() {
  try {
    return _read(_key.toJS)?.toDart;
  } catch (_) {
    return null;
  }
}

bool saveLanguage(String language) {
  try {
    _write(_key.toJS, language.toJS);
    return true;
  } catch (_) {
    return false;
  }
}

bool openExternal(String url) {
  _open(url.toJS, '_blank'.toJS, 'noopener,noreferrer'.toJS);
  return true;
}

@JS('document.documentElement.lang')
external set _documentLanguage(JSString value);
void updateDocumentLanguage(String language) {
  _documentLanguage = (language == 'pt' ? 'pt-BR' : 'en').toJS;
}
