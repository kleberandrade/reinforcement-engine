# Contributing

Keep the core pure Dart and free of IO, Flutter and runtime dependencies.
Follow the [source map](doc/architecture/structure.md) and
[class diagrams](doc/architecture/class_diagrams.md). Prefer small explicit
contracts and strategy composition. Keep UI scheduling outside the training loop.

Import only the public library in examples and tests. Pin existing public behavior
before structural refactors. Add meaningful tests for numerical updates, terminal
handling, action sampling, custom contracts and serialization. Validate configuration
at construction and numeric input at callback boundaries.

Document API changes in English and Portuguese. Keep README, guides and Unreleased
changelog notes synchronized. Use semantic commits and focused changes. Record
action, reason and validation in `doc/engineering_log.md`.

```sh
dart pub get
dart format --output=none --set-exit-if-changed lib test example
dart analyze --fatal-infos
dart test
dart run example/reinforcement_engine_example.dart
dart run example/custom_extensions.dart
dart run example/persistence.dart
dart compile js example/custom_extensions.dart -o /tmp/reinforcement_extensions.js
```

Validate the Flutter lab separately with `flutter pub get`,
`flutter analyze --fatal-infos`, `flutter test` and `flutter build web` inside
`example/flutter_lab`. The root analyzer excludes this nested package.
CI checks the core on Dart 3.3 and stable, and the lab on Flutter stable.
Never represent unsupported, configured-only or blocked checks as passing.

Before publication, verify package name, repository metadata, package contents,
version and hosted CI. Run `dart pub publish --dry-run`. Release and publishing
remain a separate workflow; do not tag just to test automation.
