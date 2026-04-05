# Example CLAUDE.md — Flutter/Dart Project

This example shows a CLAUDE.md for a Flutter mobile application using Riverpod for state management, GoRouter for navigation, and Dio for HTTP. It covers Flutter-specific conventions for widget structure, state management, and platform-aware development.

## The CLAUDE.md File

```markdown
# Project: Acme Mobile App

Flutter 3.24+ / Dart 3.5+ cross-platform mobile app (iOS + Android). Riverpod state management, GoRouter navigation, Dio HTTP client.

## Commands

- `flutter run` — run on connected device/emulator
- `flutter test` — run all tests
- `flutter test test/features/auth/login_test.dart` — run a single test file
- `flutter analyze` — static analysis (must pass with zero issues)
- `dart format .` — format all Dart files
- `flutter pub get` — install dependencies
- `flutter gen-l10n` — regenerate localization files
- `dart run build_runner build --delete-conflicting-outputs` — run code generation (Freezed, Riverpod)
- `flutter build apk --release` — build Android release
- `flutter build ios --release` — build iOS release

Run `dart format . && flutter analyze && flutter test` before committing.

## Architecture

Feature-first project structure:

- `lib/`
  - `app.dart` — MaterialApp setup, theme, router
  - `features/` — feature modules, each self-contained:
    - `auth/` — login, signup, password reset
      - `screens/` — full-screen widgets (LoginScreen, SignupScreen)
      - `widgets/` — feature-specific widgets
      - `providers/` — Riverpod providers for auth state
      - `models/` — auth-related data classes
      - `repositories/` — auth API calls
    - `home/`, `profile/`, `settings/` — same structure
  - `core/`
    - `router/` — GoRouter configuration and route definitions
    - `theme/` — app theme, colors, typography
    - `network/` — Dio client setup, interceptors, error handling
    - `storage/` — local storage (SharedPreferences, secure storage)
    - `models/` — shared data classes
    - `widgets/` — shared reusable widgets (AppButton, AppTextField, etc.)
    - `utils/` — pure utility functions
    - `l10n/` — localization files
- `test/` — mirrors lib/ structure
- `assets/` — images, fonts, JSON files

## Widget Conventions

- Stateless widgets for UI that depends only on input + providers
- Use `ConsumerWidget` or `ConsumerStatefulWidget` for widgets that read providers
- Extract widgets into separate files when they exceed ~80 lines
- Widget file naming: `login_screen.dart`, `order_card.dart`, `app_button.dart`
- One public widget per file — private helpers in the same file are fine

```dart
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: switch (authState) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError(:final error) => ErrorView(message: error.toString()),
        AsyncData(:final value) => _LoginForm(user: value),
      },
    );
  }
}
```

## State Management (Riverpod)

- Use `riverpod_generator` with `@riverpod` annotation for all providers
- Providers live in `providers/` directory within each feature
- Use `AsyncValue<T>` for all data that comes from network or database
- Use `ref.watch` in build methods, `ref.read` in callbacks
- Never store widget references in providers

```dart
@riverpod
class Auth extends _$Auth {
  @override
  FutureOr<User?> build() => ref.read(authRepositoryProvider).getCurrentUser();

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(email, password),
    );
  }
}
```

## Data Classes

- Use Freezed for all data classes (models, states, events)
- Run `dart run build_runner build --delete-conflicting-outputs` after modifying Freezed classes
- JSON serialization with `@JsonSerializable` via Freezed

```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    String? avatarUrl,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

## Navigation (GoRouter)

- All routes defined in `core/router/app_router.dart`
- Use typed route parameters — no magic strings for paths
- Redirect logic for auth guards in the router configuration
- Deep linking support for all public routes

## Testing

- Widget tests with `WidgetTester` for UI behavior
- Provider tests using `ProviderContainer` for isolated state testing
- Use `mocktail` for mocking (not mockito)
- Golden tests for critical UI components in `test/goldens/`
- Test naming: `test_[feature]_[scenario].dart`

## Networking (Dio)

- Base client configured in `core/network/api_client.dart`
- Interceptors for auth token injection, error mapping, and logging
- All API calls go through repository classes — never call Dio directly from widgets or providers
- Use typed response models — never work with raw `Map<String, dynamic>` outside repositories

## Git

- Conventional commits: feat:, fix:, chore:, refactor:
- Run code generation before committing if Freezed or Riverpod files changed
- Run `flutter analyze` — zero issues required

## Do NOT

- Do not use `setState` for data that could be in a provider
- Do not use `BuildContext` across async gaps — check `mounted` first
- Do not hardcode strings — use localization (`context.l10n.someKey`)
- Do not use `MediaQuery.of(context).size` directly — use `LayoutBuilder` or responsive breakpoints
- Do not edit generated files (`*.g.dart`, `*.freezed.dart`)
- Do not use `print()` — use the `logger` package
```

## Key Sections Explained

**Architecture** — The feature-first structure is critical for Flutter projects. Without it, Claude creates a flat structure that becomes unmanageable. Each feature being self-contained means Claude knows exactly where new code should go.

**Widget Conventions** — The `ConsumerWidget` pattern and the Dart 3 switch expression for `AsyncValue` give Claude a clear template for every screen widget.

**State Management** — Riverpod with code generation is specific enough that Claude needs explicit examples. The `ref.watch` vs. `ref.read` rule and the `AsyncValue.guard` pattern prevent subtle bugs.

**Do NOT** — The `BuildContext` across async gaps rule catches a real Flutter crash scenario. The generated file and `setState` rules prevent the most common Flutter mistakes Claude makes.

## See Also

- [CLAUDE.md Setup Guide](../guides/claude-md-guide.md) — how to structure your own CLAUDE.md
- [Minimal Example](./claude-md-minimal.md) — a simpler starting point
- [React Example](./claude-md-react.md) — for web frontend projects
- [Monorepo Example](./claude-md-monorepo.md) — for multi-package setups
