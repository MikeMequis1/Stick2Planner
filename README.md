**English** | [Português (Brasil)](README.pt-BR.md)

# Stick2Planner

Offline-first visual planner for Android. Calendar, inbox and Markdown notes stay
on the device in SQLite; synchronization with your own server is optional.

Source code: [github.com/MikeMequis1/Stick2Planner](https://github.com/MikeMequis1/Stick2Planner)

## Download

Latest APK: **[GitHub Releases](https://github.com/MikeMequis1/Stick2Planner/releases/latest)**.

- `Stick2Planner-*-arm64.apk` — recommended for most phones and tablets.
- `Stick2Planner-*-universal.apk` — fallback for other Android devices.
- Android 7.0+ (`minSdk 24`). No Play Store account is required.

## Features

- **Calendar:** day, 4-day, week, 2-week and month views; multi-day events;
  drag, resize, reorder and quick create; anchored 4-day window.
- **Event recurrence:** daily, every N weeks, every N months or yearly;
  occurrences keep the event duration.
- **Inbox:** search, status filters, sorting and undated post-its.
- **Notes:** Markdown rendering, checklists, line selection, snapshots and live
  links between notes and post-its.
- **Offline first:** all data is stored locally in SQLite. No account is
  required, and the app remains fully usable without a server.
- **Optional sync:** device pairing by QR code or text code, per-device tokens,
  manual/automatic sync, conflict copies and a local/remote data review before
  applying changes.
- **Backup:** versioned JSON export with checksum, transactional import and
  automatic snapshots.
- **Settings:** light/dark/system theme, four color palettes, Portuguese/English,
  animations, screen wake lock and gesture hints.
- **Admin web page:** live pairing QR, device rename/revoke and Portuguese/English
  UI, served by the optional sync server.

## Tech stack

- Flutter / Dart, Android SDK.
- Drift + SQLite (schema v6, migrations v1 → v6).
- Optional sync server in Dart/shelf + SQLite, with prebuilt Docker images:
  [MikeMequis1/stick2server](https://github.com/MikeMequis1/stick2server).
- Secure device tokens stored with `flutter_secure_storage`.

## Main commands

```bash
flutter pub get
dart run build_runner build
flutter analyze
flutter test
flutter build apk --release --split-per-abi
flutter build apk --release   # universal APK
```

Sync server lives in the separate
**[stick2server](https://github.com/MikeMequis1/stick2server)** repository,
including Docker Compose and the `latest` image.

For server configuration, pairing and deployment details, see
[`docs/SYNC.md`](docs/SYNC.md) and the
[stick2server README](https://github.com/MikeMequis1/stick2server#readme).

## Documentation

- [docs/PROGRESS.md](docs/PROGRESS.md) — development history.
- [docs/DECISIONS.md](docs/DECISIONS.md) — architecture and technical decisions.
- [docs/QUALITY.md](docs/QUALITY.md) — validation matrix and limitations.
- [docs/SYNC.md](docs/SYNC.md) — connection, pairing and sync.
- [stick2server](https://github.com/MikeMequis1/stick2server) — sync server, API
  and deployment.
- [docs/validacao/](docs/validacao/) — device validation screenshots.

## Requirements

- Android 7.0 or newer.
- Optional sync server: Dart 3.13+ or Docker Compose, reachable over LAN, VPN or a
  reverse proxy with HTTPS.

The application identifier is `com.mikemequis1.planner`; changing it creates a
new app and does not migrate existing local data.
