# Contributing to MoodTube

Thank you for your interest in MoodTube! This project is open source under the [MIT License](LICENSE).

## Getting started

1. Fork the repository and clone your fork.
2. Install [Flutter](https://docs.flutter.dev/get-started/install) (SDK `>=3.4.0`).
3. Install dependencies:

```bash
flutter pub get
```

4. Run the app (works without API keys via the internal catalog):

```bash
flutter run
```

5. Run tests before opening a pull request:

```bash
flutter analyze
flutter test
```

## Optional: YouTube API key

Live YouTube search requires a local `dart_defines.json` (not committed):

```bash
cp dart_defines.json.example dart_defines.json
# Add your restricted YouTube Data API key
flutter run --dart-define-from-file=dart_defines.json
```

## Pull requests

- Keep changes focused and explain the **why** in the PR description.
- Match existing code style and naming conventions.
- Update `CHANGELOG.md` for user-visible changes.
- Do **not** commit secrets (`dart_defines.json`, `android/key.properties`, keystores).

## Design guidelines

MoodTube uses the **Mood Spectrum** design system. See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) before changing UI.

## Questions

Open a [GitHub issue](https://github.com/atukunare/MoodTube/issues) for bugs or feature discussions.
