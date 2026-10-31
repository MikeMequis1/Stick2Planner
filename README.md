# Planner

Planner visual offline-first para tablets Android. A agenda é organizada em
folhas por data, com post-its de tarefas, eventos, eventos marcantes e TO-DOs
recorrentes. Todo o conteúdo fica em um banco SQLite local; nenhuma
funcionalidade essencial depende de internet.

## Estado do projeto

Etapa 0 (preparação) concluída. Ainda não existe interface de agenda: o app
abre em uma tela temporária. O escopo funcional começa na Etapa 1.

- [x] Etapa 0 — preparação, dependências, persistência básica e build Android
- [ ] Etapa 1 — fundação (domínio, esquema completo, tema, navegação)
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

O arquivo `*.g.dart` é gerado pelo drift; não editar manualmente.

## Estrutura

```
lib/
  main.dart                 # entrada + tema + localização (pt_BR)
  data/db/app_database.dart # banco drift (esquema v1: preferências)
test/
  app_test.dart             # smoke test da tela inicial
  data/db/                  # testes de persistência
docs/                       # decisões e histórico das etapas
```

Camadas planejadas: `domain` (entidades e casos de uso puros), `data`
(repositórios drift), `app` (controllers e composição), `features` (UI).
Regra de dependência: `features -> app -> domain`, `data -> domain`; `domain`
não importa Flutter nem drift.

## Persistência

drift + SQLite, escolhido por relacionamentos (post-it ↔ nota ↔ histórico),
transações, consultas por data/estado e migrações versionadas testáveis.
Versões atuais: `drift 2.35.3`, `sqlite3 3.8.0` (biblioteca embutida via
hooks), `path_provider 2.1.6`, `drift_dev 2.35.2`, `build_runner 2.17.1`.

`sqlite3_flutter_libs` foi evitado por estar marcado EOL no pub.dev. Se os
hooks falharem em algum ambiente, o fallback documentado é `drift_flutter`.

## Funcionamento offline e sincronização futura

O app não declara permissão `INTERNET` e não possui código de rede. A
preparação para uma futura sincronização em servidor próprio na rede local se
limita a: IDs UUID, `updatedAt`, exclusão lógica (tombstones) e repositórios
atrás de interfaces. Nenhum servidor, autenticação remota ou sincronização
distribuída faz parte do MVP.

## Identificador do aplicativo

`applicationId` ainda é o provisório `com.example.flutter_schedule`, pendente
de definição. O nome de exibição já é **Planner**.
