**English** | [Português (Brasil)](QUALIDADE.pt-BR.md)

# Quality and delivery

Checklist for the Stick2Planner local MVP and the post-MVP rounds (optional
sync, backup, web page and phone adjustments).

## Validated scope

- Visual schedule: periods, continuous events, creation, editing, dragging,
  reordering, resizing, states, recurrence and a 4-day anchored window.
- Event recurrence: daily, every N weeks, every N months and yearly.\n- Event time, shared tags and automatic event completion.\n- Inbox: filters, search, undated tasks and access to details.
- Notes: Markdown text, lists, snapshots and links to post-its.
- Navigation: linked/snapshot post-it → Schedule → existing detail; Inbox with
  "Open in Schedule" for dated post-its.
- Local persistence: drift/SQLite, transactions, migrations v1 → v9 and tombstones.
- Settings: theme, Portuguese/English language, six palettes with gradient,
  animations, wakelock, tips, connection/sync and shortcut to the About screen.
- About: installed version read from the package, description and GitHub links.
- Backup: versioned JSON with canonical checksum, version/schema validation,
  transactional import with prior snapshot and snapshot restoration. The
  displayed counts ignore deleted items; tombstones remain in the JSON.
- Sync: own server, pairing via QR/code, revocable tokens, web page in
  Portuguese/English, manual/automatic sync, conflict copy and
  count check local × remote before applying (keep local,
  keep remote or cancel).

## Validation matrix

| Area | Coverage |
| --- | --- |
| Domain | dates, recurrence, validation, event layout |
| Database | repositories, transactions, rollback, migrations |
| Backup | canonicalization, checksum, versions, round-trip, snapshots |
| Sync | transactional outbox, coalescing, v5 migration, remote apply |
| Server | auth, pairing, idempotency, conflict, pagination, revocation |
| Web | login, session, live QR, devices, rename/revoke, PT/EN, portrait/landscape |
| UI | schedule, inbox, notes, editor, details, links, backup, About |
| Layout | 1280×800, 800×1280, 780×360, 360×780, 500×800 and 1.3× text |
| Desktop | Windows x64, Linux x64, 1280×800 default / 900×600 minimum, shortcuts, adaptive sheets/dialogs |
| Device | Android tablet 3200×2136 and phone 1080×2340, dark theme |
| Load | 200 post-its in the schedule |
| Offline | without a server the app stays local; `INTERNET` only for optional sync |

## Accessibility

- Schedule days expose a label with the full date, a "today" indicator and
  "selected", in addition to the tap action.
- Post-its and event bars have their own semantic label.
- Icon buttons use tooltip/`Semantics`.
- Resize handles keep a 24×24 logical dp touch area.
- Dialogs, fields and buttons follow Material 3 components with labels.
- Alternatives to gestures: FAB/AppBar to create, details to move, edit,
  reorder, resize and change status.
- Enlarged text test (1.3×) covers the schedule and the Markdown editor.

## Offline and privacy

- `INTERNET`/`ACCESS_NETWORK_STATE` exist only for optional synchronization;
  without a server the app opens and operates normally.
- Data is stored in SQLite on the device; the server is optional and uses a
  per-device token stored in secure storage.
- Platform services: wakelock (screen on) and WorkManager (periodic best-effort
  sync).

## Consistency

- Planner mutations are serialized and persisted in transactions.
- Moving and resizing update the UI optimistically; on a write failure the
  previous state is restored.
- Deleting a note removes live links in the same transaction and preserves
  snapshots.
- Migrations preserve legacy text notes and lists.

## Known limitations

- CalDAV/iCalendar and Radicale are not implemented; the planned
  interoperability is in `docs/DECISIONS.md`.
- Synchronization requires a configured own server and network; there is no
  public account and no multiuser. Without a server, the app remains local.
- When local and remote diverge, automatic sync pauses at "Review
  required" until the user chooses to keep local, keep remote or cancel.
- Markdown links in notes are rendered but do not open a browser; the links on
  the About screen use `url_launcher`.
- Text snapshot uses raw Markdown; it is not a WYSIWYG selection.
- A post-it accepts one note link at a time.
- There is no undo for note deletion and no dedicated search in the notebook.
- There is no "reduce motion" preference; animations are short.
- The grid keeps a 1.5 px optical gutter between cells in the month.
- Two/three taps open the configured form; saving happens on save.
- Snapshots created before the v4 migration have no `sourceNoteId` and do not
  appear under "Excerpts from this note"; they remain accessible from the Inbox.
- "Open in Schedule" in Notes is disabled for undated post-its; the detail popup
  remains available.
- Periodic WorkManager is best-effort; the system may postpone execution.
- Inbox filters are not persisted across restarts.
- Desktop QR camera scanning and scheduled local notifications are Android-only;
  desktop pairs with the manual code. WorkManager periodic sync is Android-only.
- Linux secure storage requires a running Secret Service/keyring.
- Windows builds require Flutter plugin symlink support (Developer Mode or an
  elevated terminal) and the Microsoft Visual C++ runtime.
- The Windows data path keeps the legacy `com.example` company metadata so
  existing `%APPDATA%` data is not moved. See `docs/DESKTOP.md`.

## Size and performance

- Debug APK: ~188 MB (debug runtime/symbols).
- Split release APK: ~25–31 MB per ABI, mainly due to the QR reader's ML Kit;
  arm64 measured at ~25.8 MB in the most recent build.
- Local database: ~80 KB for 17 post-its, 3 notes and 58 history records.
- Release is the reference for evaluating smoothness; animations can be turned off.

## Final commands

```bash
flutter analyze
flutter test
flutter build apk --release --split-per-abi

# On Windows
pwsh -File scripts/build_windows.ps1

# On Linux
bash scripts/build_linux.sh

cd stick2server
dart analyze
dart test
```

## Result

Desktop migration validation (2026-11-12):

- `flutter analyze`: no issues.
- `flutter test`: 304 tests passed, including the database migration/connection
  suite and five desktop interaction tests (shortcuts, Ctrl+S save, right-click
  context menu, explicit desktop delete and desktop pairing without QR).
- `flutter build apk --release`: passed; universal APK generated.
- Linux: `scripts/build_linux.sh` completed in WSL Ubuntu 26.04 with Flutter
  3.47.9. Generated the portable bundle/tar.gz, `stick2planner_0.6.2+14_amd64.deb`
  and `Stick2Planner-0.6.2-linux-x64.AppImage`.
- Windows: `flutter build windows --release` passed after enabling Developer
  Mode and installing the Visual Studio C++ desktop workload. The portable ZIP
  and an unsigned MSIX were generated. The ZIP is directly usable; the unsigned
  MSIX requires signing (or a development-only unsigned-namespace publisher).
- Android data compatibility: schema v9 and `planner.sqlite` are unchanged; all
  migration and rollback tests passed.
- Server tests were not re-run in this migration; their previous result remains
  16 tests passed.
