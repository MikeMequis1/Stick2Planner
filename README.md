# Planner

Planner visual offline-first para tablets Android. A agenda é organizada em
folhas por data, com post-its de tarefas, eventos, eventos marcantes e TO-DOs
recorrentes. Todo o conteúdo fica em um banco SQLite local; nenhuma
funcionalidade essencial depende de internet.

## Estado do projeto

Etapas 0 e 1 concluídas: base técnica e de domínio prontas. A interface ainda é
uma visão geral (contagens e data selecionada); a grade de agenda começa na
Etapa 2.

- [x] Etapa 0 — preparação, dependências, persistência básica e build Android
- [x] Etapa 1 — fundação (domínio, esquema v2, repositórios, tema, navegação)
- [ ] Etapa 2 — agenda visual
- [ ] Etapa 3 — manipulação (arrastar, reordenar, redimensionar)
- [ ] Etapa 4 — organização (estados, caixinha, recorrente)
- [ ] Etapa 5 — notas
- [ ] Etapa 6 — qualidade e documentação final

Histórico detalhado: `docs/PROGRESSO.md`. Decisões: `docs/DECISOES.md`.

## Requisitos

- Flutter 3.47.9 (stable) / Dart 3.13.7
- Android SDK 36; o SQLite nativo é compilado via hooks do Dart (NDK exigido
  pelo build Android)
- Alvo principal: tablet Android. Windows está gerado apenas para
  desenvolvimento rápido (requer Developer Mode para plugins).

## Comandos

```bash
flutter pub get
dart run build_runner build            # gera lib/data/db/app_database.g.dart
flutter analyze
flutter test
flutter run -d <device>                # ex.: emulador Android
flutter build apk --debug
```

O arquivo `*.g.dart` é gerado pelo drift; não editar manualmente. Rode o
codegen sempre que alterar `lib/data/db/tables.dart`.

## Estrutura

```
lib/
  main.dart                     # entrada, pt_BR, bootstrap
  core/                         # DateOnly, Clock, formatação de datas
  domain/
    entities/                   # PostIt, Note/NoteLine, histórico
    repositories/               # contratos (post-it, nota, preferências)
    usecases/                   # validação de post-it
  data/
    db/                         # esquema drift v2, conversores, migrações
    mappers/                    # linha drift <-> entidade
    repositories/               # implementações drift
  app/
    bootstrap.dart              # composição de banco/repos/controllers
    app_scope.dart              # injeção na árvore de widgets
    controllers/                # PlannerController, NotesController
    theme/                      # Material 3
    app_strings.dart            # textos pt_BR centralizados
  features/
    shell/                      # trilho/barra de navegação adaptativos
    planner/                    # visão geral da agenda (Etapa 2 trará a grade)
    inbox/                      # caixinha
    notes/                      # caderno
    shared/                     # componentes reutilizáveis
test/
  core/  domain/  data/db/  app/  helpers/
docs/
```

Regra de dependência: `features -> app -> domain`, `data -> domain`; `domain`
não importa Flutter nem drift.

## Domínio e persistência

- `PostIt`: UUID, título, tipo (`task`, `event`, `recurringTodo`), estado
  (`active`, `done`, `cancelled`), `isHighlight` (`+`), detalhes, vínculo de
  nota (`noteId` + snapshot `noteExcerpt`), data/início/fim, `sortOrder`,
  timestamps e tombstone (`deletedAt`).
- `Note` + `NoteLine`: texto ou checklist, linhas ordenadas.
- `PostItHistoryEntry`: auditoria de criação, edição, movimento, status,
  rollover etc., sem duplicar o post-it.
- Esquema drift v2: `app_settings`, `notes`, `note_lines`, `post_its`,
  `post_it_history_entries`, com índices e migração v1 → v2.
- Datas de calendário usam `DateOnly` (sem hora), persistido como
  `aaaa-mm-dd`; timestamps em UTC (ms).

`drift + SQLite` foi escolhido por relacionamentos, transações, consultas por
data/estado e migrações testáveis. Versões atuais: `drift 2.35.3`,
`sqlite3 3.8.0` (biblioteca embutida via hooks), `path_provider 2.1.6`,
`drift_dev 2.35.2`, `build_runner 2.17.1`.

`sqlite3_flutter_libs` foi evitado por estar marcado EOL no pub.dev. Se os
hooks falharem em algum ambiente, o fallback documentado é `drift_flutter`.

## Funcionamento offline e sincronização futura

O app não declara permissão `INTERNET` e não possui código de rede. A
preparação para uma futura sincronização em servidor próprio na rede local se
limita a: IDs UUID, `updatedAt`, exclusão lógica (tombstones) e repositórios
atrás de interfaces. Nenhum servidor, autenticação remota ou sincronização
distribuída faz parte do MVP.

## Identificador do aplicativo

`applicationId` definitivo: **`com.mikemequis1.planner`**. Nome de exibição:
**Planner**. Alterar o ID depois de instalar implica novo app e perda dos dados
locais existentes.
