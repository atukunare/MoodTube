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
