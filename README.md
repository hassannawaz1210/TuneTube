# TuneTube

A Flutter music player with a dark discovery screen, mood shortcuts, YouTube search, a saved-track library, and a full-screen audio player. Saved tracks store metadata locally; playback still requires internet access.

YouTube access uses `youtube_explode_dart`, an unofficial extractor; no YouTube Data API key is required. Search and playback availability depend on YouTube, your network, and each video's restrictions.

## Build an Android APK

Install [Flutter 3.35.7](https://docs.flutter.dev/install), JDK 17, and the Android SDK with command-line tools. Run `flutter doctor` and accept the Android SDK licenses with `flutter doctor --android-licenses`. The first build needs internet access to download dependencies and Android build components.

```bash
bash scripts/build-apk.sh
```

The script resolves dependencies, runs analysis and tests, then creates `dist/TuneTube.apk`. This is a universal APK built in release mode using the project's debug signing key, suitable for installing directly for testing. Configure a private release signing key before store distribution. Builds on different machines can have different debug signing keys and may require uninstalling an earlier test build, which removes its local playlists.

Alternatively, after these changes are pushed to GitHub, run **Actions → Build Android APK → Run workflow**. A successful run provides the **TuneTube-APK** downloadable artifact. The workflow uses Flutter 3.35.7 and Java 17; Gradle and Android plugin versions match that Flutter release's template.

Dependency resolution is not locked yet. Commit the generated `pubspec.lock` after a successful dependency resolution to preserve exact package versions. The Hive adapter is checked in, so builds do not require code generation. If you change its model schema, regenerate the adapter with compatible `hive_generator` and `build_runner` development dependencies, and preserve the existing type and field IDs.

## Live YouTube check

After `flutter pub get`, run `dart run tool/youtube_probe.dart` to check search, direct video lookup, stream extraction, and delivery of audio bytes. Optionally pass a public YouTube video URL as its argument.

An APK build does not prove YouTube extraction works from your connection. Open the app, search for a public track, play it, seek, and check background playback. Restricted or removed videos can fail even when other tracks work.

## Verification status

The refresh has not yet been compiled or run on a device. The development environment had no Flutter or Android SDK, and SDK downloads were blocked by network access. The APK workflow is prepared but has not been executed; there is no generated APK or confirmed live YouTube playback result yet.
