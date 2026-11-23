# Contributing

Stick2Planner is a Flutter application with an optional sync server kept in a
separate repository. Changes should preserve offline-first behavior: the app
must remain fully usable without a server, account or network.

## Before you start

1. Check the working tree with `git status` and keep unrelated local changes.
2. Read [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the layer and data
   model boundaries.
3. Follow [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md) to set up the toolchain.

## Change checklist

- Keep business rules in `lib/domain/` and platform I/O in `lib/data/` or
  `lib/app/services/`.
- Preserve the existing layering: `features` → `app` → `domain`; `data`
  implements domain interfaces.
- Do not hand-edit generated files such as `lib/data/db/app_database.g.dart`.
  Change the table definitions and run:

  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```

- A schema change requires:
  - an incremental migration in `lib/data/db/app_database.dart`;
  - a migration test from the previous schema;
  - backup import compatibility (`supportedBackupSchemaVersions`);
  - updated documentation if the data model or limitations change.
- A sync contract change requires checking the compatible Stick2Server version
  and the server repository. The server stores payloads opaquely; do not make the
  app depend on server-side field interpretation.
- Keep user-visible strings in `lib/app/app_strings.dart` with both Portuguese
  and English variants.
- Never commit tokens, `.env` files, database files, build output or personal
  data from a device.

## Validation

Run at least:

```bash
flutter analyze
flutter test
```

Add or update tests for the behavior you changed. A build is not a substitute
for a test, and a passing widget test is not manual device validation. Record any
manual validation separately.

For sync changes, also run the server checks in the
[stick2server](https://github.com/MikeMequis1/stick2server) repository:

```bash
dart analyze
dart test
```

## Commits and pull requests

- Use focused commits with the repository's conventional prefixes, for example
  `feat:`, `fix:`, `docs:` or `refactor:`.
- Explain user-visible behavior and any migration or compatibility impact.
- Do not rewrite or force-push shared history.
- Do not commit generated build artifacts under `dist/` or `build/`.
- Documentation changes should keep the README as an entry point and put
  technical detail in `docs/`.
