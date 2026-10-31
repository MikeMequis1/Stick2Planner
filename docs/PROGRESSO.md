# Progresso das etapas

## Etapa 0 — Preparação (concluída em 2026-10-31)

### Implementado

- Repositório git inicializado (`main`) com commit do template original e,
  em seguida, commit desta etapa.
- Template do contador removido (`test/widget_test.dart` excluído,
  `lib/main.dart` substituído).
- Dependências adicionadas: `drift 2.35.3`, `sqlite3 3.8.0`,
  `path_provider 2.1.6`, `path 1.9.1`, `intl 0.20.3`, `uuid 4.6.0`,
  `flutter_localizations`; dev: `drift_dev 2.35.2`, `build_runner 2.17.1`.
- Banco drift mínimo (`AppDatabase`, esquema v1) com tabela `app_settings`
  (chave/valor) e conexão em arquivo via `path_provider`.
- Tema Material 3 provisório, locale pt_BR e tela temporária.
- Nome de exibição Android alterado para **Planner**.
- Testes: smoke da tela inicial; gravação/leitura em memória; persistência em
  arquivo entre abertura, fechamento e reabertura do banco.
- Documentação: `README.md`, `docs/DECISOES.md`, este arquivo.

### Comandos executados

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

### Resultados

- `flutter analyze`: sem issues.
- `flutter test`: 3 testes, todos aprovados, incluindo SQLite em memória e
  persistência em arquivo (hooks nativos do `sqlite3` funcionando no host
  Windows).
- `flutter build apk --debug`: aprovado. Gerou
  `build/app/outputs/flutter-apk/app-debug.apk`; o Gradle instalou
  automaticamente NDK 28.0.13004108, CMake 3.22.1 e Android SDK Platform 35
  (necessários para compilar o SQLite via hooks). Tempo do `assembleDebug`:
  ~385 s na primeira execução.

### Arquivos alterados

- `pubspec.yaml`, `pubspec.lock`
- `lib/main.dart` (substituído)
- `lib/data/db/app_database.dart`, `lib/data/db/app_database.g.dart` (gerado)
- `test/app_test.dart`, `test/data/db/app_database_test.dart`
- `test/widget_test.dart` (removido)
- `android/app/src/main/AndroidManifest.xml`
- `windows/flutter/generated_plugins.cmake` (regenerado)
- `README.md`, `docs/DECISOES.md`, `docs/PROGRESSO.md`

### Limitações e pendências

- Interface funcional inexistente; apenas tela temporária.
- `applicationId` provisório, aguardando decisão.
- Build Windows não validado: Developer Mode desabilitado (necessário para
  plugins) e Visual Studio sem o workload C++; irrelevante para o alvo Android.
- Sem CI configurada.
- Codegen precisa ser executado após alterações de esquema.

### Próximo passo

Etapa 1 — fundação: `DateOnly`, `Clock`, entidades, esquema completo com
migrações, repositórios e testes de domínio/persistência. Aguardando
aprovação para iniciar.

## Etapa 1 — Fundação (concluída em 2026-10-31)

### Implementado

- Identidade definitiva do app: `com.mikemequis1.planner` (namespace,
  applicationId e pacote do `MainActivity`); título da janela Windows
  atualizado para Planner.
- `DateOnly` (datas de calendário sem fuso), `Clock`/`SystemClock`,
  formatação pt_BR com intl.
- Entidades de domínio: `PostIt` (tipo, estado, marcante, notas, intervalo,
  ordem, rollover, timestamps, tombstone), `Note`/`NoteLine` e
  `PostItHistoryEntry`.
- `ValidatePostIt` com erros tipados (título, evento sem data, fim antes do
  início, intervalo em tarefa/recorrente, marcante que não é evento).
- Esquema drift v2 com `app_settings`, `notes`, `note_lines`, `post_its`,
  `post_it_history_entries`; índices, chaves estrangeiras, conversor
  `DateOnly` e migração v1 → v2.
- Repositórios drift: post-its (salvar com histórico transacional, lote,
  exclusão lógica), notas (linhas substituídas em transação, exclusão lógica
  desvincula post-its preservando o trecho) e preferências.
- `PlannerController`: data selecionada, modos por orientação persistidos,
  carregamento, contagens, filtro por data (eventos multi-dia), validação de
  post-it. `NotesController` para o caderno.
- Composição (`AppDependencies`), injeção (`AppScope`), tema Material 3,
  navegação adaptativa (trilho em tablet, barra inferior em telas estreitas)
  e telas de visão geral.
- Textos pt_BR centralizados em `AppStrings`.

### Comandos executados

```bash
dart run build_runner clean
dart run build_runner build
flutter analyze
flutter test
flutter build apk --debug
```

### Resultados

- `flutter analyze`: sem issues.
- `flutter test`: 43 testes aprovados, incluindo migração v1 → v2 com
  preferências preservadas.
- `flutter build apk --debug`: aprovado (~19 s com cache), incluindo o novo
  applicationId.
- Cobertura dos critérios de aceitação da etapa: CRUD de post-it e nota via
  repositório; ordem (`sortOrder`) e datas preservadas após reabrir o banco;
  vínculo nota↔post-it persistido; preferências de modo/data persistidas;
  abas Agenda/Caixinha/Notas acessíveis em trilho e barra inferior.

### Arquivos principais

- `lib/core/`: `date_only.dart`, `clock.dart`, `date_formatting.dart`
- `lib/domain/`: entidades, repositórios e `validate_post_it.dart`
- `lib/data/db/`: `tables.dart`, `converters.dart`, `app_database.dart` (+ `.g.dart`)
- `lib/data/mappers/mappers.dart`, `lib/data/repositories/*`
- `lib/app/`: bootstrap, scope, controllers, tema, strings, view modes
- `lib/features/`: shell, planner, inbox, notes, shared
- `test/`: `core/`, `domain/`, `data/db/`, `app/`, `helpers/`
- `android/app/build.gradle.kts`, `MainActivity.kt`, `windows/runner/main.cpp`
- `README.md`, `docs/DECISOES.md`, `docs/PROGRESSO.md`

### Limitações e pendências

- Sem grade de calendário, criação/edição visual, arraste ou redimensionamento
  (Etapas 2 e 3).
- TO-DO recorrente ainda não avança: modelagem (`startDate`,
  `lastRolloverAt`) pronta, regra na Etapa 4.
- Caixinha e Notas são telas de visão geral; filtros/editor nas Etapas 4 e 5.
- Build Windows não validado (ambiente sem Developer Mode/workload C++).
- Testes de widget cobrem navegação e renderização básica; interações visuais
  e acessibilidade entram na Etapa 6.
- O aviso do drift sobre múltiplas instâncias em testes de reabertura é
  esperado (bancos distintos em sequência, fechados antes da reabertura).

### Próximo passo

Etapa 2 — agenda visual: janelas de período por orientação, grade de dias,
post-its com cartão contínuo para eventos multi-dia e overflow "+N".
Aguardando aprovação para iniciar.
