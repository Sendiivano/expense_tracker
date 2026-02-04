# Changelog

## Unreleased

- Fixed theme types: replaced incorrect `CardTheme` usage with `CardThemeData` in `lib/main.dart`.
- Updated widget tests to use `ExpenseTrackerApp`, initialized `sqflite_common_ffi` for test environment, and made tests more robust.
- Added `sqflite_common_ffi` as a `dev_dependency` in `pubspec.yaml`.
- All unit and widget tests pass locally (`flutter test`).
