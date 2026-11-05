# Stick2Planner

Planner visual offline-first para tablets Android: agenda por períodos, caixinha
de post-its e caderno de notas Markdown. Tudo fica em SQLite local.

## Estado

Etapas 0 a 6 concluídas e rodada pós-MVP de navegação, configurações e paletas.

- [x] Agenda, criação/edição, arraste, reordenação e redimensionamento
- [x] Estados, caixinha, tarefas sem data e TO-DO recorrente
- [x] Notas Markdown, listas, snapshots e vínculos com post-its
- [x] Acessibilidade, offline, migrações e documentação
- [x] Configurações, quatro paletas, português/inglês e gestos de navegação

## Funcionalidades

- **Agenda:** dia, 4 dias, semana, 2 semanas e mês; eventos contínuos; dois toques
  criam tarefa, três criam evento e segurar abre uma prévia que acompanha o dedo
  sobre os dias visíveis. Eventos podem ser arrastados entre semanas visíveis,
  inclusive para a faixa de eventos de outra semana; nas bordas, soltar move
  ±7 dias.
- **Navegação:** deslizar na horizontal folheia períodos; deslizar na vertical
  altera a quantidade de dias com transição de morphing.
- **Caixinha:** filtros, busca, ordenação e “Abrir na Agenda” para post-its com
  data.
- **Notas:** texto Markdown renderizado, listas/checklists, snapshots e vínculos
  vivos. Post-its da nota abrem detalhes ou a Agenda.
- **Configurações:** tema Sistema/Claro/Escuro, idioma Português/English,
  paletas Verde/Oceano/Pôr do sol/Lavanda, animações, wakelock e dicas.
- **Sincronização:** servidor próprio com URL manual ou QR, token seguro por
  dispositivo, sync manual/automático e cópia de conflitos.
- **Backup:** exportar tudo em JSON versionado (checksum SHA-256) e restaurar
  por substituição integral, com snapshot automático antes de importar.

## Stack

- Flutter 3.47.9 / Dart 3.13.7
- drift + SQLite (esquema v5, migrações v1 → v5)
- `flutter_markdown_plus`, `wakelock_plus`, `intl`, `uuid`, `crypto`,
  `file_picker`, `http`, `flutter_secure_storage`, `mobile_scanner`,
  `connectivity_plus`, `workmanager`
- Servidor de sync em `server/` (Dart/shelf + SQLite, Docker Compose)
- Android SDK 36; alvo principal: tablet Android

Arquitetura: `features -> app -> domain`, `data -> domain`. `domain` não
depende de Flutter nem drift.

## Offline, tamanho e desempenho

- Sincronização é opcional: `INTERNET` existe apenas para o servidor
  configurado; sem ele o app funciona normalmente offline.
- HTTP é aceito na LAN/Tailscale (cleartext habilitado para servidor próprio).
- O APK **debug** é grande (~188 MB) porque carrega runtime e símbolos de
  depuração. O APK **release split por ABI** fica em ~25–31 MB (o leitor de QR
  adiciona o ML Kit); usar release para avaliar fluidez e armazenamento.
- O banco local é compacto: ~80 KB para 17 post-its, 3 notas e 58 registros de
  histórico. O histórico preserva auditoria; não é removido automaticamente.
- Animações e transições podem ser desativadas em Configurações. O build release
  é a referência de desempenho.

## Comandos

```bash
flutter pub get
dart run build_runner build
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release --split-per-abi

cd server
dart pub get
dart analyze
dart test
```

O arquivo `*.g.dart` é gerado pelo drift; rode o codegen ao alterar o esquema.
Servidor: ver `server/README.md` (Compose, pareamento e tokens).
Validação em tablet Android físico via `adb`; o projeto não usa emulador.
Em HyperOS/MIUI, use `adb install -r -i com.android.vending app-debug.apk` se o
install direto for bloqueado.

## Estrutura

```text
lib/
  core/        datas, clock e formatação localizada
  domain/      entidades, calendário, validações e contratos
  data/        drift/SQLite, mappers e repositórios
  app/         bootstrap, controllers, tema, strings e paletas
  features/    agenda, caixinha, notas, configurações e casca
test/          domínio, banco, sync, backup, UI e fluxos
server/        API Dart/shelf, Dockerfile e Compose
docs/          progresso, decisões, qualidade e evidências
```

## Qualidade

- `flutter analyze`: sem issues.
- `flutter test`: 232 testes aprovados.
- `flutter build apk --debug` e release split: aprovados.
- Matriz e limitações: `docs/QUALIDADE.md`.

## Documentação

- `docs/PROGRESSO.md` — histórico por etapa.
- `docs/DECISOES.md` — arquitetura, dados, i18n e interoperabilidade futura.
- `docs/QUALIDADE.md` — validação, acessibilidade, offline e limitações.
- `docs/validacao/` — evidências visuais no tablet.

## Identificador

`applicationId` Android preservado: **`com.mikemequis1.planner`**. O nome de
exibição é **Stick2Planner**. Alterar o ID implica um novo app e perda dos dados
locais existentes.

## Futuro

Importação/exportação JSON, Radicale/CalDAV/iCalendar e sincronização própria
estão documentados em `docs/DECISOES.md`, mas não implementados.
