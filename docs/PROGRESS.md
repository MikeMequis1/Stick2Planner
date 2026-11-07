**English** | [Português (Brasil)](PROGRESSO.pt-BR.md)

# Progress of the stages

## Stage 0 — Preparation (completed on 2026-10-31)

### Implemented

- Git repository initialized (`main`) with a commit of the original template and
  then a commit for this stage.
- Counter template removed (`test/widget_test.dart` deleted,
  `lib/main.dart` replaced).
- Dependencies added: `drift 2.35.3`, `sqlite3 3.8.0`,
  `path_provider 2.1.6`, `path 1.9.1`, `intl 0.20.3`, `uuid 4.6.0`,
  `flutter_localizations`; dev: `drift_dev 2.35.2`, `build_runner 2.17.1`.
- Minimal drift database (`AppDatabase`, schema v1) with the `app_settings`
  table (key/value) and a file connection via `path_provider`.
- Provisional Material 3 theme, pt_BR locale and a temporary screen.
- Android display name changed to **Planner**.
- Tests: home screen smoke test; in-memory write/read; file persistence across
  opening, closing and reopening the database.
- Documentation: `README.md`, `docs/DECISIONS.md`, this file.

### Commands run

```bash
git init -b main && git commit -m "chore: initial Flutter template"
flutter pub add drift sqlite3 path_provider uuid intl path
flutter pub add dev:drift_dev dev:build_runner
flutter pub add flutter_localizations --sdk=flutter
dart run build_runner build
flutter analyze
flutter test
flutter build apk --debug
```

### Results

- `flutter analyze`: no issues.
- `flutter test`: 3 tests, all passing, including in-memory SQLite and file
  persistence (`sqlite3` native hooks working on the Windows host).
- `flutter build apk --debug`: passed. Generated
  `build/app/outputs/flutter-apk/app-debug.apk`; Gradle automatically installed
  NDK 28.0.13004108, CMake 3.22.1 and Android SDK Platform 35 (required to
  compile SQLite via hooks). `assembleDebug` time: ~385 s on the first run.

### Changed files

- `pubspec.yaml`, `pubspec.lock`
- `lib/main.dart` (replaced)
- `lib/data/db/app_database.dart`, `lib/data/db/app_database.g.dart` (generated)
- `test/app_test.dart`, `test/data/db/app_database_test.dart`
- `test/widget_test.dart` (removed)
- `android/app/src/main/AndroidManifest.xml`
- `windows/flutter/generated_plugins.cmake` (regenerated)
- `README.md`, `docs/DECISIONS.md`, `docs/PROGRESS.md`

### Limitations and open items

- No functional interface; only a temporary screen.
- Provisional `applicationId`, awaiting a decision.
- Windows build not validated: Developer Mode disabled (required for plugins)
  and Visual Studio without the C++ workload; irrelevant for the Android target.
- No CI configured.
- Codegen must be run after schema changes.

### Next step

Stage 1 — foundation: `DateOnly`, `Clock`, entities, full schema with
migrations, repositories and domain/persistence tests. Awaiting approval to
start.

## Stage 1 — Foundation (completed on 2026-10-31)

### Implemented

- Definitive app identity: `com.mikemequis1.planner` (namespace,
  applicationId and `MainActivity` package); Windows window title updated to
  Planner.
- `DateOnly` (timezone-free calendar dates), `Clock`/`SystemClock`, pt_BR
  formatting with intl.
- Domain entities: `PostIt` (type, state, highlight, notes, interval, order,
  rollover, timestamps, tombstone), `Note`/`NoteLine` and
  `PostItHistoryEntry`.
- `ValidatePostIt` with typed errors (title, event without date, end before
  start, interval on task/recurring, highlight that is not an event).
- Drift schema v2 with `app_settings`, `notes`, `note_lines`, `post_its`,
  `post_it_history_entries`; indexes, foreign keys, `DateOnly` converter and
  v1 → v2 migration.
- Drift repositories: post-its (save with transactional history, batch, soft
  delete), notes (lines replaced in a transaction, soft delete unlinks post-its
  while preserving the excerpt) and preferences.
- `PlannerController`: selected date, per-orientation modes persisted, loading,
  counts, date filter (multi-day events), post-it validation. `NotesController`
  for the notebook.
- Composition (`AppDependencies`), injection (`AppScope`), Material 3 theme,
  adaptive navigation (rail on tablet, bottom bar on narrow screens) and
  overview screens.
- pt_BR texts centralized in `AppStrings`.

### Commands run

```bash
dart run build_runner clean
dart run build_runner build
flutter analyze
flutter test
flutter build apk --debug
```

### Results

- `flutter analyze`: no issues.
- `flutter test`: 43 tests passing, including the v1 → v2 migration with
  preferences preserved.
- `flutter build apk --debug`: passed (~19 s with cache), including the new
  applicationId.
- Coverage of the stage acceptance criteria: post-it and note CRUD via
  repository; order (`sortOrder`) and dates preserved after reopening the
  database; note↔post-it link persisted; mode/date preferences persisted;
  Agenda/Inbox/Notes tabs accessible in the rail and bottom bar.

### Main files

- `lib/core/`: `date_only.dart`, `clock.dart`, `date_formatting.dart`
- `lib/domain/`: entities, repositories and `validate_post_it.dart`
- `lib/data/db/`: `tables.dart`, `converters.dart`, `app_database.dart` (+ `.g.dart`)
- `lib/data/mappers/mappers.dart`, `lib/data/repositories/*`
- `lib/app/`: bootstrap, scope, controllers, theme, strings, view modes
- `lib/features/`: shell, planner, inbox, notes, shared
- `test/`: `core/`, `domain/`, `data/db/`, `app/`, `helpers/`
- `android/app/build.gradle.kts`, `MainActivity.kt`, `windows/runner/main.cpp`
- `README.md`, `docs/DECISIONS.md`, `docs/PROGRESS.md`

### Limitations and open items

- No calendar grid, visual creation/editing, drag or resize (Stages 2 and 3).
- Recurring TO-DO does not advance yet: modeling (`startDate`,
  `lastRolloverAt`) is ready, rule in Stage 4.
- Inbox and Notes are overview screens; filters/editor in Stages 4 and 5.
- Windows build not validated (environment without Developer Mode/C++ workload).
- Widget tests cover navigation and basic rendering; visual interactions and
  accessibility come in Stage 6.
- The drift warning about multiple instances in reopen tests is expected
  (distinct databases in sequence, closed before reopening).

### Next step

Stage 2 — visual agenda: period windows per orientation, day grid, post-its
with a continuous card for multi-day events and "+N" overflow. Awaiting
approval to start.

## Stage 2 — Visual agenda (completed on 2026-11-02)

### Implemented

- `AgendaViewMode` in the domain (day, 4 days, week, 2 weeks, month).
- `CalendarPeriod`: window derived from the selected date; week starting on
  Monday; two rows of 7 days; month in a dynamic grid of 35/42 cells with edge
  days; period navigation with day clamp in the month.
- `layoutEventSegments`: multi-day events become bars per grid row, with
  non-overlapping lanes, continuation at the ends and a lane limit with an
  overflow counter. Title appears once per period; the following segment shows
  "continues".
- Visual grid: weekday header, cells with the day number,
  selected/today highlight, post-it cards per day (symbols and state also by
  icon/strikethrough), "+N more" overflow and a sheet with the full list for the
  day.
- Multi-day event bar with unique identity (key per post-it + week),
  continuation ends and opening of the details sheet.
- Period toolbar: previous, next, "Today", `−`/`+` to adjust the number of days;
  preference persisted per orientation.
- Read-only details sheet (type, state, date/interval, details, note excerpt,
  linked note).
- Each page listens to its controller (`ListenableBuilder`), fixing the case
  where reused const widgets did not reflect date/mode changes.

### Commands run

```bash
flutter analyze
flutter test
flutter build apk --debug
```

### Results

- `flutter analyze`: no issues.
- `flutter test`: 70 tests passing (27 new: periods, bars, grid, navigation,
  overflow, orientation and data persistence).
- `flutter build apk --debug`: passed (~38 s).

### Criteria covered

- Seven days in one row, 14 in two rows, compact month 35/42 without truncating
  31 days; portrait with day/4 days/week.
- `+`/`−` and navigation without losing the selected date; mode and date
  persisted.
- Changing mode or orientation does not change data quantity, order or dates
  (widget test comparing IDs and selection before/after).
- Multi-day event is a continuous bar, not cards repeated per day; when
  crossing a week, the title is not repeated.
- Multiple post-its on the same day do not break the cell; "+N more" gives
  access to the full list.

### Main files

- `lib/domain/calendar/`: `agenda_view_mode.dart`, `calendar_period.dart`,
  `event_bar_layout.dart`
- `lib/core/date_formatting.dart` (+ period labels)
- `lib/features/planner/`: `agenda_page.dart` and `widgets/` (grid, row,
  cell, bar, card, toolbar, detail sheets)
- `lib/app/planner_view_mode.dart`, `lib/app/controllers/planner_controller.dart`
- `lib/features/shell/home_shell.dart`
- Tests: `test/domain/calendar_period_test.dart`,
  `test/domain/event_bar_layout_test.dart`,
  `test/app/calendar_view_test.dart`

### Limitations and open items

- No visual creation/editing, dragging, reordering or resizing
  (Stage 3). The details sheet is read-only.
- An event crossing a week is drawn as one segment per row, with the same
  ID; the title is not repeated, but the bar is physically interrupted by the
  line break.
- Events beyond the lane limit do not appear in the row; they remain
  accessible through the day list.
- No period transition animations and no full accessibility audit
  (Stage 6).
- No visual validation on a physical device in this stage; verification by
  widget tests at 1280×800, 800×1280 and 500×800 + APK build.

### Next step

Stage 3 — manipulation: creation/editing, drag between days, reordering,
resize handles with transactional persistence and accessible alternatives to
gestures. Awaiting approval to start.

## Stage 3 — Creation, editing and manipulation (implemented on 2026-11-02; awaiting review)

Status: implementation and automated tests complete; visual validation done
on a physical device. The stage **is not closed** until the open items listed
at the end are reviewed.

### Implemented

- Creation/editing form: task (title, optional details, single date or "No
  date"), event (required start/end, optional `+` highlight); recurring type
  locked until Stage 4.
- Domain validation translated into pt-BR messages; errors appear in the
  form and nothing is persisted when invalid. Event properties
  (interval/`+`) are normalized outside events.
- Details now offer explicit actions: edit, move to date, change
  duration (events), move up/down in order, delete with confirmation.
- Long-press drag moves tasks/events between days; events preserve the
  duration. Dropping a card onto another reorders; side handles (20 px, with a
  textual preview of the date) resize only the edge.
- `PlannerController` gained a mutation queue (`_exclusive`), transactional
  `saveBatch` in the repository, `sortOrder` normalization and history for
  creation, editing, movement, resizing, reordering and deletion.
- Soft delete keeps record/history; completion/cancellation and note links
  are preserved across edits.
- "New post-it" FAB in the agenda and details accessible by tap.
- Single-day events are now drawn in the event lane (bar), freeing the cell
  for tasks and allowing handles on any event.

### Commands run

```bash
flutter analyze
flutter test
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

### Automated results

- `flutter analyze`: no issues.
- `flutter test`: **99 tests passing** (29 new in this stage).
- `flutter build apk --debug`: passed.
- New coverage: creation/validation/editing, property normalization,
  moving task/event (including month rollover), resizing/clamp,
  reordering persisted after reopening, soft delete with history,
  serialization of concurrent operations, drag between days, reordering by
  drag and by menu, start/end handles, accessible date picker, editor with
  virtual keyboard and empty-title message.

### Validation on a physical device (2026-11-03)

Device: physical Android tablet, Android 16 / HyperOS 3.0, arm64,
2136×3200 at 440 dpi (776×1164 dp), system dark mode.

Successfully executed:

- APK installation. Normal `adb install` failed with
  `INSTALL_FAILED_USER_RESTRICTED` even with "Install via USB" enabled;
  installation worked using `adb install -r -i com.android.vending`.
- App launch, dark theme and tablet layout.
- Task creation through the form, with virtual keyboard and persistence.
- Long-press drag of the task from Tuesday to Thursday; UI and database
  confirmed `2026-11-05`.
- Multi-day event (data seeded in SQLite via `run-as` because full event
  creation through the form was not completed over `adb`) and
  resize via the end handle: end changed from `2026-11-05` to
  `2026-11-06`.
- Details sheet, visible actions, portrait mode (day) and compact month.
- Persistence after `force-stop` + reopening: task and event remained.
- Database verification via `run-as ... cat files/planner.sqlite` and
  `sqlite3` on the host.

Evidence: `docs/validacao/aparelho-tarefa-criada.png`,
`aparelho-arraste.png`, `aparelho-resize.png`, `aparelho-detalhes.png`,
`aparelho-retrato.png`, `aparelho-mes.png`.

Limitations: gestures were injected via `motionevent`, not by continuous
manual touch; stylus, multitouch, TalkBack and physical keyboard were not
tested. Event creation through the form was not completed on the device (the
flow is covered by widget tests and resize was validated with a seeded event).

### Problems found and fixed

- Resize handles appeared as white bands over the bar;
  now the touch area is transparent with a discreet grip and highlight only
  during the drag.
- In month mode, the compact height limits event lanes; overflow is
  indicated by "+N events" and remains accessible through the day list.
- The FAB can cover part of the footer on narrow screens; the grid was adjusted
  with bottom padding, but at 400 dp it is still close to the help text.

### Known limitations

- Dragging to days outside the visible period does not auto-scroll; in that
  case use "Move to date…". Documented in the interface/README.
- Events do not participate in `sortOrder` reordering (they follow the lane by
  date and lane); moving up/down is offered for tasks/recurring items.
- No undo after deletion (there is confirmation and a tombstone).
- No sync/recurring rollover: Stage 4.
- Month mode hides overflow bars behind the counter; the day list
  remains the complete source.

### Main files

- `lib/app/controllers/planner_controller.dart` (queue, CRUD, move, resize,
  reorder, history)
- `lib/domain/entities/post_it.dart` (`copyWith` with null clearing)
- `lib/domain/repositories/post_it_repository.dart` and
  `lib/data/repositories/drift_post_it_repository.dart` (`saveBatch`,
  delete with history)
- `lib/features/planner/widgets/`: `post_it_editor_sheet.dart`,
  `post_it_details_sheet.dart`, `post_it_drag_data.dart`, `day_cell.dart`,
  `week_row.dart`, `event_bar.dart`
- `lib/features/shell/home_shell.dart` (FAB), `agenda_page.dart`
- Tests: `test/app/post_it_operations_test.dart`,
  `test/app/editor_and_drag_test.dart`, adjustments in
  `test/domain/event_bar_layout_test.dart`
- Evidence in `docs/validacao/`.

### Open items for this stage (to close it)

Known items that still need a decision/implementation before
considering Stage 3 closed:

1. **Manual confirmation on device:** physical validation was done with
   gestures injected via `motionevent`. Still to confirm with real finger/stylus,
   multitouch, TalkBack active and external physical keyboard.
2. **Drag outside the visible period:** there is no auto-scroll or navigation
   during the drag. Today "Move to date…" must be used; decide whether
   that is enough or whether the drag should cross weeks/months.
3. **Event reordering:** up/down and `sortOrder` cover tasks and
   recurring items; events follow the lane by date/lane. Decide whether events
   also need manual order in the lane.
4. **"+N events" indicator in the month:** overflow events remain accessible
   through the day list, but the counter is not actionable. Evaluate turning it
   into a button with the week list.
5. **FAB on narrow screens:** at ~400 dp it is close to the footer; review
   position/size or move creation to the AppBar at that breakpoint.
6. **Persistence failure:** there is a test for validation failure and
   serialization, but a repository/database failure in the middle of an
   operation still needs to be simulated to validate rollback and visual
   feedback.
7. **Delete without undo:** there is confirmation and a tombstone, but no
   "Undo" action in the snackbar. Decide whether it belongs in this stage.
8. **Load/legibility:** many post-its (e.g. 100-200) still need to be measured
   in week/month mode on the tablet, and performance/overflow reviewed.
9. **Event created end-to-end on the device:** the form and date picker were
   inspected on the device; full event creation was covered only by
   widget tests (resize used a seeded event in the database).
10. **Finger/stylus gesture tests:** drag and resize were injected via
    `motionevent`; confirm feel/tolerance with real touch and stylus.

### Next step

Stage 4 — organization: states (complete/cancel without deleting), inbox with
filters/search, undated tasks and recurring TO-DO with idempotent daily
advance. Awaiting approval.

## Stage 4 — States, inbox and recurring TO-DO (implemented on 2026-11-03; awaiting review)

### Implemented

- Domain: `EnsureRecurringRollover` computes the pending advance → today,
  preserves future postponements and does not touch completed/cancelled items;
  returns updates and history in a batch.
- Controller: advance on startup, on `resumed` (observer) and before
  relevant operations; the `_exclusive` queue maintains idempotence/concurrency.
  `setPostItStatus` records `statusChanged`, reopens and reloads a late recurring
  item to today.
- Editor: third type "Recurring", without a required date; hint about the
  daily advance. Creating without a date uses today's local date.
- Agenda: completed items struck through with a check; cancelled with `X`;
  postponed items show a calendar icon + "postponed" label, distinct from the
  automatic advance.
- Details: explicit Complete/Cancel/Reopen actions, recurring chip
  ("Advances daily"/"Postponed until…") and an explanation that a postponed
  item resumes advancing if it remains pending.
- Inbox: full list with search (title/details/excerpt), All/
  Active/Completed/Cancelled/No date filters, sorting by date/updated/
  title and a quick state menu. Undated tasks appear in the list.
- Moving a recurring item: a future date becomes a postponement
  (`manualPostponed`); a past date normalizes to today; completing/cancelling
  stops the advance.

### Commands and results

```bash
flutter analyze
flutter test
flutter build apk --debug
adb install -r -i com.android.vending build/app/outputs/flutter-apk/app-debug.apk
```

- `flutter analyze`: no issues.
- `flutter test`: **123 tests passing** (24 new).
- `flutter build apk --debug`: passed (~15 s with cache).
- Installation on the physical device with the installer spoof workaround.

### Validation on the physical device (2026-11-03)

- Database seeded with a late recurring item (`02/11`), a postponed recurring
  item (`06/11`), an undated task, a completed task and a cancelled task.
- On opening the app, the late item was loaded to `03/11`, with **one**
  `rolloverAdvanced` record (`02/11 → 03/11`); the postponed one remained at
  `06/11`.
- Closing/reopening did not duplicate the advance (history still had 1 entry)
  and did not move the postponed item.
- Dark UI: "Done" struck through/checked, "Cancelled" with X, "Take medicine"
  with a repeat icon and "Stretch" with a calendar icon + "postponed".
- Inbox with 7 items, search, filter chips and sorting visible; dates,
  type and recurring state displayed below each card.
- `run-as` + `sqlite3` confirmed dates and history in the database.

Evidence: `docs/validacao/etapa4-recorrente-adiado.png` and
`docs/validacao/etapa4-caixinha.png`.

### Main files

- `lib/domain/usecases/ensure_recurring_rollover.dart`
- `lib/app/controllers/planner_controller.dart`
- `lib/features/planner/widgets/post_it_editor_sheet.dart`
- `lib/features/planner/widgets/post_it_details_sheet.dart`
- `lib/features/planner/widgets/post_it_tile.dart`,
  `day_cell.dart`, `week_row.dart`
- `lib/features/inbox/inbox_page.dart`
- `lib/features/shell/home_shell.dart` (lifecycle)
- Tests: `test/domain/ensure_recurring_rollover_test.dart`,
  `test/app/recurring_and_status_test.dart`,
  `test/app/inbox_and_recurring_test.dart`

### Open items and limitations

1. The advance does not use a timer: an app open across midnight only
   updates on the next `resumed`/relevant operation. This is intentional
   (requirement), but should be confirmed in review.
2. State actions on the device were covered by widget tests; physical
   validation focused on rollover, postponement and the inbox.
3. Creating a recurring item through the form was validated in a widget test;
   on the device, recurrence data was seeded to test the advance.
4. Inbox filters/search/sorting are not persisted across restarts.
5. No "Undo" after deletion; still confirmation + tombstone.
6. Gestures are still validated via `motionevent`; manual testing with finger,
   stylus and TalkBack is missing.
7. Load with 100–200 post-its and full accessibility remain for
   Stage 6.

### Next step

Stage 5 — private notes: notebook, lists, line/excerpt selection, creating a
post-it from the text and persisted links. Awaiting approval.

## Closing round for Stages 3 and 4 (2026-11-03)

### Resolved open items

- **Persistence/rollback failures:** repository decorator with simulated
  failure covers creation, editing, movement, resizing, reordering and
  deletion; memory and database remain equal. Real rollback tests use an invalid
  FK in history to prove the batch is reverted. Drag UI and form show a
  comprehensible error and keep the persisted state.
- **End-to-end events on the device:** created via the form:
  - common single-day event (`endDate` null);
  - common multi-day event (`03/11` to `05/11`);
  - single-day `+` highlight event (`is_highlight = 1`);
  - multi-day highlight event (`03/11` to `05/11`).
  All persisted and displayed as bars; validations and pt-BR pickers
  exercised.
- **Resize handles:** 24×24 dp logical `SizedBox`; verified on the device
  (66×66 px @440 dpi = 24 dp) and in a widget test. The visual grip remains
  discreet (2×12 dp).
- **"+N events":** now a button; opens the list of hidden events for the week,
  with date and access to details. Widget test + device verification.
- **FAB on narrow screens:** below 600 dp the FAB was replaced by a
  "+" icon in the AppBar. Compact bottom padding avoids covering content; a
  1000×1600 screen (≈364 dp) without layout overflow.
- **Load:** widget test with 200 post-its (tasks, simple and multi-day
  events) and a device test with 170 records. No freezing; adjustments
  made to eliminate overflow and preserve dates/counters in the compact month.
- **Undo deletion:** "Undo" snackbar restores the tombstone and records
  `restored` in history; controller and widget test.
- **Wakelock:** `wakelock_plus 1.8.2` + `WAKE_LOCK` permission; service isolated
  in `ScreenWakeService`, enabled at boot. The screen stayed on after 20 s with
  a 15 s timeout. An option to turn it off in settings is left for a future
  stage.

### Recorded decisions

- **Auto-scroll during drag:** not implemented in this round. "Move to
  date…" is deterministic, accessible and avoids conflicts; it remains a
  possible future evolution.
- **Manual event ordering:** not implemented. Start date + lanes
  suffice and avoid complexity with multi-day events.
- **Undo deletion:** implemented, as described above.

### Test results

- `flutter analyze`: no issues.
- `flutter test`: **138 tests passing**.
- `flutter build apk --debug`: passed (~15 s with cache).
- Load of 200 items in the widget test: first render between ~1.1 s and
  ~1.4 s on the host; no layout exception.
- Device load (170 items): cold start `am start -W` **2341 ms**;
  navigation and mode switching without freezing; frame samples ~12 ms
  (gfxinfo). In the high-density month mode, cells show a "+N more" and
  "+N events" summary instead of individual cards; dates remain legible.

### Complementary physical validation

- Common/highlight events and a recurring item created through the form,
  persisted in SQLite, surviving force-stop/reopening.
- Recurring UI: 1 instance, today's date, `created` history; no duplication.
- Virtual keyboard: form adjusts without overflow in the background agenda
  (`resizeToAvoidBottomInset: false`).
- Portrait/landscape, compact month, narrow screen via override and wakelock
  verified.
- Limitations retained: gestures injected via `motionevent`; no finger/stylus/
  TalkBack/external physical keyboard; recurrence creation via the form was
  validated, but the daily advance was observed with a seeded record in a
  previous round.

### Evidence

- `docs/validacao/round-evento-comum.png`
- `round-evento-comum-multidia.png`
- `round-evento-marcante-multidia.png`
- `round-evento-marcante-um-dia.png`
- `round-recorrente-ui.png`
- `round-eventos-ocultos.png`
- `round-carga-mes.png`
- `round-tela-estreita.png`

### Open items retained

- Auto-scroll and manual event ordering remain out (decision).
- Option to turn off wakelock in settings (future).
- Inbox filters are not persisted.
- Manual test with finger/stylus/TalkBack/physical keyboard missing.
- Dedicated optimization for many items is missing; it was not needed at this
  load.

### Next step

Stage 5 — private notes. Awaiting evaluation of this round; not started.

## Stage 5 — Private notes (implemented on 2026-11-03; Markdown adjustment)

### Implemented

- Independent notebook: note list, creation, editing and deletion with
  confirmation; title and two modes: Markdown text or list.
- **Text notes:** a single multiline Markdown field, with vertical expansion
  and syntax hints; accepts headings, bold, italic, ordered and unordered
  lists, links, paragraphs, line breaks and code blocks.
- **Lists:** keep the line-based editor with add, remove, move up/down and
  check items; order persisted by `position`.
- Text note details render formatted Markdown (without showing the raw
  syntax) and allow creating an excerpt post-it.
- List details keep selection by tapping one or more lines, with a stable
  bottom bar and the "Create post-it from excerpt" action.
- Conversion into a snapshot: `noteExcerpt` with the chosen text and `noteId`
  null; the post-it is created without a date, accessible from the inbox. The UI
  shows "Excerpt copied" and the snapshot warning.
- Live link: "Create task with this note" (whole note) and "Link to
  post-it…" choosing an existing task; "Open note" in post-it details and
  "Unlink note". The UI shows "Linked note" and records
  `noteLinked`/`noteUnlinked` in the post-it history.
- Deleting a linked note warns, removes the `noteId`s in a transaction and
  preserves tasks/snapshots; the note becomes a tombstone.
- Editing the note updates the live reference but does not change snapshots.
- Integration with post-it details in Agenda and Inbox.

### Model and decisions

- Drift schema **v3**: `notes.markdown` (nullable text) stores the full
  content of text notes; `note_lines` remains exclusive to lists.
- v2 → v3 migration converts the lines of `type='text'` notes into a single
  Markdown separated by `\n`, removes those lines and preserves lists.
- `Note.plainText` uses `markdown` for text and the lines for lists; serves as
  a fallback for legacy data.
- Rendering with `flutter_markdown_plus 1.0.12` (official `flutter_markdown`
  is discontinued). `softLineBreak: true` keeps the line break visible when
  pressing Enter, without requiring a blank line.
- Text snapshot uses a dialog with selectable raw Markdown: the user
  chooses the excerpt, or "Whole note" when there is no selection; the title is
  pre-filled with the note title.
- Live link and snapshot remain mutually exclusive: linking a note clears
  the `noteExcerpt`; copying an excerpt does not create a `noteId`.
- List selection remains by line/range; there is no substring within
  a line in this mode.
- Deleting a note does not delete post-its; it unlinks them and keeps the
  post-it's own content and snapshots.
- There is no note history table; link events are kept in the post-its'
  history. Note deletion has no "Undo" in this stage.

### Tests and results

- `flutter analyze`: no issues.
- `flutter test`: **158 tests passing** (6 new in this review).
- `flutter build apk --debug`: passed (~15 s with cache).
- New tests: Markdown creation/editing preserving formatting after reopening,
  legacy line fallback, v2 → v3 migration with text and checklist, creation of
  a Markdown note through the UI with formatted rendering and Markdown excerpt
  snapshot.
- Previous tests for list, snapshot, live link, unlink and deletion
  continue to pass.

### Physical validation

- Existing v2 database on the tablet migrated to v3: legacy text note
  (`Pao`, `Leite`) became `markdown = 'Pao\nLeite'`, `note_lines` became empty
  and `PRAGMA user_version = 3`.
- Markdown note created and edited on the device; bold, italic, list, heading
  and line breaks rendered correctly in the details.
- Markdown note snapshot persisted with null `note_id` and the excerpt selected
  in the dialog; "Whole note" also available.
- List created in List mode: `type = checklist`, `markdown` null, lines in
  order; selecting two lines showed "2 selected" and the create-post-it action.
- Existing note link remained visible in "Linked post-its" after the
  migration and editing.
- Screens verified on an Android tablet (3200×2136, 440 dpi, dark theme), with
  app restart to confirm persistence. Evidence:
  `docs/validacao/etapa5-markdown-editor.png`,
  `etapa5-markdown-detalhe.png`, `etapa5-markdown-snapshot.png` and
  `etapa5-lista-selecao.png`.

### Limitations

- Markdown links are rendered but do not open a browser in this stage (no
  external integration; the text remains selectable/copyable).
- The text snapshot is chosen in raw Markdown, not in the rendered text;
  this keeps the implementation simple and preserves the chosen syntax.
- Switching a note between Text and List converts the content (lines ↔ Markdown)
  and discards Markdown formatting; the action is intentional and has no undo.
- Selection in lists is by line/range, not substring within the line.
- A note has one link per post-it; linking another replaces the reference.
- Deleting a note removes live links without undo; snapshots remain.
- There is no search/sorting specific to the notebook in this stage.
- A snapshot is an intentional copy: editing the note does not update it.

### Next step

Stage 6 — quality and final documentation: completed in this round; see the
final section `Stage 6 — quality and delivery`.

## Adjustment round — Markdown, long press and agenda (2026-11-03)

### Markdown editor

- Toolbar above the text field with H1, H2, H3, bold, italic, bulleted list,
  numbered list, quote, link, inline code, code block and quick preview.
- Actions respect the selection: they wrap the chosen text or prefix the affected
  lines. H1/H2/H3 replace the previous level instead of accumulating `#`; numbered
  lists renumber the block.
- The field regains focus and selection after using the toolbar.
- Quick preview sits to the right of the field on wide screens (below on narrow
  screens), with Markdown rendering, its own scrolling and toggling via the eye
  button.

### Note selection

- List lines are now selected by **long press**, with haptic feedback; a simple
  tap does not select.
- The checkbox still checks/unchecks; the bottom bar, snapshot and live link
  are unchanged.
- Hints in the details and editor were updated to "Long press a line…".

### Agenda

- Period navigation and mode controls grouped in bordered capsules,
  "Today" separated by a divider and `+`/`−` icons aligned.
- Footer with an aligned hint icon and a "No date" count in a pill.
- Compact month cell with 1 px less internal padding to preserve at least
  one visible task alongside the overflow indicator when height is reduced.
- Visual changes only; gestures, rules and persistence remain the same.

### Tests and results

- `flutter analyze`: no issues.
- `flutter test`: **159 tests passing** (1 new in this round).
- `flutter build apk --debug`: passed.
- New test: Markdown toolbar applies H1 and bold, opens the preview and persists
  the content; a list test confirms that a simple tap does not select and a long
  press selects.

### Physical validation

- Markdown toolbar, preview and rendered details verified on the tablet.
- Long press on a list line showed "1 selected" and the create-post-it action;
  a simple tap did not open the selection.
- Agenda header, capsules, footer and grid verified on the tablet.
- Evidence: `docs/validacao/etapa5-markdown-barra.png`,
  `etapa5-markdown-previa.png`, `etapa5-selecao-toque-longo.png` and
  `rodada-agenda-cabecalho.png`.

### Limitations

- The toolbar inserts Markdown syntax; the editor is not WYSIWYG and the markers
  remain visible.
- The preview sits to the right of the editor on wide screens and stacked below
  on narrow screens; it is not a WYSIWYG editor.
- There is no toolbar-specific undo/redo; the system text field undo applies.
- Selecting lines requires a long press; a simple tap does not select (deliberate
  decision to avoid accidental selection).
- The agenda adjustments are visual and do not change shortcuts, drag or business
  rules.
- Previous limitations remain: links do not open a browser, text snapshot
  uses raw Markdown, one link per post-it, no note search/history.

## Gesture and visual adjustment round (2026-11-03)

### Editor preview

- On wide screens, the Markdown preview is **to the right** of the editing field,
  with the toolbar occupying the full width above both.
- On narrow screens, editor and preview are stacked.
- The panel has a minimum height of 320 px and its own scrolling up to 360 px;
  the field height follows the content.

### Event bars and agenda

- Event bar content got padding at the ends so it does not sit under the
  resize handles; the icon no longer coincides with the start of the bar.
- Resize handles became more visible (rounded grip) and keep a 24 px
  touch area.
- Dragging events and post-its starts after 200 ms, reducing the feeling of
  freezing without turning scrolling into accidental dragging.
- Header, footer and main spacings normalized to multiples of
  8 px; fine adjustments use multiples of 4 px.
- App now uses **edge-to-edge**: transparent status and navigation bars
  and the app background covering the usable screen area.

### Grid gestures

- **Single tap:** selects the day immediately.
- **Double tap:** opens task creation already with the date and Task type.
- **Triple tap:** opens event creation already with the date and Event type.
- **Long press:** opens a day preview window; releasing the finger closes
  the window. The preview lists up to four post-its and indicates the rest.
- The interval to chain 2/3 taps is 300 ms; day selection does not wait
  for that interval.

### Tests and results

- `flutter analyze`: no issues.
- `flutter test`: **163 tests passing**.
- `flutter build apk --debug`: passed.
- New tests: double tap opens a task and triple tap opens an event; long press
  shows a preview and releasing removes it; Markdown preview is to the right of
  the field; dragging the handle updates the bar width before releasing.

### Physical validation

- Markdown preview on the right verified on the tablet.
- Double tap opened "New post-it" in Task with the correct date; triple tap
  opened the same form in Event.
- Event bars with inset content and visible grips at the ends.
- Evidence: `docs/validacao/rodada-agenda-gestos.png`,
  `rodada-agenda-toque-duplo.png`, `rodada-agenda-toque-triplo.png` and
  `etapa5-markdown-previa-direita.png`.

### Limitations

- Double/triple taps open the creation form already configured; the post-it is
  only written on save, avoiding provisional titles.
- The three-tap sequence must occur within 300 ms.
- Multi-tap gestures are not triggered when the tap starts over a
  post-it; in that case the card takes precedence.
- The long-press preview closes only on release; it is not a modal window.
- The margin adjustment covers the main spacings; the grid keeps an optical
  gutter of 1.5 px between cells to preserve density in the month.
- Previous note, link and linking limitations remain.

## Agenda animations (2026-11-03)

### Implemented

- Day selection animates color, border, shadow and a more noticeable scale
  (180 ms, `easeOut`); the day number grows 15%.
- The cell under drag grows more (1.04) and the drop target gains animated
  border/shadow.
- Post-it cards and event bars shrink more on touch (0.93/0.97,
  110 ms).
- Drag feedback enters with scale (200 ms, `easeOutBack`) and elevation; the
  source card fades in 180 ms.
- **Resizing an event updates the bar width/position in real time**,
  with the active bar slightly enlarged (1.03), larger active handle and the
  date text switching with cross-fade.
- Resize preview and the "+N events" button enter with fade/scale.
- The period label slides + fades; the mode label uses fade + scale.
- When changing period or mode, the grid cross-fades with a subtle scale
  (0.98 → 1); data updates in the same period remain instantaneous.

### Limitations

- Continuous resizing follows the finger without easing on the width to avoid
  introducing delay; the movement is smoothed by the gesture frame itself.
- There is no explicit "reduce motion" preference; animations are short
  and do not block interaction.
- Animations do not change data, persistence or business rules.
- Evidence of live resizing:
  `docs/validacao/rodada-redimensionar-ao-vivo.png`.

## Stage 6 — quality and delivery (2026-11-03)

### Flicker fix

- Moving and resizing now apply an optimistic in-memory update before
  writing to the database. The bar immediately assumes the new date/duration;
  persistence remains transactional.
- On write failure, the previous state is restored and the error is raised to the UI.
- A test with a delayed repository proves that the state changes before
  `saveBatch` completes.

### Accessibility and layout

- Day cell exposes a semantic label with the full date, "today" and
  "selected", in addition to the tap action.
- Tests with text enlarged to 1.3× cover the agenda and the Markdown editor,
  without layout exceptions.
- Tooltips, post-it/event labels, 24×24 dp handles and gesture alternatives
  reviewed.

### Offline and consistency

- At that stage, a contract test confirmed that the Android manifest did not
  declare `INTERNET`. From Stage 5 on, the permission exists only for optional
  sync; the test was updated (no foreground service and no battery
  exemption).
- `docs/QUALITY.md` consolidates the validation matrix, accessibility,
  offline, consistency and known limitations.

### Tests and results

- `flutter analyze`: no issues.
- `flutter test`: **167 tests passing**.
- `flutter build apk --debug`: passed.
- Android tablet validated with the app installed; data restored after the
  manual resize test. Evidence: `docs/validacao/etapa6-agenda.png`.

### Final limitations

- No cross-device sync.
- Markdown links do not open a browser.
- Text snapshot uses raw Markdown.
- One note link per post-it; no undo for note deletion.
- No "reduce motion" preference.
- No search specific to the notebook.
- 1.5 px optical gutter in the month grid.

### Next step

Stage 6 MVP complete. Awaiting final evaluation; no later stage
was started.

## Post-it navigation and future architecture (2026-11-03)

### Implemented navigation

- New `AppNavigationController` shares the current section between the shell and
  pushed routes.
- Single helper `openPostItDetailsById` finds the post-it by UUID, selects the
  Agenda, returns from the note route when necessary and opens the existing
  details.
- Post-its with a live link appear in "Linked post-its"; snapshots with
  `sourceNoteId` appear in "Excerpts from this note".
- Each item has two buttons: "View details" opens the popup in place; "Open in
  Agenda" selects the date and highlights the post-it temporarily. The Agenda
  button is disabled when there is no date.
- The highlight lasts 4 s and combines a primary border, 1.05 scale and elevation.
- Tapping the Markdown content or a list line opens the editor; long press
  keeps selecting lines for a snapshot.
- Inbox: the `...` menu gained "Open in Agenda" only for post-its with a date;
  complete/reopen/cancel actions remain the same.
- A missing UUID shows a warning and does not create a post-it.
- Agenda: horizontal swipe pages through the period with a slower page
  animation (520 ms, 3D rotation); vertical swipe morphs (fade + scale
  0.92 → 1, 360 ms) when increasing/reducing the days.
- Sidebar: rail with a minimum width of 88 dp and the full height of the shell.
- Settings: System/Light/Dark theme, four gradient palettes
  (Green, Ocean, Sunset and Lavender), animations, keep screen on and agenda
  hints, persisted in `app_settings`.

### Model and compatibility

- Schema v4 adds `post_its.source_note_id` (nullable), provenance metadata for
  the snapshot; it is not a live link.
- v3 → v4 migration preserves snapshots and only adds the column.
- Old snapshots have no provenance and remain accessible from the Inbox.

### Interoperability (documented, not implemented)

- Drift/SQLite remains the primary source and offline use.
- Future backup/restore in a dedicated JSON with UUIDs, history, snapshots,
  links and metadata.
- Radicale/CalDAV/iCalendar as an interoperability layer (`VEVENT`,
  `VTODO`, `X-*`), without discarding data from the internal model.
- Eventual own sync service with outbox, versioning,
  tombstones, ETags and conflicts.
- No `caldav` dependency, server, export or import was
  added in this round.

### Tests and results

- `flutter analyze`: no issues.
- `flutter test`: **182 tests passing**.
- `flutter build apk --debug`: passed.
- New tests: navigation by live link, navigation by snapshot, missing UUID,
  "Open in Agenda" option with/without date, menu preservation, horizontal
  period gesture, vertical days gesture and settings.
- v3 → v4 migration covered.
- Tablet validation: two buttons per post-it in the note, temporary focus in the
  Agenda, settings screen and page/period gestures. Evidence:
  `docs/validacao/rodada-nota-acoes-postit.png`,
  `rodada-foco-postit.png` and `configuracoes.png`.

### Next step

Awaiting evaluation. Interoperability/sync belongs to a future stage not yet
started.

## i18n, performance and delivery (2026-11-03)

### Identity

- App renamed to **Stick2Planner**; Dart package `stick2planner`.
- Android `applicationId` preserved as `com.mikemequis1.planner`, to avoid
  creating a new app or losing data.
- README rewritten in a shorter and more direct form.

### Language

- Portuguese (BR) / English preference in Settings, persisted in
  `app_settings`.
- Interface texts are now resolved at runtime by `AppStrings`;
  dates use `DateFormats.locale` and patterns specific to each language.
- MaterialApp switches `locale`, `supportedLocales` and theme without restarting
  the app.

### Palettes and performance

- Four gradient palettes: Green, Ocean, Sunset and Lavender.
- The shell background uses the palette gradient; a transparent Scaffold reveals
  the background without duplicating surfaces.
- **Debug** build measured: ~188 MB. Release split per ABI: ~19–22 MB
  (`arm64` ~21 MB). The size observed on the tablet was the debug APK.
- Local database measured: ~80 KB for 17 post-its, 3 notes and 58 history
  records; there is no abnormal growth per record.
- The animated grid was wrapped in a `RepaintBoundary`; main animations
  respect the "Animations" option and can be disabled.
- Fixed the `AnimatedSwitcher` key: the key now sits on the `RepaintBoundary`
  (direct child), restoring horizontal paging and vertical morphing.
- Events can be dragged between visible weeks; at the grid edges,
  "previous/next week" zones move the event by ±7 days and take the selection
  to the new date.
- The long-press preview now follows the finger: when sliding over other
  visible days, it shows the date and post-its of the cell under the finger.
- In 2 weeks and month, the entire row of each week became a drop target:
  dropping onto the event lane of another week moves the post-it to the day under
  the finger. Before, only day cells accepted drops, so the lane with bars was
  a void.

### Validation

- `flutter analyze`: no issues.
- `flutter test`: **182 tests passing**.
- `flutter build apk --debug`: passed.
- `flutter build apk --release --split-per-abi`: passed
  (armeabi-v7a 18.8 MB; arm64 21.0 MB; x86_64 22.4 MB).
- Android tablet: release installation, theme/language/palettes and navigation
  verified.
- Environment reduced to a physical device: AVD `planner_tablet`, system image
  android-35 x86_64 and the SDK `emulator` package removed from disk; no
  emulator configuration remained in the project.

## Backup and restore (2026-11-04)

### Format

- Versioned JSON (`formatVersion` 1) generated by `BackupDocument`, with
  `schemaVersion`, `appVersion`, `exportedAt`, optional `deviceId`, counts and
  checksum.
- SHA-256 checksum over canonical JSON (`core/canonical_json.dart`): sorted
  keys, integers only, literal UTF-8, lists in deterministic order.
- Exports post-its (including tombstones), notes, lines/checklists, history and
  UI preferences. `planner.sync.*` keys and credentials are left out.
- Import accepts `formatVersion` 1 and `schemaVersion` 4 or 5; versions 3 or
  earlier and 6 or higher are rejected with a specific message.

### Import

- Single mode: replace all data, with explicit confirmation.
- Automatic snapshot at `<app support>/backups/pre-import-*.s2p.json`,
  verified by reopening and checksum before any write; retention of 5
  files.
- Applied in one transaction (`notes → note_lines → post_its → history`), with
  duplicate ID, FK and type validation before writing.
- Settings lists local snapshots (up to 3) and allows restoring; restoring
  creates a new snapshot first.
- After importing: agenda, notes and preferences reloaded.

### Files

- `core/canonical_json.dart`, `core/app_info.dart`
- `data/backup/backup_document.dart`, `backup_service.dart`,
  `backup_file_gateway.dart`
- `features/settings/settings_page.dart` ("Backup and restore" section)
- `app/bootstrap.dart`, `app/app_scope.dart`, `app/app.dart`
- `test/core/canonical_json_test.dart`, `test/data/backup_service_test.dart`,
  `test/app/backup_test.dart`

### Validation

- `flutter analyze`: no issues.
- `flutter test`: **195 tests passing** (13 new).
- `flutter build apk --debug`: passed.
- `flutter build apk --release --split-per-abi`: passed
  (armeabi-v7a 19.0 MB; arm64 21.1 MB; x86_64 22.5 MB).
- Physical tablet test pending: the device was not connected to `adb` in this
  round; the file picker still needs to be exercised manually.

## Sync server — initial audit (2026-11-04)

Read-only survey via SSH, with no changes to the machine:

- Ubuntu 26.04.1 LTS, kernel 7.0, x86_64, 2 vCPU, 3.3 GiB RAM, 5.3 GB free.
- Docker 29.9.2 and Compose v5.6.1 installed; 6 active containers (ports 3000,
  8080, 8081, 8082, 9000).
- Tailscale active at `IP-do-host-no-Tailnet`; LAN at `IP-do-host-na-LAN/24`.
- Port **8090** free for the Planner service; UFW absent/inactive.
- `sudo` requires a password; privileged operations depend on the user.

## Stage 2 — local sync foundation (2026-11-04)

- Schema **v5**: `sync_outbox`, `sync_row_states`, `sync_states`; migration
  tested from a v4 fixture with data preserved.
- Outbox records the entity's full state in canonical JSON, coalesces by
  `(entity, entityId)` and is written **in the same transaction** as the
  repositories (post-it, note, history, deletions).
- A note is an atomic unit (lines/checklists in the payload); a post-it is
  individual; history is append-only. Preferences and credentials stay local.
- Deleting a note enqueues the note and the unlinked post-its.
- `SyncApplyService` applies remote changes without generating outbox entries
  and records the server revision per entity.
- `SyncStateStore` keeps `deviceId`, cursor, server, last sync and error.
- Importing a backup discards old outbox/revisions/cursor, keeping deviceId and
  the server configuration.

Files: `data/db/tables.dart`, `app_database.dart`, `data/sync/*`,
`data/repositories/*`, `test/data/sync_outbox_test.dart`,
`test/data/migration_v5_test.dart`.

## Stage 3 — server and initial deploy (2026-11-04)

- Independent Dart package in `server/`: shelf, SQLite, per-device tokens,
  single-use pairing, per-entity revision, idempotence and cursor.
- Endpoints: `/v1/health`, `/v1/sync`, `/v1/pair`, `/v1/admin/*`.
- Server tests: 10 cases (auth, pairing, idempotence, conflict,
  pagination, revocation, validation and limits).
- Multi-stage Dockerfile with `dart build cli` (sqlite3 build hooks) and a
  Debian slim non-root image; Compose on port **8090** with named volume
  `planner-data` and healthcheck.
- Deployed at `diretório-do-servidor` on the Ubuntu 26.04 machine; container
  `stick2planner-api` healthy and reachable on the LAN.
- Smoke test: health 200, pairing 200, sync 200, revocation 200 and
  post-revocation sync 401. No token was printed.
- `sudo` is not available without a password; firewall and TLS via Tailscale are
  pending user action.

## Stage 5 — configuration, pairing and status (2026-11-04)

- "Sync" section in Settings: server address, save, test
  connection, enable automatic, sync now, pair and disconnect.
- Pairing via server JSON/code or QR (`mobile_scanner`); token goes
  to `flutter_secure_storage`, never to the database/backup/logs.
- `SyncCoordinator` keeps URL, enabled, deviceId, pending items, last sync,
  report and error; the manual button uses the same engine as Stage 4.
- Disconnecting clears token and URL and disables automatic sync.
- Android: `INTERNET`, `ACCESS_NETWORK_STATE`, `CAMERA` (optional) and
  `usesCleartextTraffic` for a server on the LAN; the app remains offline-first.
- Offline contract test updated: internet exists only for optional sync;
  no foreground service and no battery exemption request.

## Stage 6 — automation and cross-device validation (2026-11-04)

- Triggers: local change (outbox watch + 2 s debounce), app resume,
  reconnection (`connectivity_plus`), manual button and periodic WorkManager
  (15 min, network-restricted, best-effort).
- Sync never blocks the UI; failures become state/error and the outbox remains.
- WorkManager runs in its own isolate with database + secure token; without a
  configured server, the task simply ends.
- Cross-device tests with an in-memory server: convergence, conflict
  with copy and local win with resend.
- Build warning: `workmanager_android` plugin still applies KGP; it works today,
  but will require an update when Flutter migrates to Built-in Kotlin.
- Larger release because of the QR reader's ML Kit (~24.7/28.5/30.8 MB).

## Exposure via Tailscale (2026-11-04)

- Host `host-do-servidor` in the Tailnet `tailnet.example.ts.net`.
- tsdproxy 1.4.7 healthy exposing homepage, portainer, filebrowser, it-tools,
  ports and tsdproxy over HTTPS (all tested with 200).
- Planner exposed as `planner`: labels `tsdproxy.enable/name/container_port` and
  `tsdproxy.ephemeral=false`.
- `https://planner.tailnet.example.ts.net/v1/health` returns 200; sync without a
  token returns 401.
- Server `PUBLIC_URL` points to the HTTPS URL.
- First authorization of the `planner` node was manual; state is kept in the
  `tsdproxy_data` volume.
- The tablet still had no Tailscale: it kept syncing through the USB tunnel
  (`127.0.0.1:8090`). For wireless use, install Tailscale on the tablet or move the
  tablet to the server's LAN.
- Tailscale installed on the tablet: the USB tunnel was removed and sync started
  using `http://IP-do-host-no-Tailnet:8090` (host IP in the Tailnet) as an
  initial test.
- MagicDNS did not resolve because of the tablet's private DNS (AdGuard DoT).
  Changed to "Automatic/opportunistic", the name started resolving; the URL was
  changed to `https://planner.tailnet.example.ts.net` via pairing and
  HTTPS sync works (tsdproxy logs: `/v1/pair` and `/v1/sync` 200).
- Test post-its confirmed on the server after unplugging the cable.
- The URL field in Settings now follows external changes
  (pairing/disconnection), avoiding showing an old address.
- Phone layout adjusted: in landscape (height < 520 dp) the agenda bar
  fits on one line, "Today" becomes an icon, hints/chip disappear and the FAB
  becomes compact; in portrait the hint takes 2 lines. Tests cover 780×360 and
  360×780.
- "About" texts updated: sync is optional, not "no sync in this version".

## Inbox and clarity of the sync flow (2026-11-05)

- The Inbox no longer reserves 72 px for a FAB that only exists in the Agenda; the
  list got the full height (the empty footer space disappeared).
- Filters moved to a horizontally scrollable strip, saving one line in
  portrait and two more on narrow screens.
- Sync settings now explain the order ("1) test, 2) pair, 3)
  sync"), show "Paired · N pending" and make clear that testing does not
  pair and that sync/automatic only enable after pairing.
- Full flow documented in `docs/SYNC.md`.

## Navigation and sync refinements (2026-11-05)

- 4-day mode now anchors the window: tapping another visible day moves only the
  selection, without rebuilding the grid; arrows/gesture shift exactly 4 days and
  preserve the selection offset. "Today" reanchors when necessary.
- Descriptive texts removed from the sync card. Address and connection test
  moved to the dedicated **Connection** screen
  (`connection_test_page.dart`), with inline result.
- Cloud icon at the top reflects the state (not paired, syncing, error,
  pending, up to date) and opens Settings scrolled to sync.
- The top "+" appears in Agenda and Inbox and is hidden in Notes; the Agenda
  keeps the FAB on wide screens.
- `flutter test`: 237 tests passing.

## Pairing web page (2026-11-05)

- `GET /` on the server shows administrative login (`ADMIN_TOKEN`) and, once
  authenticated, a page with a live pairing QR, textual code, devices and
  revocation.
- QR generated as SVG on the server itself (`qr` package), without depending on
  `qrencode`/external images; renewed every 4.5 min while the page is
  open, with a 5 min TTL.
- In-memory sessions with `HttpOnly`/`SameSite=Strict` cookie; `/api/pairing`
  and `/api/devices` APIs require a session.
- The `pair` CLI command remains available.
- Server tests cover login, QR, session, devices and revocation
  (12 tests in total).
- Device name comes from the Android model (`device_info_plus`) on the next
  pairing; existing devices can be renamed on the web page
  (`POST /api/devices/<id>/label`).


## Stage 4 — sync engine in the app (2026-11-04)

- `HttpSyncTransport`: `/v1/sync`, `/v1/health` and `/v1/pair`, with timeout,
  error classification (retryable for network/5xx/429) and Bearer token.
- `SyncEngine`: sends the outbox, applies pull, resolves conflicts and keeps the
  cursor in the same local transaction as applying the changes.
- Ack only removes the outbox entry if the `changeId` is still the same; if there
  was an edit during the push, it only aligns `baseRev`.
- Conflict: compares `updatedAt`; tie and identical content → server wins.
  Server wins → applies version and creates a `[Conflict] …` copy of the local
  content (note copies lines with new IDs). Local wins → updates
  `baseRev` and resends once; a second conflict becomes a copy.
- A server tombstone with local content creates a copy before applying the
  deletion; a local tombstone does not create a copy.
- `SyncController` exposes `idle/running/success/failure`, last report and error,
  ignoring concurrent calls.
- Transport failure keeps outbox and cursor; failure applying the pull undoes
  ack and cursor in the same transaction.

Files: `data/sync/sync_models.dart`, `sync_transport.dart`,
`sync_engine.dart`, `app/controllers/sync_controller.dart`,
`test/data/sync_engine_test.dart`, `test/app/sync_controller_test.dart`.

## Clear settings, About and bilingual web page (2026-11-05)

### Settings

- Sections renamed to make their scope explicit: "Appearance and language",
  "Agenda behavior", "Connection and sync" and "Backup and restore".
- More direct items: "App theme", "Interface language", "Accent color and
  background", "Animations and transitions", "Show gesture hints in the
  agenda", "Automatic sync", "Pair this device" and "Disconnect
  from this server".
- The old About section became a navigation item to its own screen.

### About screen

- New `features/settings/about_page.dart` with name, installed version read from
  `package_info_plus` (`0.1.1`), short description and links to the repository and
  MikeMequis1's GitHub profile.
- Links open in the browser via `url_launcher`; failure shows a snackbar. Android
  manifest gained an explicit query for `https` intents.
- Widget test covers version, description and both links.

### Server web page

- Login and panel now have a **Português/English** button with dynamic switching,
  without reloading; the choice is stored in `localStorage` and the initial
  language follows the browser (Portuguese fallback).
- Translation covers fixed texts, QR count, device states,
  rename/revoke buttons, rename prompt and invalid token message.
- The HTML keeps Portuguese text as fallback; JavaScript switches to
  English when selected.
- Server tests verify the presence of the selector, the English dictionary and
  the `data-i18n` attributes on login and panel.

### Documentation

- README, `docs/DECISIONS.md`, `docs/QUALITY.md`, `docs/SYNC.md` and
  `server/README.md` reviewed to reflect sync, backup, web page, About,
  phone layout and current state.
- Removed outdated statements ("no sync", "About without
  sync in this version", "INTERNET absent", "future stage not started").

### Validation

- `flutter analyze`: no issues.
- `flutter test`: **238 tests passing**.
- `dart analyze` / `dart test` on the server: no issues; **12 tests passing**.
- Release installed on the phone; Settings and About screens verified.

## Sync review, ADMIN_TOKEN and documentation cleanup (2026-11-05)

### Check before sync

- `GET /v1/sync/stats` on the server returns counts of active post-its, notes,
  events, tasks and history.
- The app counts the same local set and compares before syncing. When both
  sides have data and the post-it/note/event/task counts
  diverge, sync stops on the first sync or when there is no pending outbox, and
  shows a local × remote table.
- The confirmation offers **Keep local**, **Keep remote** or **Cancel**.
  Keep local sends the local snapshot via `POST /v1/sync/replace` (the server
  tombstones what does not exist on the device); keep remote downloads
  `GET /v1/sync/snapshot` and replaces the local content. History is preserved
  as an audit trail in local mode.
- Automatic sync does not decide on its own: it stays in "Review required", the
  cloud changes state and the user confirms in Settings → Review now.
- The dialog uses a table with counts; tests cover divergence detection,
  keep local, keep remote and the UI flow.

### ADMIN_TOKEN and documentation

- New command `dart run bin/server token` generates a random value for
  `ADMIN_TOKEN` (alternative: `openssl rand -hex 32`).
- `docs/SYNC.md` documents the complete process: generate, write to
  `.env`, recreate the container and query the value.
- Removed personal configuration references from the documentation: public domain,
  LAN/Tailnet IPs, host, deploy directory and device names. Only
  generic placeholders remain.
- `server/.env.example` and the pairing example use a generic address;
  `docker-compose.yml` no longer loads proxy/Tailscale-specific labels.
- `server/README.md` explains the difference between `ADMIN_TOKEN` and a device
  token and the optional exposure via LAN/VPN/proxy.

### Web page

- Compacted landscape layout: two columns for wide and short screens (up to
  700 px height), reduced QR and, at heights ≤ 480 px, hiding the auxiliary
  text to fit better. Portrait remains as it was.

### Validation

- `flutter analyze`: no issues.
- `flutter test`: **264 tests passing**.
- `dart analyze` / `dart test` on the server: no issues; **15 tests passing**.
- Server rebuilt and `GET /v1/health` responding; release installed on the
  phone.

## Pairing state and backup counts (2026-11-05)

- Cloud updates on pair/disconnect: the coordinator clears pending error/report,
  writes/clears the device label and notifies the shell immediately.
- The server now returns `deviceLabel` in `/v1/sync/stats`; the app persists
  the label locally and updates it after a rename on the web page.
- The **Pair this device** button is disabled when a token already exists and
  the card shows **Paired: <device name>**.
- Backup/export counts ignore items with `deletedAt`: deleting all
  notes/post-its zeroes the displayed counts. The JSON still stores the
  tombstones and history; old backups with legacy counts remain
  accepted.
- `flutter test`: **264 tests passing**; server: **16 tests passing**.

## Event recurrence and Pending label (2026-11-05)

- The editor's third type is now labeled **Pending** (`Pendência` in Portuguese);
  the internal `recurringTodo` identifier and daily rollover behavior are
  unchanged.
- Events gained a repeat option: daily, weekly (every N weeks), monthly (every N
  months) and yearly. Occurrences preserve the event duration and are expanded
  only for the visible calendar period.
- Recurring occurrences share the series ID; tapping opens the series for
  editing. Drag and resize are disabled on generated occurrences to avoid
  accidentally moving the series anchor.
- Schema v6 adds `recurrence` and `recurrence_interval` to `post_its`, with a
  migration from v1–v5. Sync payloads and JSON backups carry the fields; older
  payloads/backups default to no recurrence.
- The event details sheet shows a repeat summary chip.
- Added domain tests for daily/weekly/monthly/yearly expansion and a widget test
  for the weekly editor flow.

## Sync server moved to stick2server (2026-11-06)

- Server source, Dockerfile, Compose files, tests and documentation now live in
  the public [MikeMequis1/stick2server](https://github.com/MikeMequis1/stick2server)
  repository.
- GitHub Actions publishes the image to GHCR as
  `ghcr.io/mikemequis1/stick2server:latest` (multi-arch amd64/arm64), plus
  version and commit tags.
- The Compose file in that repository pulls the `latest` image by default;
  `docker-compose.build.yml` remains available for local builds.
- The `server/` directory was removed from this app repository and links were
  updated to the new repository.
- Both `Stick2Planner` and `stick2server` are public; the app README links the
  source repository and the server README links the app repository.

## Calendar, time, tags and completion (2026-11-06)

- Past days use a muted gray tint in every calendar view, while today and future
  days keep the normal surface; the day header uses a muted foreground.
- Events accept an optional time stored as minutes from local midnight. It is
  shown on the event bar and inbox tile, never substituted for dates/timestamps.
- Shared tags (name + palette tone) can be created, edited and deleted; deletion
  removes associations without deleting post-its. Tags are assigned in the editor
  and shown in details, inbox rows and the Inbox tag filter.
- Schema v7 adds `post_its.time_minutes`, `post_its.tag_ids` and the `tags` table.
  Sync payloads/backups carry the fields; old payloads/backups default to no time,
  no tags and no recurrence.
- Type selection uses icons; the former highlighted event is now **Done/feito**
  with a pencil icon and an info dialog.
- Events with an `endDate` before today are automatically marked done on startup,
  resume, refresh and before mutations, with a single `eventCompleted` history
  entry. Events without an end date are unchanged.
- The task details title icon toggles done/reopen immediately.
- `flutter test`: **264 tests passing**; server: **16 tests passing**.

## Palette, type descriptions and event preview (2026-11-06)

- `AppPalette` now offers eight tones: the original Green, Ocean, Sunset and
  Lavender plus Rose, Teal, Sand and Graphite. Each keeps a three-stop light/dark
  gradient and derives all component colors from its Material 3 seed, so user
  data and already-assigned item colors are untouched.
- Type selection shows one shared description card under the chips. Task, Event,
  Pending and Feat descriptions follow the previous Pending card style and update
  with the selected type; Feat reuses the positive-moments help text.
- The long-press day preview now resolves items through `itemsCoveringDate`, so
  tasks and events share the same rows, type label and optional time. The gesture,
  filters and item IDs are unchanged.
- The former **Done/feito** label is now **Feito** (PT-BR) and **Feat** (EN).
- `flutter test`: **268 tests passing**; server: **16 tests passing**.
