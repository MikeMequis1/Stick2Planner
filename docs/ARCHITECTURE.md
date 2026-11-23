# Architecture

Stick2Planner is a single Flutter codebase for Android, Windows and Linux. The
application is local-first: the SQLite database is the source of truth, and the
optional Stick2Server integration is an additional synchronization path rather
than a runtime dependency.

This document describes the current architecture and the decisions that still
shape the code. Historical development records are intentionally not reproduced
here; Git history preserves them.

## 1. Design constraints

- The app must open and work without a server, account or network.
- Data must survive app updates and schema migrations.
- The same domain rules and database schema must run on Android and desktop.
- Touch and mouse/keyboard are both first-class inputs.
- Platform-only integrations (camera, notifications, background work) must be
  optional and guarded at runtime.
- Sync must not be able to delete local data while the server is unreachable.
- User content must remain recoverable when a conflict cannot be merged.

## 2. System context

```text
┌──────────────────────────── Stick2Planner ────────────────────────────┐
│ Flutter UI (features)                                                 │
│        │                                                              │
│        ▼                                                              │
│ controllers / services (app)                                          │
│        │                                                              │
│        ├──────────────► domain entities and use cases                 │
│        │                                                              │
│        ▼                                                              │
│ Drift repositories (data) ──► planner.sqlite                          │
│        │                                                              │
│        ├──► JSON backup / snapshots (local files)                    │
│        └──► sync engine ──HTTP──► Stick2Server (optional, own server) │
└───────────────────────────────────────────────────────────────────────┘
```

The server is never the primary store. It receives opaque entity payloads,
assigns revisions and returns changes after a cursor. A device can disconnect,
continue editing and synchronize later.

## 3. Layers and responsibilities

| Layer | Location | Responsibility |
| --- | --- | --- |
| UI | `lib/features/` | Pages, dialogs, sheets, gestures, keyboard shortcuts and accessibility labels. Organized by section: planner, inbox, notes, routines, tags, settings, shell and shared widgets. |
| Application | `lib/app/` | Composition root, `AppScope`, `ChangeNotifier` controllers, navigation, settings, notifications, token storage, background sync and the sync coordinator. |
| Domain | `lib/domain/` | Pure Dart entities, calendar periods, recurrence expansion, validation, rollover, completion and routine interval rules. Repository interfaces live here. |
| Data | `lib/data/` | Drift database, repositories, mappers, backup, sync engine, outbox, transport and conflict merge. |
| Core | `lib/core/` | `DateOnly`, `Clock`, canonical JSON, formatting, platform capability checks and app version metadata. |

Dependency direction:

```text
features ──► app ──► domain
                  ▲
data ─────────────┘   (data implements domain interfaces)
```

`domain` does not import Flutter or Drift. `data` may depend on `domain` and
`core`, never on `features`. `app` is the only place that wires concrete
implementations together.

## 4. Composition and state management

- `lib/main.dart` initializes Flutter bindings, date formatting and the
  dependency graph.
- `AppDependencies` (`lib/app/bootstrap.dart`) creates the database,
  repositories, controllers, backup service, notification service and sync
  coordinator. Tests build the same graph with an in-memory database.
- `AppScope` is an `InheritedWidget` that exposes the controllers to the widget
  tree. Widgets subscribe with `ListenableBuilder`; there is no Riverpod, Bloc or
  Provider dependency.
- Controllers are `ChangeNotifier`s:
  - `PlannerController` — calendar items, selection, view mode, mutations.
  - `NotesController` — notes, lines, snapshots and links.
  - `TagsController` — tag definitions and associations.
  - `RoutinesController` — simple/complete routines, completions, reminders and
    executions.
  - `AppSettingsController` — theme, language, palette, animations, wake lock,
    hints and notifications.
  - `AppNavigationController` — current shell section and navigation intents.
  - `SyncCoordinator` — pairing, triggers, preflight, status and reports.
- Widgets do not call repositories directly. User actions go through a
  controller, which validates, persists and refreshes its in-memory list.

Why `ChangeNotifier`: the application has a small number of long-lived screens
and a single dependency graph. The built-in mechanism keeps the composition
explicit and avoids a state-management framework in the MVP. The cost is manual
listener wiring; `AppScope` and controller-level tests contain that cost.

### Write path

Most mutations follow this order:

1. Validate in the controller/domain.
2. Persist through the repository inside a transaction.
3. Reload or update the in-memory list.
4. Notify listeners.

`PlannerController` serializes mutations through an exclusive queue so rapid
drags and edits cannot interleave transactions. Moving and resizing are the
deliberate exception: the UI updates optimistically to avoid flicker, and the
previous state is restored if the write fails.

## 5. Local persistence

### Drift + SQLite

The local database is created by `AppDatabase` (`lib/data/db/app_database.dart`)
with Drift. It uses:

- `schemaVersion` **13**;
- incremental migrations from v1;
- `PRAGMA foreign_keys = ON` on open;
- `journal_mode = WAL`, `busy_timeout = 5000` and `synchronous = NORMAL` for file
  connections. WAL and the timeout matter because Android WorkManager can open a
  second connection while the foreground app is writing.

The database file is `planner.sqlite` inside
`getApplicationSupportDirectory()`. Nothing is written next to the executable.

Why Drift instead of `sqflite`, Isar, ObjectBox or Hive:

- the model is relational (post-it ↔ history ↔ note, routines ↔ sections ↔
  intervals ↔ completions, sync metadata);
- transactions are required for moving/resizing/reordering and for sync
  application;
- versioned migrations are a product requirement;
- tests can use an in-memory database and exercise the same SQL.

The trade-off is mandatory code generation (`build_runner`). Generated Drift
code is committed because release builds and fresh checkouts must not depend on
codegen being run first.

### Tables

| Group | Tables | Purpose |
| --- | --- | --- |
| Settings | `app_settings` | Key/value preferences. New preferences do not require a migration. |
| Post-its | `post_its`, `post_it_history_entries` | Unified tasks/events, audit history. |
| Notes | `notes`, `note_lines` | Markdown text notes or ordered checklist lines. |
| Tags | `tags` | Shared tag definitions; post-its store tag IDs. |
| Routines (simple) | `routines`, `routine_items`, `routine_completions` | Weekly checklist and per-date completion. |
| Routines (complete) | `routine_sections`, `routine_intervals`, `routine_interval_completions` | Cards, time intervals and one task per interval. |
| Routine operations | `routine_reminders`, `routine_executions` | Reminder configuration and append-only execution log. |
| Sync | `sync_outbox`, `sync_row_states`, `sync_bases`, `sync_states` | Pending changes, applied revisions, merge bases and device/server state. |

The sync tables are local metadata. They are not exported in JSON backups; a
backup import clears the outbox, row states and merge bases while preserving the
device ID and server configuration.

## 6. Conceptual data model

```text
PostIt ── noteId ───────────────► Note ── 1:n ──► NoteLine
  │                                 │
  ├── 1:n ──► PostItHistory        └── sourceNoteId ◄── snapshot provenance
  │
  ├── tagIds[] ───────────────► Tag (IDs stored as JSON)
  │
  └── seriesId ──► other PostIt rows of the same recurring series

Routine
  ├── routine_items ── 1:n ──► routine_completions
  ├── routine_sections ── 1:n ──► routine_intervals
  │                                  └── 1:n ──► routine_interval_completions
  ├── routine_reminders
  └── routine_executions (no FK; survives routine deletion)
```

### Post-it

A single `post_its` table represents:

- `task` — optional single date; no duration or recurrence required;
- `event` — date required, optional end date, recurrence, time and tags;
- `recurringTodo` — the UI's **Pending** item: one row advanced by the daily
  rollover, never a generated copy.

Important fields: `status`, `isHighlight` (**Feito**), `details`, `noteId`,
`noteExcerpt`, `sourceNoteId`, `startDate`, `endDate`, `recurrence`,
`recurrenceInterval`, `recurrenceEndDate`, `seriesId`, `occurrenceStatuses`,
`timeMinutes`, `reminderMinutes`, `tagIds`, `sortOrder`, `lastRolloverAt`,
`createdAt`, `updatedAt`, `deletedAt`.

Rules that matter for maintenance:

- Completing or cancelling never deletes a row. Permanent deletion writes a
  tombstone (`deletedAt`) so history and future sync can represent it.
- `sortOrder` is a per-day visual order, not an x/y coordinate. The layout must
  remain readable after rotation and on another screen size.
- Color is never the only carrier of meaning; state, type and highlight also use
  icons, labels or symbols.
- **Feito** records are single-day events without tags, duration or recurrence.
  Completion, cancellation and resize are rejected by validation as well as hidden
  in the UI.
- `occurrenceStatuses` is keyed by the occurrence start date. The series status
  wins over per-occurrence marks; reopening the series clears the overrides.
- A split recurring series is represented by two or more rows sharing
  `seriesId`. `null` means the row is the root.

### Notes

- A text note stores Markdown in `notes.markdown`; its lines table is empty.
- A checklist note stores ordered `note_lines`; `markdown` is null.
- A **snapshot** is a copied excerpt stored on the post-it as `noteExcerpt` with
  `noteId = null` and optional `sourceNoteId` for provenance. It does not change
  when the note changes.
- A **live link** is `post_its.noteId`. Editing the note is reflected in the
  link; deleting the note unlinks post-its in the same transaction while keeping
  title, details and snapshots.
- Notes do not have a separate history table. Link/unlink events are recorded in
  the post-it history.

### Routines

- `routines.mode` selects `simple` or `complete`.
- Simple routines keep the legacy `routine_items` + `routine_completions`
  structure.
- Complete routines use normalized `routine_sections` → `routine_intervals`.
  Intermediate times are boundaries between intervals. Adding a time splits the
  containing interval; the left side keeps its ID, task and completions, and the
  right side receives a new ID. Moving a boundary only changes adjacent
  start/end values. Removing a boundary merges neighbors; if both sides have a
  task, the user must choose which task survives.
- `RoutineInterval.id` is the stable identity. List indexes are never used as
  identity.
- `createdAt` is the routine creation instant. Occurrences are not shown before
  its local calendar date, even after an offline gap or delayed sync.
- `routine_executions` is an append-only log independent from the current
  checkbox state. `dedupeKey` prevents duplicate manual toggles or repeated
  notification actions. It has no foreign key to routines or activities, so
  deleting a routine does not erase its history.
- Reminders live in `routine_reminders` and travel inside the atomic routine
  payload. Notification IDs are derived locally and are not synchronized.

### Dates and identity

- Calendar dates use `DateOnly` (no time, persisted as `yyyy-MM-dd`). This avoids
  DST and timezone shifts in calendar rules.
- Audit timestamps are UTC milliseconds since epoch.
- IDs are UUID v4.
- Event times, routine times and reminder lead times use local wall-clock
  minutes since midnight, not UTC timestamps.
- `Clock` is injectable so domain tests do not depend on `DateTime.now()`.

## 7. Calendar model

Five view modes exist, with orientation-specific sets:

| Orientation | Modes |
| --- | --- |
| Landscape | week, 2 weeks, month |
| Portrait | day, 4 days, week |

The selected date is the anchor. Previous/next moves the selection by one period
(1, 4, 7 or 14 days; month preserves and clamps the day). The 4-day window starts
at the selected date and stays anchored when another visible day is tapped.
Changing mode or orientation does not change data.

Recurrence is a property of a series, not only of events:

- `recurrence` can be daily, weekly (every N weeks), monthly (every N months) or
  yearly;
- occurrences are virtual copies generated for the visible period; they are not
  separate rows;
- monthly/yearly arithmetic clamps the day (31 Jan → 28/29 Feb; 29 Feb → 28 Feb);
- `recurrenceEndDate` limits occurrence starts and is independent from `endDate`
  (duration);
- tasks can also be recurring series. `recurringTodo` is the exception: it is a
  single row advanced by `EnsureRecurringRollover` at boot, on resume and before
  schedule operations.

Multi-day events are one continuous record rendered as segments across weeks,
not repeated cards. The event lane is ordered deterministically
(start, end, `sortOrder`, id) so lane assignment remains stable after a drag.

Other calendar interaction rules that still matter:

- A first tap selects a day. Another tap on the selected day opens the full day
  sheet only when that day has content and only after the same short multi-tap
  window used for quick creation. Two/three taps on a day with content therefore
  do not trigger the single-tap sheet. Empty days never open an empty sheet;
  two/three taps still quick-create a task/event on empty days.
- Active events with tags use the first associated tag's background and
  foreground, so agenda bars, day tiles and Inbox rows match the tag chip.
  Tasks keep their type color; resolved and Feito records keep the status/highlight
  treatment, and the tag chips remain visible as text/identity.
- Deleting a post-it shows an **Undo** action; restoring it records `restored` in
  the history instead of resurrecting a silent copy.
- Dragging near the grid edge does not auto-scroll. **Move to date…** is the
  deliberate fallback, avoiding accidental moves while the finger is near the
  boundary.
- Opening a post-it from a note or the Inbox uses its UUID and opens the existing
  record. A missing UUID shows a warning instead of creating a copy.
- On narrow screens the create action moves to the AppBar in Agenda/Inbox; on
  wide screens the Agenda keeps the extended FAB.

## 8. Offline-first and write consistency

- Every user action writes to SQLite first.
- Repositories record sync outbox entries in the same transaction as the domain
  change. A crash after commit leaves a durable pending change.
- Tombstones preserve deletions for history and sync.
- No network operation is required to open, edit, search or back up data.
- A sync failure never rolls back local edits; the outbox remains and the error
  is exposed in Settings.
- Backup import is an explicit destructive operation: it verifies a snapshot
  first, then replaces all user data in one transaction.

## 9. Synchronization architecture

The full operational guide is in [`SYNC.md`](SYNC.md). The architectural points
are:

- The server is a separate Dart/shelf service with its own SQLite database. It
  stores opaque JSON payloads per `(entity, entityId)` with a monotonic `rev`.
- Entities: `postIt`, `note`, `history`, `tag`, `routine`,
  `routineExecution`.
- Local pending changes live in `sync_outbox`, coalesced by
  `(entity, entityId)`. Each row has the full canonical payload, `baseRev`,
  `changeId`, attempts and last error.
- Push/pull is one request. The server applies a change only when `baseRev`
  equals the current revision; otherwise it returns the server version as a
  conflict.
- `changeId` makes pushes idempotent. Pull returns changes after a cursor.
- Applying pull, acks, revisions and the cursor happens in one local
  transaction.
- Generic conflicts are resolved by highest `updatedAt`; ties and identical
  content keep the server version. The losing local version becomes a
  `[Conflict]` copy (post-it/note/routine).
- Routines use a three-way merge (`base`, `local`, `server`) keyed by stable
  IDs. Independent edits to different cards, intervals, fields or dates merge
  into one payload and are re-sent. A genuine same-element conflict keeps the
  server version and creates a local `[Conflict]` copy.
- Older servers are handled explicitly: below 0.2.2 routine changes stay in the
  outbox; below 0.2.3 execution history stays in the outbox. The rest of sync
  continues.

Why the server stores opaque payloads: the app owns domain semantics, and adding
fields (tags, recurrence, routine cards, reminders) does not require a server
schema migration. The trade-off is that the server cannot validate domain
content; the app must remain backwards compatible with older payloads.

## 10. Backup and restore

- Format: JSON with `format: "stick2planner-backup"`, `formatVersion: 1`,
  `schemaVersion`, app version, export time, counts and a SHA-256 checksum over
  canonical JSON.
- Canonicalization: ordered keys, integer-only numbers, deterministic list
  ordering.
- Accepted schema versions: 4 through 13.
- The export includes post-its, notes, lines, history, tags, routines, routine
  executions, settings and tombstones. Credentials and `planner.sync.*`
  settings are excluded.
- Import replaces all user data in one transaction after creating and verifying
  an automatic snapshot. The last five pre-import snapshots are retained.
- External formats (CalDAV/iCalendar) are not part of the backup.

## 11. Platform strategy

The UI, controllers, domain and Drift schema are shared. Only optional native
integrations are conditional (`lib/core/platform_support.dart`):

| Capability | Android | Windows/Linux |
| --- | --- | --- |
| Calendar, inbox, notes, routines, backup, sync | Yes | Yes |
| QR pairing scanner | Camera via `mobile_scanner` | Manual pairing code |
| Scheduled local notifications | `flutter_local_notifications` | Not scheduled; UI explains the limitation |
| Periodic background sync | WorkManager (best effort) | Opportunistic/manual while open |
| Secure token storage | Android secure storage | Windows Credential Manager / Linux Secret Service |
| Keep screen awake | `wakelock_plus` | Supported where the desktop session allows |

Desktop-specific UI:

- initial window 1280×800, minimum 900×600 (DPI-scaled on Windows);
- `NavigationRail` on wide windows, bottom bar on narrow ones;
- dialogs capped at 640 logical px and bottom sheets at 720 logical px;
- immediate mouse dragging, right-click context menus, `Ctrl+S`/`Ctrl+Enter`
  save, `Esc` cancel, explicit delete actions, and shell shortcuts;
- no hold-to-delete on desktop lists.

The Windows runner intentionally keeps the legacy `com.example` company metadata
so the existing `%APPDATA%\com.example\Stick2Planner` path is not moved. Linux
uses `com.mikemequis1.planner` under `$XDG_DATA_HOME`.

## 12. Decisions that still constrain the code

| Decision | Rationale | Consequence |
| --- | --- | --- |
| Drift + SQLite | Relational data, transactions, migrations and in-memory tests | Codegen is mandatory; generated code is committed |
| `ChangeNotifier` + `AppScope` | Small app, explicit composition, no framework overhead | Manual wiring; controllers must notify correctly |
| `DateOnly` for calendar dates | No DST/timezone drift in schedule rules | Separate wall-clock fields for times/reminders |
| `sortOrder`, not coordinates | Readable on any screen/orientation | No free-form positioning; reorder is explicit |
| Tombstones instead of hard deletes | History and sync need deletion facts | Queries must filter `deletedAt`; storage grows slowly |
| Atomic note and routine payloads | Avoid partial structures during sync | Larger payloads; server stays domain-agnostic |
| Three-way routine merge | Independent edits should not create conflict copies | `sync_bases` is required and must be maintained |
| Local execution log without FKs | History must survive routine deletion | Orphan executions are intentional |
| Optional server, never primary | Offline-first product constraint | Sync must tolerate absence and old server versions |
| Desktop as an extra Flutter target | One UI/domain/schema | Platform-only plugins are guarded and documented |

## 13. Deliberate non-goals

- Public account, multiuser or cloud service.
- CalDAV/iCalendar/Radicale interoperability (evaluated, not implemented).
- Free x/y positioning of post-its.
- WYSIWYG Markdown editing or opening external links inside notes.
- Direct synchronization of the SQLite file between devices.
- Automatic conflict resolution for the same routine element.

## 14. Related documents

- [`DEVELOPMENT.md`](DEVELOPMENT.md) — build and test workflow.
- [`SYNC.md`](SYNC.md) — server integration and diagnostics.
- [`QUALITY.md`](QUALITY.md) — validation status and limitations.
- [Stick2Server](https://github.com/MikeMequis1/stick2server) — server
  implementation and deployment.
