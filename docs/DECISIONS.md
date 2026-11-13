**English** | [Português (Brasil)](DECISOES.pt-BR.md)

# Technical decisions

Record of approved decisions and the constraints that apply to the next
stages. Each item: context, decision, consequence.

## Architecture

- **Context:** offline-first app, tablet-first, with future synchronization on a
  self-hosted server on the local network.
- **Decision:** layers `features` (UI) → `app` (controllers/composition) →
  `domain` (entities + use cases) and `data` (drift) implementing domain
  interfaces. State via `ChangeNotifier` exposed by a single `AppScope`;
  no Riverpod/Bloc in the MVP.
- **Consequence:** business rules testable without Flutter; no empty network
  abstraction. Future synchronization enters as an additional implementation of
  the repositories plus conflict resolution, without rewriting the UI.

## Local database

- **Decision:** drift + SQLite.
- **Rationale:** relationships (post-it ↔ note ↔ history), transactions
  to move/reorder/resize, queries by date/state, versioned migrations and
  tests with an in-memory database. `sqflite` would require manual mapping and
  migrations; `isar`/ObjectBox/Hive do not offer the same relational
  support.
- **Consequence:** codegen mandatory (`dart run build_runner build`).

## Application identity

- **Decision:** `applicationId` / `namespace` `com.mikemequis1.planner`; display
  name Stick2Planner.
- **Consequence:** defined before real data existed. Changing the
  `applicationId` later creates another app and loses the local database; the
  display name can change without affecting the data.

## Dates and IDs

- **Decision:** calendar dates use `DateOnly` (no time, persisted as
  `yyyy-MM-dd`); audit timestamps use UTC in milliseconds; IDs are
  UUID v4.
- **Consequence:** no time zone/DST shift in schedule rules; injectable `Clock`
  for deterministic tests (no `DateTime.now()` in the domain).

## Post-it model

- A single `post_its` table with `type` (`task`, `event`, `recurringTodo`),
  `status` (`active`, `done`, `cancelled`), `isHighlight` (symbol `+`),
  `details`, `noteId` + `noteExcerpt`, `startDate`/`endDate`, `recurrence` +
  `recurrenceInterval`, `sortOrder`, `createdAt`/`updatedAt`, `deletedAt`.
- Simple and detailed tasks share the same type: a filled `details` field
  characterizes the detailed one. Events require a date; range and `+` are
  normalized/validated only for events.
- **Order, not coordinates:** there is no free x/y position. The layout is
  responsive and ordered by `sortOrder` per day; absolute coordinates would
  break readability in another orientation. Events use their own lanes and do
  not enter the ordering of task cards.
- **Color is not data:** colors derive from type/state and always come with an
  icon, symbol or label.
- **Deletion:** completing/cancelling never deletes; permanent deletion writes a
  tombstone (`deletedAt`), preserving history and preparing for sync.

## Types and validation

- Task: title required; details and single date optional; no range
  and no `+` marking (normalized by the controller and refused by validation).
- Event: date required; end ≥ start; `endDate` equal to the start is
  normalized to `null` (single-day event); `+` allowed.
- Recurring: no range; type locked on edit until Stage 4.
- Domain errors (`PostItValidationError`) are translated to pt-BR messages
  in the form; saving only happens after validation.

## Desktop targets

- **Context:** the same planner must run on Windows and Linux without forking
  the Dart UI, business rules, drift schema or Android behaviour.
- **Decision:** desktop is an additional Flutter target. A small
  `core/platform_support.dart` exposes runtime capability checks; only optional
  native integrations are conditional. Post-its/events use
  `LongPressDraggable` on touch and plain `Draggable` on desktop. Dialogs and
  bottom sheets get desktop width limits; the native runners set the initial
  and minimum window sizes. Data continues in `getApplicationSupportDirectory()`
  with the existing `planner.sqlite` file and schema v9.
- **Consequence:** no data migration and no duplicate persistence layer.
  `mobile_scanner` and `workmanager` remain Android-only at runtime and are
  hidden/disabled on desktop. Windows keeps the legacy `Runner.rc` company name
  so the application support directory is not moved. Packaging scripts only
  bundle release output; they never strip runtime libraries.

## Moving, reordering and resizing

- Dragging the body uses `LongPressDraggable` on touch (avoids accidental drag
  while scrolling) and immediate `Draggable` on desktop; cells and cards are
  `DragTarget`s.
- Moving an event preserves `durationInDays`; moving a task changes the single
  date. Reindexing of source/destination and history are written in one
  transaction (`saveBatch`).
- Reordering within the same day accepts a destination index; the order is
  renormalized (`sortOrder` 0..n-1) and persisted.
- Event side handles (20 px, with textual preview) change only the
  extremity; the body continues to move the event. Only the real ends of the
  event receive handles (continuation segments do not).
- Accessible alternatives: move to date, change duration via selectors,
  move up/down in order, edit and delete with confirmation.

## Write consistency

- All `PlannerController` mutations go through a queue (`_exclusive`),
  serializing rapid drags/edits.
- In-memory state is only updated after the database commit; a validation or
  persistence failure keeps the last consistent view.
- History and multiple changes use drift's `saveBatch`/transactions.

## Multi-day events — continuous card

- **Approved decision:** an extended event is **a single continuous post-it**
  between days, not repeated cards.
- **Implementation consequence (Stage 2/3):** all events (including
  single-day ones) are drawn in the events lane, never as a task card.
  The grid uses one lane per week row; the event becomes a segment with the
  same ID, continuation ends and a title shown only once per visible
  period; if it crosses the week break, the next segment shows "continues"
  instead of repeating the entire card. Dragging the body moves the entire
  range; dragging the handles changes only the corresponding extremity.

## Recurring TO-DO

- UI label: **Pending**. The internal type remains `recurringTodo`; only the
  user-facing name changed.

- A single row; never generates copies. Pending and with a null/overdue date →
  `startDate = local today`. Recalculation is absolute and idempotent; running it
  several times neither duplicates nor advances beyond what is necessary.
- Implemented in `EnsureRecurringRollover` (pure domain), which only updates
  `startDate`/`lastRolloverAt` and records `rolloverAdvanced` in the history;
  identity, title, details, note and state are preserved.
- Executed at boot, on lifecycle `resumed` and before schedule operations. No
  continuous timers and no background service. Closed for several
  days → jumps straight to the current day on the next opening.
- Completed/cancelled stops advancing and remains in the inbox. Reopening an
  overdue recurring item reloads it to today.
- **Manual postponement:** dropping on a future date fixes the date and suspends
  advancing until it; dropping on a past date/today normalizes to today. The
  history receives `manualPostponed`; the card shows a calendar icon + "postponed"
  (text, not just color), and the detail explains that it resumes advancing if it
  remains pending.
- The "Recurring" type in the editor does not ask for a date; the current date is
  derived from today, without duplicating the record.

## States and inbox

- `status` (`active`, `done`, `cancelled`) never implies deletion. Completing
  strikes through the card; cancelling shows `X`; both remain in the database and
  in the history. Reopening returns to active (an overdue recurring item reloads to
  today).
- State actions are in the detail (accessible) and in the inbox menu; changing
  state does not alter date, order or link.
- The inbox lists all post-its (with and without date), with filters by state and
  "no date", search in title/details/excerpt and sorting by date,
  update or title.
- State is independent of temporal position; dragging does not change status.

## Failures, rollback and consistency

- Writes go through drift transactions; `saveBatch` writes post-its + history
  atomically. A failure in any item reverts the batch.
- The controller only updates memory after the commit (`_reload`); validation or
  repository failure keeps the UI in the last persisted state.
- Operations are serialized by a queue; errors reach the UI as a snackbar/form
  message.
- Tests cover simulated failures in creation, editing, moving,
  resizing, reordering and deletion, plus rollback due to an invalid FK.

## Handles and accessibility

- Interaction area of **24×24 logical dp** in Flutter (not physical pixels),
  with a 2×12 dp visual grip. The event body remains the movement
  target; the handle only resizes.
- On narrow screens (<600 dp), the "+" is in the AppBar in the Schedule and
  Inbox sections and is absent in Notes; on wide screens the Schedule keeps the
  extended FAB and the Inbox uses the AppBar "+".

## Additional events in the month

- "+N events" is a button; it opens a sheet with the events that did not fit in
  the week lanes, with dates and access to details.
- The month remains a compact view; tasks that do not fit use "+N more"
  and open the day's list when the cell is tapped.

## Decisions from this round

- **Auto-scroll while dragging:** postponed. The "Move to date…" action covers the
  case and avoids interaction risks; it can be reevaluated after real use.
- **Manual ordering of events:** not needed. Organization by start date and
  lanes is sufficient; manual order conflicts with multi-day events.
- **Undo deletion:** implemented with the existing tombstone; snackbar
  "Undo" restores and records `restored` in the history.
- **Screen on:** `wakelock_plus` enabled by default during use, isolated in
  `ScreenWakeService`; the option "Keep screen on during use" allows
  turning it off. Preference persisted in `app_settings`.

## Notes

- **Model v3:** text notes store the full content in
  `notes.markdown`; list notes store ordered items in `note_lines` and
  leave `markdown` null. The UI keeps the Text and List modes.
- **Migration v2 → v3:** the lines of `type='text'` notes are merged into a single
  Markdown (`\n`), those lines are removed and the lists remain intact. The
  `Note.plainText` fallback covers old data without losing content.
- **Markdown:** `flutter_markdown_plus 1.0.12`, because `flutter_markdown` is
  discontinued. The detail renders the formatting; `softLineBreak: true` treats
  Enter as a visible break, keeping paragraphs separated by a blank line.
- **Quick bar:** above the Markdown field there are shortcuts for H1/H2/H3, bold,
  italic, lists, quote, link, inline code, code block and preview. The
  actions operate on the selection or the current line; headings switch level instead
  of accumulating `#`.
- **Quick preview:** on wide screens it is to the right of the field; on narrow
  screens, stacked below. It has a minimum height of 320 px, its own scrolling up to
  360 px and is a check, not a WYSIWYG editor. There is no separate undo/redo —
  it uses the system field's undo.
- **Line selection:** requires a long press (with haptic feedback), avoiding
  accidental selection while scrolling or tapping the checkbox. A single tap does not
  select; the bottom bar and the snapshot remain the same.
- **Text snapshot:** dialog with the raw Markdown selectable and a filled
  title; without a selection, it uses the entire note. The snapshot is a literal copy of the
  excerpt, including the chosen Markdown syntax.
- **List snapshot:** selection by tapping one or several lines, as before.
- **Snapshot:** `noteExcerpt` with `noteId = null`; editing the note does not change the
  copied text. The UI marks "Excerpt copied".
- **Live link:** `noteId` (reference to the entire note); the UI marks "Note
  linked" and offers "Open note". Linking clears the previous snapshot.
- **Deletion:** the note becomes a tombstone; when deleting a linked note, the
  post-its' `noteId` are removed in the same transaction, preserving title,
  details and snapshots. The UI warns before the action.
- Notes do not have their own history table; link changes are
  recorded in the post-it history (`noteLinked`/`noteUnlinked`).

## Calendar

- Landscape: week, two weeks, compact month.
- Portrait: day, four days, week.
- **Header:** navigation and mode controls in separate visual capsules,
  with `+`/`-` icons, "Today" and a divider; layout only, no rule changes.
- **Date gestures:** one tap selects; two taps open task creation;
  three open event creation; a long press opens a floating preview that
  closes on release. The chaining of multiple taps uses a 300 ms window.
- **Preview follows the finger:** during the long press, moving the finger over other
  visible days updates the date and the preview's post-its. The gesture stays pinned to the
  source cell, so cells register their geometry in a
  `DayPreviewRegistry` per grid; the rectangle under the finger defines the displayed date.
- **Events across weeks:** a normal drag reaches any visible week,
  including dropping on the events lane (lanes) of another week — the
  week row is a `DragTarget` that converts the horizontal position into column/day. At the
  grid edges, zones appear to move ±7 days and update the selected
  date.
- **Finger position on drop:** `DragTargetDetails.offset` brings the anchored
  feedback corner, not the touch. `PostItDragData.anchorOffset` records the anchor
  at the start of the drag to recover the real point and choose the right column.
- **Transitions:** the `AnimatedSwitcher` key stays on the direct child
  (`RepaintBoundary`), guaranteeing horizontal page turning and vertical morphing.
- **Event bars:** the content is inset from the handles so the icon does not sit under
  the start; the handles have a visible grip and 24×24 dp of touch. The drag starts after
  200 ms, avoiding the feeling of freezing without dragging by accident.
- **Frame:** app in edge-to-edge with transparent status/navigation bars;
  main spacings in multiples of 8 px and fine adjustments in multiples of
  4 px. The grid keeps an optical gutter of 1.5 px between cells to preserve the
  month's density.
- **Motion:** selection and drag target use scale/color/shadow; cards and
  bars react to touch; drag feedback uses `easeOutBack`; horizontal period
  page-turns with 3D rotation (520 ms) and the vertical day change uses
  fade + scale morphing (360 ms). Resizing follows the finger in real
  time. The highlighted post-it uses a border, 1.05 scale and elevation for 4 s.
- **Settings:** screen with System/Light/Dark theme, four gradient
  palettes (Green, Ocean, Sunset and Lavender), animations, keep screen
  on and schedule tips. Preferences live in `app_settings`; turning off
  animations zeroes the main transitions and the page turning/morphing. Access to
  synchronization is under "Connection and synchronization" and "About the app" opens
  a screen with version, description and links.
- In the compact month, the cell's internal padding is reduced to preserve at
  least one visible task along with the overflow indicator.
- The selected date is the anchor. Previous/next moves the selection by one period
  (1, 4, 7, 14 days; month with day preserved and clamped). In 4-day mode the
  window starts at the selected date and remains anchored when tapping another
  visible day; navigating shifts the entire window by 4 days and preserves the offset.
- Compact month: dynamic grid of 35 or 42 cells depending on the month, including
  dimmed edge days; never truncated to 30 days.
- Changing mode or orientation does not alter the date, order or any data; only
  a viewing preference.
- Many post-its: limit per cell + a "+N" indicator opening the day.

## Event recurrence (schema v6)

- Events can repeat daily, every N weeks, every N months or yearly.
  `recurrence` and `recurrenceInterval` live on the post-it; tasks and pending
  items never carry a recurrence.
- Occurrences are virtual copies generated for the visible period, keeping the
  series ID and duration. The base event is the first occurrence.
- Monthly/yearly occurrences use calendar arithmetic with day clamping (31 Jan →
  28/29 Feb; leap day → 28 Feb in non-leap years).
- Drag and resize are disabled on generated occurrences to avoid moving the
  series anchor; tapping opens the series and the editor changes the rule.
- Schema v6 migrates v1–v5; old sync payloads/backups without the fields default
  to `none`/`1`.

## Event time, tags and completion (schema v7)

- Event time is optional `timeMinutes` (0–1439), local wall-clock; not a UTC
  timestamp and not used for ordering.
- Tags are a shared table (`id`, `name`, tone, timestamps) and `post_its.tag_ids`
  stores the associations. A tag deletion is a tombstone plus association removal,
  never a post-it deletion.
- Tags use `ColorScheme` roles/containers so their colors follow the active
  palette in light/dark themes.
- Active events with an `endDate` before today become done automatically; the
  check is idempotent and records one `eventCompleted` history entry. Events
  without an end date keep the previous behavior.
- The task title icon in details toggles done/reopen without leaving the sheet.
- Schema v7 migrates v1–v6; old payloads/backups default to no time, no tags and
  no recurrence.

## Type descriptions and day preview

- The editor shows one shared description card for the selected post-it type,
  styled like the former Pending help card; Feat reuses the positive-moments text.
- The long-press preview reuses the existing overlay/registry and resolves items
  with `itemsCoveringDate`, so events join tasks with the same row format. Event
  rows keep the type label and optional time.
- New palettes are additive enum values; the persisted setting remains the palette
  name, so existing selections are unaffected.
- Soft tag tones use a lighter accent over the surface, keeping all six selector
  swatches visually distinct from their solid counterparts.
- The Inbox keeps the tag selection at the top, with a manage/new-tag button and
  empty states for no tags, no tag matches and no search results.
- Long-pressing an Inbox row opens a tag selector; it is a focused update
  (`setPostItTags`) that keeps every other field untouched.
- Tag tones are limited to five; schema v8 rewrites legacy `tertiarySoft` tags to
  `tertiary`, keeping the hue instead of dropping the tag.

## Routines and notifications (schema v9)

- Routines are stored locally (`routines`, `routine_items`,
  `routine_completions`) and synchronized as one atomic `routine` entity.
  Completion is keyed by `routine_item_id + date`, so each occurrence has an
  independent state; no global completion flag.
- `post_its.reminder_minutes` stores the lead time; reminders require
  `time_minutes` and an active item. Re-scheduling cancels and rebuilds the local
  notification set, avoiding duplicates and dropping resolved/past items.
- Android notifications use `flutter_local_notifications`. The small icon lives
  in `res/drawable/ic_stat_planner.xml` and is pinned with `res/raw/keep.xml`
  because resource shrinking otherwise removes it and the plugin throws
  `invalid_icon`.
- Scheduling prefers exact alarms (`exactAllowWhileIdle`) when authorized and
  falls back to `inexactAllowWhileIdle`. The manifest declares both
  `SCHEDULE_EXACT_ALARM` and `USE_EXACT_ALARM`; the latter is auto-granted on
  Android 13+ but restricted by Play policy to alarm/calendar-centric apps.
- Settings exposes a test action that posts one immediate notification and one
  scheduled 10 seconds later, so channel, permission and scheduler can be
  validated independently of real reminders.
- Windows and tests are no-ops. Daily summaries are scheduled for the next seven
  days at 08:00.
- The navigation shell now has one adaptive surface: landscape rail with
  Config/Sync pinned at the bottom and a six-action bar in portrait.
- Routines are not part of sync or JSON backups yet; post-it reminders are
  carried in both.

## Routine creation date and list interactions

- `createdAt` is the routine's creation instant and is never recalculated on
  edit. Occurrences are anchored to its local calendar date (`createdOn`);
  `runsOn` refuses earlier dates. This is deliberately separate from the weekly
  scheduling days and from any future configurable start date.
- Routine sync sends the original `createdAt` in the payload; merges never use
  server receipt time for creation. Deletion is a tombstone and the workbook of
  activities/completions travels inside the same entity.
- Servers below 0.2.2 do not accept the entity; the app keeps routine changes in
  the local outbox and continues syncing the other entities until the server is
  updated.
- Reordering is handle-only (`ReorderableDragStartListener`) so text fields,
  checkboxes, horizontal day navigation and drag do not fight for the same
  gesture. Routine cards persist immediately; existing notes and routines also
  autosave the new order when the drag ends, while brand-new drafts still use the
  Save action.
- Deleting a list item requires a continuous long press with a circular
  confirmation. Releasing early cancels; no extra dialog is shown because the
  gesture is already deliberate.
- The routine screen reuses the Agenda's visual language (day strip, active
  palette cards, compact typography) without copying calendar-specific features.
- Note excerpt selection uses an explicit mode: a long press enters it, taps
  toggle lines, and a close button leaves it. This keeps tap-to-edit available
  while selection is off and avoids accidental editor openings while selecting.
- No schema migration was required: `createdAt` already existed from v9.

## Localization

- **App:** Portuguese (BR) and English, persisted in `app_settings`. `AppStrings`
  resolves texts at runtime and `DateFormats.locale` chooses the date
  patterns, with no external service and no app restart.
- **Server web page:** Portuguese and English, with dynamic switching on the client
  (without reloading), persisted in `localStorage` and applied to texts, states,
  QR count and device actions. The HTML keeps a Portuguese fallback
  for browsers without JavaScript.

## Navigation between notes, inbox and schedule

- **Shared section:** `AppNavigationController` keeps the shell's current section
  and allows stacked routes (note detail) to return to the Schedule.
- **Opening by UUID:** a single helper finds the existing post-it, opens the same
  detail/edit and does not create a copy. If the UUID does not exist, it shows a warning and does not
  navigate.
- **Notes:** post-its with a live link (`noteId`) and snapshots with provenance
  (`sourceNoteId`) listed in the note detail have two actions: "View details"
  (popup in place) and "Open in Schedule" (selected date + temporary highlight).
- **Editable content:** tapping the rendered Markdown or a list line
  opens the note editor; the long press remains reserved for line selection.
- **Inbox:** the `...` menu shows "Open in Schedule" only when
  `startDate != null`; the status actions remain unchanged.
- **Schedule gestures:** horizontal drag turns the period page with a page
  transition; vertical drag increases/reduces the number of days.
- **Sidebar:** rail with a minimum width of 88 dp and the full height of the
  shell, with no empty strip at the edges.
- **Snapshot provenance:** `sourceNoteId` is origin metadata for
  navigation; it is not a live link, does not change the snapshot and does not prevent the note from
  being edited/deleted. Snapshots prior to the v4 migration have no provenance.

## Language, performance and size

- **Language:** Portuguese (BR) and English, persisted in `app_settings`.
  `AppStrings` resolves texts at runtime; `DateFormats.locale` chooses the
  date patterns. No external service and no app restart.
- **Palettes:** six gradients (Green, Ocean, Sunset, Lavender, Rose, Graphite)
  combined with light/dark; the seed color still comes from Material 3.
- **Performance:** the split release build is the reference. Debug loads runtime and
  symbols (~188 MB); arm64 release ~21 MB. Main grid in
  `RepaintBoundary`; animations can be turned off in Settings.
- **Data:** compact SQLite (~80 KB for 17 post-its, 3 notes and 58 history
  records). History is kept for auditing, not by duplicating events.
- Lean README; historical details live in `docs/PROGRESS.md`.

## Validation environment

- **Physical device only**, via `adb` (Android 16 tablet / HyperOS 3.0).
  There is no AVD, system image or `emulator` package installed; nothing in the project
  depends on the emulator.
- Gestures can be injected with `adb shell input`/`motionevent` on the device
  itself; the release build is the reference for smoothness and size.
- On HyperOS/MIUI, install with `adb install -r -i com.android.vending` when the
  direct install is blocked.

## Interoperability, backup and synchronization

**Status:** backup and synchronization implemented (Stages 1–6). CalDAV/iCalendar
remains as future interoperability; there is no public account nor multiuser.

### Configuration, pairing and automation

- Server URL in `sync_state`; individual token in `flutter_secure_storage`.
- Administrative web page on the server: login with `ADMIN_TOKEN`, pairing QR
  renewed while open, list/revocation of devices. The temporary token is never
  persisted on the client; the QR contains the JSON accepted by the app.
  The page switches Portuguese/English on the client and persists the choice in the browser.
- Settings separates the sync state from the address actions: the card shows
  "Paired/Not paired", pending items, last sync and error; the address and the connection
  test are on the **Address and connection test** screen. The cloud icon at the
  top reflects the state and opens the section already focused.
- The **About** screen reads the package version (`package_info_plus`), shows a short
  description and opens the repository and the GitHub profile (`url_launcher`).
- Web session in memory (HttpOnly/SameSite=Strict cookie), separate from the device
  tokens.
- The `pair` CLI remains for automation and diagnostics.
- Device name uses the Android model (`device_info_plus`) and can be
  corrected/renamed on the web page (`POST /api/devices/<id>/label`), without
  needing to re-pair.
- Pairing via JSON/QR generated on the server, with a single-use token (TTL 5 min);
  each device receives its own token, revocable on the server.
- Triggers: local change (outbox watch + debounce), resume, reconnection,
  manual button and periodic WorkManager (15 min, best-effort, network-restricted).
- Before applying, the app queries `/v1/sync/stats` and compares it with the local
  counts. If both sides have data, the counts diverge and this is the first
  sync or there is no pending outbox, the operation stops and asks for a choice: keep local
  (sends the local snapshot and a tombstone for what only exists on the server), keep
  remote (replaces the local content with the remote snapshot) or cancel. Automatic sync
  never decides on its own: it stays in "Review required" until the user's
  choice.
- Sync failure does not block the UI; state and error are visible in Settings.
- `INTERNET`/`ACCESS_NETWORK_STATE` were added only for optional sync;
  cleartext is accepted for a self-hosted server on the LAN/Tailscale.
- A conflict copy is the last resort to avoid losing content; the winner is
  resent once with `baseRev` aligned.

### Local database as the main source

- Drift/SQLite remains the application's source of truth.
- Planner must continue to work fully offline.
- The SQLite file must not be synchronized directly between devices.
- The local architecture must not be replaced by a server-dependent
  solution.

### Backup and restore in a proprietary JSON format

- Versioned JSON format (`formatVersion` 1) with `schemaVersion`, app version,
  export date, counts and SHA-256 checksum over canonical JSON.
- Canonicalization: keys ordered by code units, integers only, literal UTF-8,
  lists in deterministic order (UUID, note+position, date+UUID).
- Exports post-its, notes, lines, history, tombstones and UI preferences;
  credentials and `planner.sync.*` keys never enter the file. The document's counts
  consider only active items (without `deletedAt`), although the backup
  continues to preserve tombstones and all history. Old backups with
  legacy counts continue to be accepted.
- Import replaces all data, with explicit confirmation, in a single
  transaction and after a verified automatic snapshot (retention of 5).
- Compatibility: accepts `formatVersion` 1 with `schemaVersion` 4 or 5; refuses
  0/2+ and schemas ≤ 3 or > 5. Each accepted version has a tested upgrader.
- Snapshots and restore live in the app's private directory; the screen offers
  restoring a snapshot, which generates another before applying.
- External formats (iCalendar/CalDAV) remain outside the main backup.

### Interoperability: Radicale, CalDAV and iCalendar

- **Radicale** is the reference for a lightweight, open-source CalDAV server, runnable
  via Docker; image considered: `ghcr.io/kozea/radicale:stable`.
- **CalDAV** (RFC 4791) is the communication/synchronization protocol.
- **iCalendar** (RFC 5545) is the interoperability format.
- Planned mapping: events → `VEVENT`; tasks → `VTODO`; specific
  properties → `X-*`.
- Radicale is an interoperability layer, not a replacement for the local
  database nor a full Planner synchronization.
- Recurrences with their own rollover, Markdown, checklists, snapshots, history,
  links and ordering may have no equivalent in iCalendar. Internal data
  must not be discarded to fit the standard.
- Documentation: <https://radicale.org/>, <https://github.com/Kozea/Radicale>.
- The Dart package `caldav` can be evaluated in a future prototype, but it is not
  an approved dependency without real compatibility tests with Radicale.

### Possible self-hosted synchronization service

Implemented in the separate [stick2server](https://github.com/MikeMequis1/stick2server) repository (shelf + SQLite), with no
Flutter dependency:

- opaque entities with a monotonic `rev` per item, change log with `seq` and
  pull cursor;
- local coalescing outbox, with `changeId` for idempotency;
- tombstones transported in the payload;
- conflict by `baseRev`: the server returns the current version and the client resolves
  by `updatedAt` (conflict copy + resending the winner in Stage 4);
- individual tokens per device, revocable, stored as SHA-256;
- pairing via single-use token (QR content), TTL of 5 min;
- body/payload/batch size limit and constant-time token comparison;
- backup import discards local outbox/cursor and preserves configuration.

### Conflicts and consistency (implemented)

- Push compares `baseRev` with the current revision; divergence returns the server
  version, without applying.
- The winner is the highest `updatedAt`; tie or identical content → server.
- Server wins → version applied and local content preserved as
  `[Conflict] <title>` (new UUID; note copies lines with new IDs).
- Local wins → `baseRev` aligned and single resend; residual conflict becomes a copy.
- Deletion: a server tombstone generates a copy of the local content; a local tombstone
  does not generate a copy.
- Ack removes the outbox only if the `changeId` remains the same; editing during
  the push only updates `baseRev`.
- Pull, ack, revisions and cursor are written in a local transaction; failure undoes
  everything. A network failure keeps the outbox and cursor intact.

### Local synchronization foundation (schema v5)

- `sync_outbox`: complete canonical payload, `base_rev`, `change_id`, attempts and
  error; coalescence by `(entity, entity_id)`.
- `sync_row_states`: server revision applied per entity.
- `sync_states`: `device_id`, cursor, server, enabled, last sync/error.
- Drift repositories write the outbox in the same transaction; remote application uses a
  separate path and does not feed the queue back.
- A note is the atomic unit (lines/checklists in the payload); history is
  append-only; preferences/credentials do not sync.


### Scope

Implemented: self-hosted server in the [stick2server](https://github.com/MikeMequis1/stick2server) repository, pairing by QR/code, individual
revocable tokens, manual/automatic sync, administrative web page in
Portuguese/English and JSON backup. Still out of scope: public account,
multiuser and CalDAV/iCalendar.

## Out of scope in the MVP

- Public account, multiuser and CalDAV/iCalendar (future interoperability).
- Free positioning of post-its.
- WYSIWYG editor for Markdown and opening external links inside notes.
- Selection of arbitrary substrings in lists (MVP: line or range; in text
  notes the snapshot uses selection in the raw Markdown).

## Optimistic consistency and final quality

- **Move/resize:** in-memory state is updated before the database to
  avoid flicker; `saveBatch`/`save` remain transactional and the previous state is
  restored on failure.
- **Accessibility:** days have a full label, "today/selected" states and a tap
  action; texts enlarged 1.3× are validated in the schedule and notes.
- **Offline:** the app opens and operates without a server; `INTERNET` and
  `ACCESS_NETWORK_STATE` exist only for optional synchronization. The data
  remain in local SQLite.
- **Delivery:** `docs/QUALITY.md` concentrates the validation matrix, limitations and
  final criteria.

## Pending decision

None at the moment.
