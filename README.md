**English** | [Português (Brasil)](README.pt-BR.md)

# Stick2Planner

Offline-first visual planner for Android, Windows and Linux. Calendar, inbox and
Markdown notes stay on the device in SQLite; synchronization with your own server
is optional.

Source code: [github.com/MikeMequis1/Stick2Planner](https://github.com/MikeMequis1/Stick2Planner)

## Download

Latest APK: **[GitHub Releases](https://github.com/MikeMequis1/Stick2Planner/releases/latest)**.

- `Stick2Planner-*-arm64.apk` — recommended for most phones and tablets.
- `Stick2Planner-*-universal.apk` — fallback for other Android devices.
- `Stick2Planner-*-windows-x64.zip` — portable desktop build for Windows 10/11.
- `Stick2Planner-*-linux-x64.tar.gz` / `stick2planner_*_amd64.deb` — Linux
  desktop bundle and Debian package (AppImage when published).
- Android 7.0+ (`minSdk 24`). No Play Store account is required.

## Features

- **Calendar:** day, 4-day, week, 2-week and month views; multi-day events;
  drag, resize, reorder and quick create; anchored 4-day window; past days use a
  discreet muted tint.
- **Event recurrence:** daily, every N weeks, every N months or yearly;
  occurrences keep the event duration.
- **Event time:** optional start time, always visible on the event bar, without
  replacing event dates or internal timestamps.
- **Tags:** shared tags for events and tasks, with palette-based colors, tag
  management, multi-tag filtering in the Inbox and sync/backup support.
- **Feat:** positive-moment events use a pencil icon and a short contextual
  explanation. Completed events are marked done automatically after their end
  date; tasks can be completed from the details title icon.
- **Inbox:** search, status filters, tag filters, sorting and undated post-its.
- **Routines:** weekly day board with per-day progress, expandable cards,
  drag-and-drop activities, per-day completion (independent for each occurrence),
  occurrences that never predate the routine's creation, and server sync.
- **Notifications:** optional daily summary and per-item reminders (minutes
  before), scheduled locally on Android without internet.
- **Navigation:** adaptive single rail in landscape/desktop (Config/Sync at the
  bottom) and an evenly distributed bottom bar in portrait. Desktop adds
  keyboard shortcuts (`Ctrl+1…4`, `Ctrl+Tab`, `Ctrl+N`, `Ctrl+,`, `Ctrl+S`,
  `Ctrl+←/→`, `Alt+←/→`, `F1`) and immediate mouse dragging. Right-click opens
  context menus; checklist rows support Ctrl/Shift+click selection.
- **Notes:** Markdown rendering, checklists, line selection, snapshots and live
  links between notes and post-its.
- **Offline first:** all data is stored locally in SQLite. No account is
  required, and the app remains fully usable without a server.
- **Optional sync:** device pairing by QR code or text code, per-device tokens,
  manual/automatic sync, conflict copies and a local/remote data review before
  applying changes.
- **Backup:** versioned JSON export with checksum, transactional import and
  automatic snapshots.
- **Settings:** light/dark/system theme, six color palettes, Portuguese/English,
  animations, screen wake lock and gesture hints.
- **Admin web page:** live pairing QR, device rename/revoke and Portuguese/English
  UI, served by the optional sync server.

## Tech stack

- Flutter / Dart; Android SDK, Windows desktop C++ toolchain and Linux GTK 3.
- Drift + SQLite (schema v9, migrations v1 → v9). The same schema is used on
  Android, Windows and Linux; desktop data lives in each platform's application
  support directory.
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

# Desktop (run on each target OS)
pwsh -File scripts/build_windows.ps1      # Windows x64 + portable ZIP
bash scripts/build_linux.sh               # bundle + .deb (+ AppImage)
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
- [docs/DESKTOP.md](docs/DESKTOP.md) — Windows/Linux requirements, packaging,
  data locations and desktop limitations.
- [docs/SYNC.md](docs/SYNC.md) — connection, pairing and sync.
- [stick2server](https://github.com/MikeMequis1/stick2server) — sync server, API
  and deployment.
- [docs/validacao/](docs/validacao/) — device validation screenshots.

## Requirements

- Android 7.0 or newer; Windows 10/11 x64; or a Linux x64 desktop with GTK 3.
- Windows build: Visual Studio "Desktop development with C++" and Windows
  Developer Mode (Flutter plugin symlinks).
- Linux build: `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`,
  `libsecret-1-dev`, `dpkg-dev`; `appimagetool` for the optional AppImage.
- Optional sync server: Dart 3.13+ or Docker Compose, reachable over LAN, VPN or a
  reverse proxy with HTTPS.

The application identifier is `com.mikemequis1.planner`; changing it creates a
new app and does not migrate existing local data. Linux uses that identifier for
its data directory; Windows keeps the existing `Runner.rc` company metadata
(`com.example`) so current `%APPDATA%` data is not moved. See
[`docs/DESKTOP.md`](docs/DESKTOP.md).
