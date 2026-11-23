**English** | [Português (Brasil)](README.pt-BR.md)

# Stick2Planner

Stick2Planner is an offline-first visual planner for Android, Windows and Linux.
Calendar, tasks, routines and Markdown notes live in a local SQLite database;
synchronization with a self-hosted server is optional.

Source code: [github.com/MikeMequis1/Stick2Planner](https://github.com/MikeMequis1/Stick2Planner)

## Download

Latest release: **[GitHub Releases](https://github.com/MikeMequis1/Stick2Planner/releases/latest)**

- `Stick2Planner-*-arm64.apk` — Android 7.0+ (`minSdk 24`); recommended for most
  phones and tablets.
- `Stick2Planner-*-universal.apk` — fallback for other Android devices.
- `Stick2Planner-*-windows-x64.zip` — portable Windows 10/11 x64 build. The
  optional MSIX in the same release is unsigned and must be signed before normal
  installation.
- Linux x64 builds are produced locally with `scripts/build_linux.sh`
  (tar.gz + `.deb`, AppImage when `appimagetool` is available). Linux artifacts
  are not published in the current release yet.

## What it does

- **Visual calendar:** day, 4-day and week modes in portrait; week, 2-week and
  month in landscape; multi-day events; drag, resize, reorder and quick
  creation; per-occurrence completion and series splitting when a recurring item
  moves.
- **Tasks and Inbox:** active/done/cancelled states, undated items, search,
  filters, sorting and shared tags.
- **Notes:** Markdown or checklists, rendered preview, line selection, snapshots
  and live links between notes and post-its.
- **Routines:** simple weekly checklists or complete cards with time blocks and
  one task per interval; per-day completion, reminders, execution history and a
  progress dashboard.
- **Local notifications:** daily summary and per-item/routine reminders on
  Android, scheduled without an internet connection.
- **Offline first:** no account required; the app remains fully usable without a
  server.
- **Optional sync:** pairing by QR code or text code, per-device tokens,
  manual/automatic synchronization, conflict copies and a local/remote review
  before replacing data.
- **Backup:** versioned JSON export with checksum, transactional import and a
  verified snapshot before each import.
- **Adaptive UI:** touch and mouse/keyboard layouts, six palettes, light/dark/
  system theme and Portuguese/English.

## Platforms

| Platform | Target | Notes |
| --- | --- | --- |
| Android | 7.0+ (`minSdk 24`) | APK; notifications, QR pairing and periodic sync use Android APIs |
| Windows | 10/11 x64 | Portable ZIP; desktop shortcuts and mouse interactions |
| Linux | x64 with GTK 3 | Bundle/`.deb`; QR pairing uses the manual code; secure tokens need Secret Service |

## Tech stack

- Flutter/Dart with an adaptive Material 3 interface.
- Drift + SQLite, schema v13, migrations from v1 onwards.
- Optional sync server in Dart/shelf + SQLite:
  [MikeMequis1/stick2server](https://github.com/MikeMequis1/stick2server).
- Device tokens stored with `flutter_secure_storage`.

## Quick start

```bash
flutter pub get
dart run build_runner build        # only after schema/table changes
flutter analyze
flutter test
flutter run
```

Release builds:

```bash
flutter build apk --release --split-per-abi
pwsh -File scripts/build_windows.ps1     # Windows
bash scripts/build_linux.sh              # Linux
```

Full requirements, packaging details and platform caveats are in
[`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md).

## Documentation

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — layers, data model, local
  persistence, offline-first design and sync architecture.
- [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md) — environment, code generation,
  tests, builds, scripts and platform-specific setup.
- [`docs/SYNC.md`](docs/SYNC.md) — Stick2Server integration, pairing,
  synchronization, conflicts and diagnostics.
- [`docs/QUALITY.md`](docs/QUALITY.md) — test strategy, current results, manual
  validation and known limitations.
- [Stick2Server](https://github.com/MikeMequis1/stick2server) — server setup,
  API, Docker images and deployment.

## Data and privacy

All planner data is stored locally in `planner.sqlite` inside the platform's
application support directory. Sync tokens are kept in secure storage and are
never written to backups, logs or the database. The app requests internet
access only for optional synchronization.

Application identifier: `com.mikemequis1.planner`. Linux uses it for the data
directory; Windows keeps the legacy `com.example` company metadata so existing
`%APPDATA%` data is not moved. See
[`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md#9-data-locations).
