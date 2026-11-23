[English](README.md) | **Português (Brasil)**

# Stick2Planner

Planner visual offline-first para Android, Windows e Linux. Agenda, tarefas,
rotinas e notas Markdown ficam em um banco SQLite local; a sincronização com um
servidor próprio é opcional.

Código-fonte: [github.com/MikeMequis1/Stick2Planner](https://github.com/MikeMequis1/Stick2Planner)

## Download

Release mais recente: **[GitHub Releases](https://github.com/MikeMequis1/Stick2Planner/releases/latest)**

- `Stick2Planner-*-arm64.apk` — Android 7.0+ (`minSdk 24`); recomendado para a
  maioria dos celulares e tablets.
- `Stick2Planner-*-universal.apk` — alternativa para outros aparelhos Android.
- `Stick2Planner-*-windows-x64.zip` — build portátil para Windows 10/11 x64. O
  MSIX opcional da mesma release não é assinado e precisa de assinatura antes da
  instalação normal.
- Builds Linux x64 são gerados localmente com `scripts/build_linux.sh`
  (tar.gz + `.deb`, AppImage quando `appimagetool` estiver disponível). Ainda não
  há artefatos Linux publicados na release atual.

## O que faz

- **Agenda visual:** modos dia, 4 dias e semana em retrato; semana, 2 semanas e
  mês em paisagem; eventos multi-dia; arraste, redimensionamento, reordenação e
  criação rápida; conclusão por ocorrência e divisão da série quando um item
  recorrente muda de dia.
- **Tarefas e Caixinha:** estados ativa/concluída/cancelada, itens sem data,
  busca, filtros, ordenação e tags compartilhadas.
- **Notas:** Markdown ou checklists, prévia renderizada, seleção de linhas,
  snapshots e vínculos vivos entre notas e post-its.
- **Rotinas:** listas semanais simples ou cards completos com faixas de horário e
  uma tarefa por intervalo; conclusão por dia, lembretes, histórico de execução e
  dashboard de progresso.
- **Notificações locais:** resumo diário e lembretes de itens/rotinas no Android,
  agendados sem internet.
- **Offline-first:** não exige conta e continua totalmente utilizável sem
  servidor.
- **Sincronização opcional:** pareamento por QR ou código, token por dispositivo,
  sincronização manual/automática, cópias de conflito e revisão local/remota antes
  de substituir dados.
- **Backup:** exportação JSON versionada com checksum, importação transacional e
  snapshot verificado antes de cada importação.
- **Interface adaptativa:** layouts para toque e para mouse/teclado, seis paletas,
  tema claro/escuro/sistema e português/inglês.

## Plataformas

| Plataforma | Alvo | Observações |
| --- | --- | --- |
| Android | 7.0+ (`minSdk 24`) | APK; notificações, pareamento por QR e sync periódico usam APIs Android |
| Windows | 10/11 x64 | ZIP portátil; atalhos e interações de mouse |
| Linux | x64 com GTK 3 | Bundle/`.deb`; pareamento por código manual; token seguro exige Secret Service |

## Stack

- Flutter/Dart com interface adaptativa em Material 3.
- Drift + SQLite, esquema v13, migrações desde a v1.
- Servidor de sincronização opcional em Dart/shelf + SQLite:
  [MikeMequis1/stick2server](https://github.com/MikeMequis1/stick2server).
- Tokens de dispositivo guardados com `flutter_secure_storage`.

## Início rápido

```bash
flutter pub get
dart run build_runner build        # apenas após mudanças de esquema/tabelas
flutter analyze
flutter test
flutter run
```

Builds de release:

```bash
flutter build apk --release --split-per-abi
pwsh -File scripts/build_windows.ps1     # Windows
bash scripts/build_linux.sh              # Linux
```

Requisitos completos, empacotamento e particularidades de cada plataforma estão
em [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md).

## Documentação

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — camadas, modelo de dados,
  persistência local, offline-first e arquitetura de sincronização.
- [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md) — ambiente, geração de código,
  testes, builds, scripts e configuração por plataforma.
- [`docs/SYNC.md`](docs/SYNC.md) — integração com o Stick2Server, pareamento,
  sincronização, conflitos e diagnóstico.
- [`docs/QUALITY.md`](docs/QUALITY.md) — estratégia de testes, resultados atuais,
  validação manual e limitações conhecidas.
- [Stick2Server](https://github.com/MikeMequis1/stick2server) — configuração do
  servidor, API, imagens Docker e deploy.

## Dados e privacidade

Todos os dados do planner ficam em `planner.sqlite`, no diretório de suporte de
cada plataforma. Tokens de sincronização ficam no armazenamento seguro e nunca
são gravados em backups, logs ou no banco. O acesso à internet existe apenas para
a sincronização opcional.

Identificador do aplicativo: `com.mikemequis1.planner`. O Linux usa esse
identificador no diretório de dados; o Windows mantém os metadados legados
`com.example` para não mover dados existentes em `%APPDATA%`. Consulte
[`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md#9-data-locations).
