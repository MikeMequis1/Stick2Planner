# Desktop: Windows and Linux

Stick2Planner keeps the same Flutter UI, controllers, Drift/SQLite schema and
offline-first behaviour on Android, Windows and Linux. Desktop support is an
additional target, not a rewrite.

## Supported platforms

| Platform | Target | Status |
| --- | --- | --- |
| Android | 7.0+ (`minSdk 24`), ARM64/x64 | Preserved; existing APK flow unchanged |
| Windows | 10/11 x64 | Supported; portable ZIP and optional MSIX |
| Linux | x64, GTK 3 desktop | Supported; bundle, `.deb` and optional AppImage |

The database schema remains **v9**. No table, column or migration was changed
for desktop. The existing `planner.sqlite` file is opened by the same drift
code on every platform.

## Where data lives

The application always uses `getApplicationSupportDirectory()` from
`path_provider`; nothing is written next to the executable.

| Platform | Typical application data directory | Database |
| --- | --- | --- |
| Android | app-private support directory | `planner.sqlite` |
| Windows | `%APPDATA%\com.example\Stick2Planner` | `planner.sqlite` |
| Linux | `$XDG_DATA_HOME/com.mikemequis1.planner` (usually `~/.local/share/com.mikemequis1.planner`) | `planner.sqlite` |

The Windows company name (`com.example`) comes from the existing
`windows/runner/Runner.rc`. It was intentionally kept so a previously created
Windows data directory is not moved or overwritten. The database file name and
schema are unchanged, so an Android database can also be restored from a JSON
backup on desktop.

Automatic backup snapshots live in a `backups/` subdirectory of the same
application support directory. Export/import uses the native file picker on
all platforms.

## Desktop behaviour

- Initial window: 1280×800 logical pixels; minimum 900×600 (scaled by DPI on
  Windows). Linux also sets a GTK minimum size.
- Wide windows use the existing `NavigationRail`; narrow windows keep the
  bottom bar used on phones.
- Dialogs are capped at 640 logical pixels and bottom sheets at 720 logical
  pixels, centered on large windows. Mobile widths are unaffected.
- Post-its and event bars start dragging immediately with a mouse; touch uses
  the original long-press gesture.
- Right-click opens context menus for days, post-its, inbox rows, notes,
  routines/activities and tags.
- Desktop editors use `Ctrl+S` / `Ctrl+Enter` to save and `Esc` to cancel.
- Desktop lists use explicit delete actions instead of hold-to-delete.
- In checklist notes, `Ctrl+click` selects a line and `Shift+click` selects a
  range; `Esc` clears the selection.
- Keyboard shortcuts in the main window:
  - `Ctrl+1…4`: Agenda, Inbox, Notes, Routines.
  - `Ctrl+Tab` / `Shift+Ctrl+Tab`: next/previous section.
  - `Ctrl+N`: create an item in the current section.
  - `Ctrl+,`: Settings.
  - `Ctrl+Shift+S`: Sync settings.
  - `Ctrl+←` / `Ctrl+→`: previous/next calendar period.
  - `Alt+←` / `Alt+→`: previous/next day.
  - `Ctrl++` / `Ctrl+-`: more/fewer visible days.
  - `Ctrl+T`: today.
  - `Ctrl+S` / `Ctrl+Enter`: save in an editor or dialog.
  - `Ctrl+B` / `Ctrl+I` / `Ctrl+K`: Markdown bold/italic/link.
  - `F1` or `Ctrl+/`: shortcut help.
- Settings has a desktop-only “Desktop shortcuts” entry; the Agenda hint and
  checklist/routine hints switch to mouse/keyboard wording on desktop.

## Platform-specific integrations

| Feature | Android | Windows / Linux |
| --- | --- | --- |
| Calendar, inbox, notes, routines | Yes | Yes |
| SQLite/Drift + migrations | Yes | Yes |
| JSON backup and snapshots | Yes | Yes |
| Optional server sync | Yes | Yes, while the app is open |
| Manual sync trigger | Yes | Yes |
| Periodic background sync (WorkManager) | Yes | Not available; desktop sync is opportunistic/manual |
| Scheduled local notifications | Yes | Not scheduled; Settings explains the limitation |
| QR pairing scanner | Camera (`mobile_scanner`) | Manual pairing code; the scanner plugin has no Windows/Linux implementation |
| Secure sync token | Android keystore-backed storage | Windows Credential Manager / Linux Secret Service (`libsecret`) |
| Keep screen awake | Yes | Supported by `wakelock_plus` where the desktop session allows it |
| URL opening | Yes | Yes (`url_launcher`) |

None of these limitations affect local offline use. The app opens and works
without a server, account, network or camera.

## Development requirements

Common:

- Flutter 3.47.9+ (Dart 3.13.7+).
- Run `flutter pub get`; generated Drift code is already committed. Use
  `dart run build_runner build --delete-conflicting-outputs` only after schema
  or table changes.

Windows:

- Visual Studio with the **Desktop development with C++** workload (MSVC,
  CMake, Windows 10/11 SDK).
- Developer Mode enabled, because Flutter creates symlinks for plugin
  ephemeral directories.
- 64-bit Windows 10/11.

Linux:

```bash
sudo apt-get install clang cmake ninja-build pkg-config \
  libgtk-3-dev libsecret-1-dev libjsoncpp-dev liblzma-dev \
  dpkg-dev appimagetool
```

`dpkg-dev` provides `dpkg-deb` for the Debian package. `appimagetool` is only
needed for AppImage output; on its first run it may download the AppImage
runtime (later builds reuse the cache).

## Build commands

```bash
flutter pub get
flutter analyze
flutter test

# Android (unchanged)
flutter build apk --release --split-per-abi
flutter build apk --release

# Windows x64 + portable ZIP
pwsh -File scripts/build_windows.ps1

# Linux x64 + tar.gz + .deb (+ AppImage when appimagetool exists)
bash scripts/build_linux.sh
```

Release artifacts are written under `dist/` (ignored by git).

## Distribution layout

Windows portable ZIP (`dist/windows/Stick2Planner-<version>-windows-x64.zip`):

```text
stick2planner.exe
flutter_windows.dll
*.dll                       # plugin runtimes and native assets
data/
  icudtl.dat
  flutter_assets/
  app.so                    # release AOT library
README.txt
```

Optional MSIX:

```text
dist/windows/msix/Stick2Planner-<version>-windows-x64.msix
```

The MSIX manifest is in `packaging/windows/msix/AppxManifest.xml`. The package
is unsigned unless a certificate is supplied:

```powershell
pwsh -File scripts/package_windows_msix.ps1 `
  -Publisher "CN=Stick2Planner" `
  -CertificatePath ".\certs\stick2planner.pfx" `
  -CertificatePassword "<password>"
```

Linux bundle (inside `dist/linux/Stick2Planner-<version>-linux-x64.tar.gz`):

```text
stick2planner
lib/libflutter_linux_gtk.so
lib/libapp.so               # release AOT library
lib/*.so                    # plugin/native assets
data/icudtl.dat
data/flutter_assets/
README.txt
```

Debian package (`dist/linux/stick2planner_<version>_amd64.deb`) installs:

```text
/opt/stick2planner/                 complete relocatable bundle
/usr/bin/stick2planner              symlink
/usr/share/applications/stick2planner.desktop
/usr/share/icons/hicolor/256x256/apps/stick2planner.png
```

AppImage, when built, is self-contained for the Flutter bundle but still uses
the host GTK 3 / Secret Service libraries, as allowed by the AppImage runtime
model.

## Validation and known limitations

Validated on the development host:

```bash
flutter analyze          # no issues
flutter test             # 304 tests passed
flutter build apk --release
```

Linux release validation was executed in WSL Ubuntu 26.04 with Flutter 3.47.9:

```bash
FLUTTER_BIN=/opt/flutter-linux/flutter/bin/flutter bash scripts/build_linux.sh
```

It produced `Stick2Planner-0.6.2-linux-x64.tar.gz`,
`stick2planner_0.6.2+14_amd64.deb` and
`Stick2Planner-0.6.2-linux-x64.AppImage`.

Windows release validation also passed after enabling Developer Mode and
installing the Visual Studio C++ desktop workload:

```powershell
flutter build windows --release
pwsh -File scripts/build_windows.ps1
pwsh -File scripts/package_windows_msix.ps1
```

It produced `Stick2Planner-0.6.2-windows-x64.zip` and an unsigned
`Stick2Planner-0.6.2-windows-x64.msix`. The MSIX must be signed with a trusted
certificate before normal installation.

The portable ZIP needs no certificate and is the supported no-signing
distribution. Installing the unsigned MSIX with
`Add-AppxPackage -AllowUnsigned` was tested and rejected with `0x80073D2C`
because its publisher is not in Windows' special unsigned-package namespace.
Unsigned installation would additionally require an elevated PowerShell and a
manifest publisher with the development OID; that variant is not suitable for
distribution.

This repository's build scripts fail with a clear message if the platform
toolchain or Developer Mode is missing; they never omit runtime libraries to
force a successful build.

Remaining limitations:

- `mobile_scanner` and `workmanager` have no Windows/Linux implementation. Both
  are guarded at runtime; they are not removed from the Android build.
- Desktop notifications are intentionally not scheduled yet. The plugin stack
  supports desktop channels, but adding them would require new permission and
  app-identity work outside this migration.
- Linux secure storage needs a running Secret Service implementation
  (GNOME Keyring, KWallet, etc.). If unavailable, pairing fails gracefully and
  the rest of the app keeps working.
- Windows builds require the Microsoft Visual C++ runtime. It is normally
  present on Windows 10/11; for clean machines, distribute the VC++ x64
  redistributable or use an MSIX dependency. The Flutter runtime DLLs are
  always included in the portable ZIP.
