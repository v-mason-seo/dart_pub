# effective_dart

[![pub package](https://img.shields.io/pub/v/effective_dart.svg)](https://pub.dartlang.org/packages/effective_dart)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![style: effective dart][badge]][badge_link]

**Be consistent. Be brief.**

This package provides linter rules corresponding to the guidelines in
_[Effective Dart][]_.
You can easily see all enabled rules on the [Supported Lint Rules][] site.

**Note**: This package is inspired by the [pedantic][] package,
which contains lints internally used at Google.

## Using the Lints

To use the lints add a dev dependency in your `pubspec.yaml`:

```yaml
dev_dependencies:
  effective_dart: ^1.3.0
```

Then add an include in your `analysis_options.yaml` file:

```yaml
include: package:effective_dart/analysis_options.yaml
```

Or, if you using e.g. continuous builds,
they will likely fail whenever a new version of `package:effective_dart`
is released.
To avoid this, specify a version of `analysis_options.yaml`:

```yaml
include: package:effective_dart/analysis_options.1.3.0.yaml
```

## Consider Lints

Consider guidelines are practices that you might or might not want to follow,
depending on circumstances, precedents, and your own preference.

Following lints are not enforced by this package:

- [`prefer_expression_function_bodies`](https://dart-lang.github.io/linter/lints/prefer_expression_function_bodies.html)
- [`prefer_typing_uninitialized_variables`](https://dart-lang.github.io/linter/lints/prefer_typing_uninitialized_variables.html)
- [`use_function_type_syntax_for_parameters`](https://dart-lang.github.io/linter/lints/use_function_type_syntax_for_parameters.html)

## Unused Lints

Following lints have been considered and will not be enforced by this package:

- [`unnecessary_getters`](https://dart-lang.github.io/linter/lints/unnecessary_getters.html)
  has been [disabled](https://github.com/dart-lang/linter/issues/23)
- [`comment_references`](https://dart-lang.github.io/linter/lints/comment_references.html)
  is way too restrictive and comment references are handled in different ways
  in tools ([see this issue](https://github.com/dart-lang/sdk/issues/36974))

## Suppressing Lints

There are situations when you want to suppress a specific lint rule.
You can suppress lints alone in your project on multiple levels.
We will go through examples of how to suppress
[`public_member_api_docs`](https://dart-lang.github.io/linter/lints/public_member_api_docs.html)
lint rule.

**Note**: this package provides linter rules corresponding to the guidelines
in _[Effective Dart][]_.
That means we generally do not want to disable a rule in this package
if it works properly.
Yet, if you think some rule should be disabled by this package, open an issue.

### Line Level

To suppress a specific lint rule on a line of code,
you can put an `ignore` comment above the line of code:

```dart
// ignore: public_member_api_docs
class MyClass {}
```

### File Level

To suppress a specific lint rule on a file,
you can put an `ignore_for_file` comment to the file:

```dart
// ignore_for_file: public_member_api_docs

class MyClass {}

class MySecondClass {}
```

### Project Level

To suppress a specific lint rule on a project,
you can modify your `analysis_options.yaml` file:

```yaml
include: package:effective_dart/analysis_options.yaml

linter:
  rules:
    public_member_api_docs: false
```

## Badge

Show the world you're following _Effective Dart_ ???
[![style: effective dart][badge]][badge_link]

```md
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://pub.dev/packages/effective_dart)
```

## License

Licensed under the [MIT License](LICENSE).

[effective dart]: https://dart.dev/guides/language/effective-dart
[pedantic]: https://github.com/dart-lang/pedantic
[supported lint rules]: https://dart-lang.github.io/linter/lints
[badge]: https://img.shields.io/badge/style-effective_dart-40c4ff.svg
[badge_link]: https://pub.dev/packages/effective_dart
