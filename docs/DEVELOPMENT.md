# Development

This guide covers environment setup, code generation, tests, local execution and
release packaging for Stick2Planner. The README is the project entry point; this
file is the canonical development reference.

## 1. Toolchain

| Tool | Version / requirement | Used for |
| --- | --- | --- |
| Flutter | 3.47.9 or newer (stable) | App, tests, builds |
| Dart | 3.13.7 or newer | Codegen, analysis, tests |
| Android SDK | Android 7.0+ target (`minSdk 24`) | APK builds |
| Visual Studio | "Desktop development with C++" workload (MSVC, CMake, Windows 10/11 SDK) | Windows builds |
| Windows Developer Mode | Enabled | Flutter plugin symlinks |
| Linux desktop packages | `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`, `libsecret-1-dev`, `libjsoncpp-dev`, `liblzma-dev`, `dpkg-dev` | Linux builds |
| `appimagetool` | Optional | AppImage output |
| Docker Compose / Dart 3.13+ | Optional | Running Stick2Server locally |

The server lives in a separate repository:
[github.com/MikeMequis1/stick2server](https://github.com/MikeMequis1/stick2server).

## 2. First setup

```bash
git clone https://github.com/MikeMequis1/Stick2Planner.git
cd Stick2Planner
flutter pub get
```

Generated Drift code is committed (`lib/data/db/app_database.g.dart`). Run
`build_runner` only after changing table definitions or annotations:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Do not edit generated `.g.dart` files by hand.

Check the toolchain and connected devices:

```bash
flutter doctor
flutter devices
```

## 3. Project layout

```text
lib/
├── main.dart
├── app/                 # composition, controllers, services, theme, strings
├── core/                # DateOnly, Clock, canonical JSON, platform support
├── data/                # Drift, repositories, backup, sync
├── domain/              # entities, calendar rules, use cases, interfaces
└── features/            # UI by section (planner, inbox, notes, routines, ...)
test/
├── app/                 # widget and controller tests
├── core/
├── data/                # database, migrations, backup, sync
├── domain/              # pure domain tests
└── helpers/
scripts/                 # Windows/Linux release packaging
packaging/               # Linux desktop entry/icon, Windows MSIX manifest
android/ windows/ linux/ # native runners
```

Layering rules are described in [`ARCHITECTURE.md`](ARCHITECTURE.md#3-layers-and-responsibilities).

## 4. Day-to-day commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # schema changes
flutter analyze
flutter test
flutter run
```

Useful variants:

```bash
flutter test test/domain/event_recurrence_test.dart
flutter test --plain-name "dois dispositivos convergem"
dart format lib test
```

`flutter test` currently runs the full suite (381 tests in this working tree,
including the active-day highlight, tap-window and tag-color regressions).
The two-device sync suite opens multiple `AppDatabase` instances in the same
process and may print Drift's multi-instance warning. It is expected there; a
failure is not.

## 5. Running locally

```bash
flutter run -d windows
flutter run -d linux
flutter run -d <android-device-id>
```

The app creates `planner.sqlite` on first open. To test sync manually, start
Stick2Server and pair the app from **Settings → Connection and synchronization**;
see [`SYNC.md`](SYNC.md).

## 6. Code generation and schema changes

A schema change is a cross-cutting change:

1. Update the table definitions in `lib/data/db/tables.dart`.
2. Increment `schemaVersion` in `lib/data/db/app_database.dart`.
3. Add a migration branch that preserves existing data.
4. Run `dart run build_runner build --delete-conflicting-outputs`.
5. Add or update a migration test in `test/data/db/migration_test.dart`.
6. Check backup compatibility in
   `lib/data/backup/backup_document.dart`
   (`supportedBackupSchemaVersions`).
7. Update [`ARCHITECTURE.md`](ARCHITECTURE.md) if the data model changed.
8. Run `flutter analyze` and `flutter test`.

Migrations must not reset the database or drop user content. The current
migration path covers v1 → v13, including legacy note conversion, tag tone
rewrites, routine tables and the routine-execution backfill.

## 7. Tests

The suite is organized by risk:

| Area | Examples |
| --- | --- |
| Domain | date arithmetic, recurrence expansion, validation, rollover, event bar layout, routine interval rules |
| Database | repositories, transactions/rollback, foreign keys, migrations from v1, in-memory connection |
| Backup | canonical JSON, checksum, version/schema acceptance, round-trip, snapshots |
| Sync | outbox coalescing, engine push/pull, conflicts, two-device convergence, routine merge, execution dedupe |
| UI | calendar modes, drag/resize, inbox, notes/editor, routines, settings, backup, About |
| Accessibility | semantic labels, 1.3× text scale |
| Load | 200 post-its rendered and navigated in the month view |
| Offline contract | internet permission exists only for optional sync; no foreground service or battery exemption request |

Commands:

```bash
flutter analyze
flutter test
```

A passing test is not manual device validation. See
[`QUALITY.md`](QUALITY.md) for what has actually been exercised on hardware.

## 8. Releases

### Android

```bash
flutter build apk --release --split-per-abi
flutter build apk --release                 # universal APK
```

Artifacts are written to `build/app/outputs/flutter-apk/`. The release build
currently uses the debug signing config from `android/app/build.gradle.kts`;
configure a real keystore before distributing outside GitHub Releases.

Versioning lives in two places and must stay synchronized:

- `pubspec.yaml` → `version: 0.10.4+22`
- `lib/core/app_info.dart` → `appVersionString = '0.10.4+22'`

### Windows

Prerequisites: Visual Studio C++ desktop workload and Developer Mode (or an
elevated terminal for symlinks).

```powershell
pwsh -File scripts/build_windows.ps1
```

This runs `flutter build windows --release`, copies the complete bundle and
creates `dist/windows/Stick2Planner-<version>-windows-x64.zip`. The script never
removes runtime DLLs to force a smaller archive.

Optional MSIX:

```powershell
pwsh -File scripts/package_windows_msix.ps1 `
  -Publisher "CN=Stick2Planner" `
  -CertificatePath ".\certs\stick2planner.pfx" `
  -CertificatePassword "<password>"
```

The MSIX is unsigned without a certificate. Installing an unsigned package with
`Add-AppxPackage -AllowUnsigned` is not supported by the current manifest
publisher; distribute the portable ZIP unless a trusted certificate is
available.

The portable ZIP needs the Microsoft Visual C++ runtime. It is normally present
on Windows 10/11; for clean machines, distribute the VC++ x64 redistributable.

### Linux

```bash
sudo apt-get install clang cmake ninja-build pkg-config \
  libgtk-3-dev libsecret-1-dev libjsoncpp-dev liblzma-dev \
  dpkg-dev appimagetool
bash scripts/build_linux.sh
```

The script produces:

- `dist/linux/Stick2Planner-<version>-linux-x64.tar.gz`;
- `dist/linux/stick2planner_<version>_amd64.deb`;
- `dist/linux/Stick2Planner-<version>-linux-x64.AppImage` when `appimagetool`
  exists.

`dpkg-dev` provides `dpkg-deb`; `appimagetool` may download its runtime on first
use. The script stages files under `$TMPDIR` because ownership/permissions cannot
be normalized reliably on WSL `drvfs` mounts.

Release artifacts are written under `dist/`, which is ignored by Git.

### Packaging layout

The Windows portable ZIP keeps the complete Flutter bundle together:

```text
stick2planner.exe
flutter_windows.dll
*.dll                     # plugin runtimes and native assets
data/icudtl.dat
data/flutter_assets/
data/app.so
README.txt
```

The optional MSIX uses `packaging/windows/msix/AppxManifest.xml` and writes to
`dist/windows/msix/`.

The Debian package installs:

```text
/opt/stick2planner/                 complete relocatable bundle
/usr/bin/stick2planner              symlink
/usr/share/applications/stick2planner.desktop
/usr/share/icons/hicolor/256x256/apps/stick2planner.png
```

The Linux tar.gz contains the same bundle with a top-level `README.txt`. The
AppImage is self-contained for the Flutter bundle but still uses the host GTK 3
and Secret Service libraries.

## 9. Data locations

| Platform | Application support directory | Database |
| --- | --- | --- |
| Android | app-private support directory | `planner.sqlite` |
| Windows | `%APPDATA%\com.example\Stick2Planner` | `planner.sqlite` |
| Linux | `$XDG_DATA_HOME/com.mikemequis1.planner` (usually `~/.local/share/com.mikemequis1.planner`) | `planner.sqlite` |

Automatic pre-import snapshots are written to a `backups/` subdirectory next to
the database. Export/import uses the native file picker on all platforms.

Windows keeps the legacy `com.example` company name from
`windows/runner/Runner.rc`. Changing it moves the data directory; migrate the
file deliberately instead. The app identifier `com.mikemequis1.planner` is used
by Android and Linux.

## 10. Scripts

| Script | Platform | Output |
| --- | --- | --- |
| `scripts/build_windows.ps1` | Windows PowerShell | Release folder + portable ZIP |
| `scripts/package_windows_msix.ps1` | Windows PowerShell | Signed or unsigned MSIX |
| `scripts/build_linux.sh` | Linux/WSL bash | tar.gz, `.deb`, optional AppImage |

All scripts fail with a clear message when their toolchain is missing. They are
packaging helpers, not a CI system; this repository has no automated release
pipeline.

## 11. Platform-specific notes

### Android

- `minSdk 24`, `applicationId com.mikemequis1.planner`.
- Permissions: `INTERNET`, `ACCESS_NETWORK_STATE`, `CAMERA` (optional), wake
  lock, notifications, boot receiver and exact-alarm permissions.
- Exact alarms are used when authorized; otherwise scheduling falls back to
  inexact delivery. `USE_EXACT_ALARM` is auto-granted on Android 13+ but Play
  policy restricts it to alarm/calendar-centric apps; review before publishing.
- The notification small icon is pinned by `res/raw/keep.xml` because resource
  shrinking would otherwise remove it and the plugin would throw
  `invalid_icon`.
- WorkManager periodic sync is best effort and may be postponed by the system.

### Windows

- The window opens at 1280×800 and has a 900×600 minimum (DPI-scaled).
- Right-click context menus, immediate mouse drag, `Ctrl+S`/`Ctrl+Enter`,
  `Esc`, `Ctrl+Tab`, `Alt+←/→` and checklist `Ctrl`/`Shift` selection are
  desktop-only.
- QR scanning and scheduled local notifications are not available; pair with the
  manual code.
- Developer Mode is required for plugin symlinks during the build.

### Linux

- GTK 3 is required at runtime; the `.deb` declares `libgtk-3-0`,
  `libsecret-1-0` and related dependencies.
- Secure token storage requires a running Secret Service provider (GNOME
  Keyring, KWallet, etc.). Pairing fails gracefully if it is unavailable.
- The AppImage bundles the Flutter app but still uses host GTK/Secret Service
  libraries.
- A real Linux GUI smoke test is still pending; build validation was done in WSL
  Ubuntu 26.04 with Flutter 3.47.9.

## 12. Common problems

| Symptom | Cause | Action |
| --- | --- | --- |
| Generated database classes are missing or stale | Table annotations changed | Run `dart run build_runner build --delete-conflicting-outputs` |
| `database is locked` | Two connections writing, especially WorkManager | Keep WAL/busy timeout; avoid long transactions |
| Windows build fails on symlinks | Developer Mode disabled | Enable it or use an elevated terminal |
| Linux pairing fails | No Secret Service/keyring | Start GNOME Keyring/KWallet and retry |
| QR option unavailable on desktop | `mobile_scanner` has no desktop implementation | Paste the pairing code |
| No desktop notifications | Scheduling is Android-only | Use the app; notifications are intentionally not scheduled on desktop |
| MSIX will not install | Unsigned package / publisher mismatch | Use the portable ZIP or sign with a trusted certificate |
| Android install blocked on HyperOS/MIUI | Installer restriction | Use `adb install -r -i com.android.vending` when appropriate |

## 13. Documentation maintenance

- README: entry point, platforms, download and quick start.
- `docs/ARCHITECTURE.md`: current architecture and decisions that still matter.
- `docs/DEVELOPMENT.md`: this file; setup, tests, builds and platform notes.
- `docs/SYNC.md`: server integration and diagnostics.
- `docs/QUALITY.md`: test results, manual validation and limitations.
- `SITE_CONTENT.md`: explanatory material for the future project page; not part
  of the repository's technical documentation.

Update the affected document in the same change. Do not add another file for a
topic that already has a canonical home.
