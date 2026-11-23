# Quality and validation

This document records what is actually verified at the current state, what is
only covered by automated tests, and what still needs manual confirmation. It is
not a development log.

State of this review: **2026-11-23**, app **0.10.4+22**, schema **v13**,
Stick2Server **0.2.3**.

## 1. Validated scope

The following areas are implemented and have automated coverage:

- Calendar: five view modes (orientation-specific sets), selected-date anchor,
  month grid, multi-day event segments, drag/resize/reorder, event lanes,
  quick creation and day sheet.
- Recurrence: daily, every N weeks, every N months and yearly; optional end
  date; per-occurrence completion/cancellation; recurring tasks; series split
  when an occurrence moves; recurring-TO-DO daily rollover.
- Post-it types: task, event, recurring TO-DO and **Feito**; validation rules,
  states (`active`, `done`, `cancelled`) and detail actions.
- Inbox: search, state filters, "no date", tag filters, sorting and access to
  details/actions.
- Tags: shared definitions, five tones, palette-derived colors, association from
  post-its and Inbox, sync and backup.
- Notes: Markdown and checklist modes, toolbar, preview, line/range selection,
  snapshots, provenance and live post-it links.
- Routines: simple checklists; complete cards with sections/intervals/tasks;
  per-day completion; drag reordering; hold-to-delete; reminders; execution
  history; dashboard.
- Notifications: daily summary, post-it reminders and routine reminders on
  Android, including a completion action and a test notification.
- Backup: canonical JSON, checksum, schema/version validation, transactional
  import, pre-import snapshot and snapshot restore.
- Sync: outbox, coalescing, push/pull, preflight counts, keep-local/keep-remote,
  generic conflicts, routine three-way merge, tombstones, revocation and
  compatibility with older servers.
- Desktop: same schema and controllers, adaptive rail/bar, mouse drag,
  right-click menus, keyboard shortcuts, desktop dialogs and explicit delete.
- Accessibility: semantic labels for days/post-its/actions, 24×24 dp resize
  handles and 1.3× text-scale widget tests.

## 2. Test strategy

| Layer | What is exercised |
| --- | --- |
| Domain | `DateOnly`, calendar periods, recurrence expansion/clamping, validation, rollover, event bar layout, routine interval split/merge |
| Database | repositories, transactions and rollback, foreign keys, in-memory connection, migrations v1 → v13 |
| Backup | canonicalization, SHA-256 checksum, accepted schemas 4–13, round-trip, snapshots, failure handling |
| Sync | outbox coalescing, engine push/pull, idempotency, conflicts, two-device convergence, tags, series segments, routine merge, execution dedupe |
| UI/widgets | calendar modes, drag and resize, inbox, notes/editor/selection, routines, settings, backup, About, failure states |
| Accessibility | labels and 1.3× text scale |
| Load | 200 post-its rendered and navigated in month view |
| Offline contract | internet permission only for optional sync; no foreground service or battery-exemption request |

### Accessibility details

- Calendar days expose the full date, a "today" indicator and "selected" state,
  in addition to the tap action.
- Post-its and event bars have their own semantic labels.
- Icon buttons use tooltip/`Semantics`.
- Resize handles keep a 24×24 logical dp touch area with a visible grip.
- Dialogs and fields use Material 3 labels and focus order.
- Every gesture has a non-gesture alternative: create via FAB/AppBar, move via
  details, edit/reorder/resize/status via details.
- 1.3× text scale is covered for the calendar and the Markdown editor.

## 3. Current automated results

Run on 2026-11-23 in this working tree:

```text
flutter analyze  → No issues found
flutter test     → 381 tests passed
```

The suite includes regression coverage for the active-day highlight, the
selected-day tap window and tag-colored events.

The sync suite emits Drift's "database class created multiple times" warning
because the two-device tests open more than one in-memory database in the same
process. It is expected in that suite and does not fail the run.

The suite is not a substitute for device testing. In particular, it does not
prove rendering performance on low-end hardware, real notification delivery,
camera/QR behavior, secure-storage behavior on every desktop keyring, or
accessibility with TalkBack.

Server-side validation was last recorded at Stick2Server 0.2.3: `dart analyze`
clean and 20 tests passing, including recurring task series and execution
history. It was not rerun for this documentation-only review.

## 4. Builds

Artifacts present in `dist/` at this review (not committed; `dist/` is ignored):

| Target | Version | Artifact | Size |
| --- | --- | --- | --- |
| Android arm64 | 0.10.4 | `Stick2Planner-0.10.4-arm64.apk` | ~30.2 MB |
| Android universal | 0.10.4 | `Stick2Planner-0.10.4-universal.apk` | ~83.9 MB |
| Windows x64 | 0.10.4 | portable ZIP | ~14.7 MB |
| Windows x64 | 0.10.4 | unsigned MSIX | ~14.8 MB |
| Linux x64 | 0.6.2 | tar.gz | ~12.0 MB |
| Linux x64 | 0.6.2 | `.deb` | ~9.7 MB |
| Linux x64 | 0.6.2 | AppImage | ~11.9 MB |

The GitHub release `v0.10.4` contains the Android APKs and the Windows ZIP/MSIX.
Linux artifacts are not published in that release. The Linux artifacts above are
older (0.6.2) and were built in WSL Ubuntu 26.04 with Flutter 3.47.9.

A successful build does not mean the feature was manually validated. The release
APK currently uses the Android debug signing config; a real keystore is required
before distributing outside GitHub Releases.

## 5. Manual validation

### Android

- Physical tablet: Android 16 / HyperOS 3.0, arm64, 3200×2136, dark theme.
- Stages 1–6 were exercised on the device on 2026-11-03: launch, calendar,
  creation/editing, drag, resize, states, inbox, notes/Markdown and navigation.
- Notification delivery was verified on 0.4.1 (2026-11-10) with the immediate
  and 10-second test notifications; the channel was reported at importance 4.
- Gestures in the early rounds were also injected via `adb shell input` /
  `motionevent`; those are not a substitute for continuous finger/stylus tests.
- Early releases were installed on a phone; Settings and About were checked.

Not manually validated on Android after 0.4.1: series split, routine reminders,
desktop-specific behavior, TalkBack, stylus and continuous multitouch. The
0.10.4 release APK was installed and used to validate carousel clipping, the
selected-day tap/sheet flow, tag-colored events, routines/dashboard and a
screen-recorded navigation pass with test data; these checks are not a substitute
for the remaining manual matrix.

### Synchronization

- A real Stick2Server deployment was used with a tablet and phone over
  Tailscale/LAN in the 0.2.x stage: pairing, HTTPS sync, revocation and
  cross-device convergence were exercised.
- Later server versions (0.2.2/0.2.3) and routine/execution entities are covered
  by automated two-device tests and server tests; a fresh manual cross-device
  routine validation was not recorded.

### Desktop

- Windows release build and packaging scripts succeeded after enabling Developer
  Mode and installing the Visual Studio C++ workload. A clean Windows 10/11
  machine review (all screens, both input methods, DPI scaling, backup path) is
  still pending.
- Linux release packaging succeeded in WSL at 0.6.2. A real Linux GUI smoke test
  (GTK runtime, keyring, window behavior) is still pending.
- Desktop notifications are intentionally not scheduled; QR scanning is
  Android-only.

### Accessibility and input

- Widget tests cover semantic labels and 1.3× text scale for the calendar and the
  Markdown editor.
- TalkBack, stylus, external keyboard and sustained multi-touch were not manually
  validated.

## 6. Known limitations

### Product

- Sync requires a self-hosted Stick2Server and network; there is no public
  account, cloud service or multiuser support.
- CalDAV/iCalendar/Radicale are not implemented; the evaluation is documented in
  [`ARCHITECTURE.md`](ARCHITECTURE.md#13-deliberate-non-goals).
- When local and remote data diverge, automatic sync pauses at **Review
  required** until the user chooses.
- Routine conflicts on the same element keep the server version and create a
  `[Conflict]` copy; they are not automatically resolved.
- Markdown links are rendered but do not open a browser.
- A post-it accepts one live note link at a time.
- Text snapshots use the raw Markdown selection, not a WYSIWYG selection.
- There is no undo for note deletion and no dedicated search in the notebook.
- Inbox filters are not persisted across restarts.
- Snapshots created before the v4 migration have no `sourceNoteId` and do not
  appear under "Excerpts from this note".
- "Open in Schedule" is disabled for undated post-its; the detail sheet remains
  available.
- Feito records intentionally reject tags, duration, recurrence, completion,
  cancellation and resize.
- There is no free x/y positioning of post-its; ordering is per day.

### Platform

- Android: notifications, QR scanning and periodic WorkManager sync are
  Android-only. Periodic work is best effort and may be delayed.
- Android: `USE_EXACT_ALARM` is policy-restricted; the app falls back to inexact
  scheduling when exact alarms are not authorized.
- Windows/Linux: no scheduled local notifications and no camera QR scanner; pair
  with the manual code.
- Windows: builds need Developer Mode for plugin symlinks; the portable build
  needs the Visual C++ runtime; the MSIX is unsigned unless a certificate is
  supplied.
- Windows: the data path keeps the legacy `com.example` metadata so existing
  `%APPDATA%` data is not moved.
- Linux: secure storage requires a running Secret Service provider; the AppImage
  still depends on host GTK/Secret Service libraries.
- Linux: latest release artifacts have not been published or GUI-tested at
  0.10.4.

### Validation and delivery

- No CI pipeline: analyze, tests and builds are run manually.
- No performance benchmark on low-end devices; the load test is a 200-item
  widget test.
- The native backup file picker has automated coverage but was not exercised on
  a physical device in the recorded rounds.
- No manual validation of TalkBack, stylus, physical keyboard, sustained
  multi-touch, or every desktop keyring.
- Screenshots in `docs/validacao/` date from 2026-11-03 and predate tags,
  routines, notifications, desktop support and the continuous carousel. They are
  historical evidence, not a current UI reference. One month-view capture also
  contains a personal messaging notification overlay and must not be published.
- The code comment at the top of `lib/data/db/app_database.dart` still describes
  schema v5 even though `schemaVersion` is 13; this is a code comment awaiting a
  code change, not a behavioral issue.

## 7. Validation commands

```bash
flutter analyze
flutter test

# Optional Android release build
flutter build apk --release --split-per-abi

# Desktop packaging (run on the target OS)
pwsh -File scripts/build_windows.ps1
bash scripts/build_linux.sh

# Sync server (separate repository)
cd ../stick2server
dart analyze
dart test
```

Do not treat a successful build as functional validation. Record manual device
results separately, with date, platform, app version and what was actually
exercised.
