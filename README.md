# MoodTube

MoodTube is a Flutter Android MVP that helps users find long music playlists on YouTube by mood.

## Core Direction

- MoodTube does not extract YouTube audio.
- MoodTube does not download or cache YouTube videos.
- All playback happens through the official YouTube embedded player.
- The app does not cover the official player or its controls.
- Background playback is not included.
- If no API key is configured, the app works with mock data.
- The UI defaults to English, follows the device language for Korean users, and also supports manual language selection in Settings.

## UI Design Direction

Current UI style was refreshed on 2026-06-03. Use this as the baseline for future MoodTube screens and components.

- Overall look: premium, modern, soft neumorphism inspired by contemporary mobile design kits.
- Background: bright off-white / cool light gray surface with a very subtle grid texture. Avoid dark, heavy, earthy, or one-note beige themes.
- Surfaces: raised soft panels with white highlights and gentle gray shadows. Keep card corners at 8px.
- Palette: restrained neutral base with strong accents only where needed. Current accents are orange `#ff6b35`, blue `#2477ff`, violet `#8b5cf6`, mint `#2fd0ac`, graphite `#252b36`, and warm yellow `#ffb23f`.
- Typography: bold, clean hierarchy. Hero/page titles are large and heavy; compact cards use smaller, tight text. Letter spacing stays 0.
- Header pattern: use the `PremiumHeader` component for major screens, with a small glowing status dot and optional `SoftDial` visual.
- Cards and controls: use `softPanelDecoration`, `DesignTokens.softShadow`, and `DesignTokens.smallShadow` instead of ad hoc styling.
- Mood cards: use color accents from `DesignTokens.moodPalette`; keep the emoji inside a small raised square control.
- Inputs/buttons/navigation: should feel like physical soft controls from the reference image, not flat default Material widgets.
- Interactions: preserve existing app behavior for search, mood cards, saving playlists, playback, language settings, and API mode. Visual polish should not remove working states.
- Do not switch back to the older sage/cream organic palette unless explicitly requested.

Primary implementation file: `lib/main.dart`. The current design system lives in `DesignTokens`, `softPanelDecoration`, `SoftBackdrop`, `PremiumHeader`, `SoftDial`, and `StatusDot`.

## Run

From a Flutter-ready environment:

```bash
cd MoodTube
flutter pub get
flutter run
```

If this project was opened from a manual scaffold and Flutter/Gradle wrapper files are missing, regenerate Android platform files after installing Flutter:

```bash
cd MoodTube
flutter create --platforms=android .
flutter pub get
flutter run
```

## YouTube API Mode

Settings includes an API mode switch and API key field for YouTube Data API integration. If the key is empty or a request fails, the app falls back to mock data.

Android internet permission is included in `android/app/src/main/AndroidManifest.xml`.
