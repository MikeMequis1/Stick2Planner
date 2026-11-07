[English](README.md) | **Português (Brasil)**

# Stick2Planner

Planner visual offline-first para Android. Agenda, Caixinha e notas Markdown
ficam no aparelho em SQLite; a sincronização com um servidor próprio é opcional.

Código-fonte: [github.com/MikeMequis1/Stick2Planner](https://github.com/MikeMequis1/Stick2Planner)

## Download

APK mais recente: **[GitHub Releases](https://github.com/MikeMequis1/Stick2Planner/releases/latest)**.

- `Stick2Planner-*-arm64.apk` — recomendado para a maioria dos celulares e tablets.
- `Stick2Planner-*-universal.apk` — alternativa para outros aparelhos Android.
- Android 7.0+ (`minSdk 24`). Não é necessária conta na Play Store.

## Funcionalidades

- **Agenda:** dia, 4 dias, semana, 2 semanas e mês; eventos multi-dia; arraste,
  redimensionamento, reordenação e criação rápida; janela de 4 dias ancorada;
  dias anteriores recebem um tom acinzentado discreto.
- **Repetição de eventos:** diária, a cada N semanas, a cada N meses ou anual;
  as ocorrências mantêm a duração do evento.
- **Horário do evento:** horário inicial opcional, sempre visível na barra do
  evento, sem substituir datas nem timestamps internos.
- **Tags:** tags compartilhadas entre eventos e tarefas, com cores da paleta,
  gerenciamento, filtro múltiplo na Caixinha e suporte a sync/backup.
- **Feito:** eventos positivos usam ícone de lápis e uma explicação curta;
  eventos são concluídos automaticamente após a data final e tarefas podem ser
  concluídas pelo ícone junto ao título nos detalhes.
- **Caixinha:** busca, filtros por estado, filtros por tag, ordenação e post-its
  sem data.
- **Notas:** renderização Markdown, checklists, seleção de linhas, snapshots e
  vínculos vivos entre notas e post-its.
- **Offline-first:** todos os dados ficam em SQLite local. Não há conta e o app
  continua totalmente utilizável sem servidor.
- **Sincronização opcional:** pareamento por QR/código, token por dispositivo,
  sync manual/automático, cópias de conflito e revisão dos dados local/remoto
  antes de aplicar.
- **Backup:** exportação JSON versionada com checksum, importação transacional e
  snapshots automáticos.
- **Configurações:** tema claro/escuro/sistema, seis paletas, português/inglês,
  animações, manter tela ligada e dicas de gestos.
- **Página web administrativa:** QR de pareamento ao vivo, renomear/revogar
  dispositivos e interface português/inglês, servida pelo servidor opcional.

## Stack

- Flutter / Dart, Android SDK.
- Drift + SQLite (esquema v8, migrações v1 → v8).
- Servidor de sincronização opcional em Dart/shelf + SQLite, com imagens Docker
  prontas: [MikeMequis1/stick2server](https://github.com/MikeMequis1/stick2server).
- Tokens de dispositivo guardados com `flutter_secure_storage`.

## Principais comandos

```bash
flutter pub get
dart run build_runner build
flutter analyze
flutter test
flutter build apk --release --split-per-abi
flutter build apk --release   # APK universal
```

O servidor de sincronização fica no repositório separado
**[stick2server](https://github.com/MikeMequis1/stick2server)**, com Docker
Compose e imagem `latest`.

Para configuração do servidor, pareamento e deploy, consulte
[`docs/SINCRONIZACAO.pt-BR.md`](docs/SINCRONIZACAO.pt-BR.md) e o
[README do stick2server](https://github.com/MikeMequis1/stick2server#readme).

## Documentação

- [docs/PROGRESSO.pt-BR.md](docs/PROGRESSO.pt-BR.md) — histórico de desenvolvimento.
- [docs/DECISOES.pt-BR.md](docs/DECISOES.pt-BR.md) — arquitetura e decisões técnicas.
- [docs/QUALIDADE.pt-BR.md](docs/QUALIDADE.pt-BR.md) — matriz de validação e limitações.
- [docs/SINCRONIZACAO.pt-BR.md](docs/SINCRONIZACAO.pt-BR.md) — conexão, pareamento e sync.
- [stick2server](https://github.com/MikeMequis1/stick2server) — servidor de sync,
  API e deploy.
- [docs/validacao/](docs/validacao/) — evidências visuais no aparelho.

## Requisitos

- Android 7.0 ou superior.
- Servidor de sync opcional: Dart 3.13+ ou Docker Compose, acessível por LAN, VPN
  ou proxy reverso com HTTPS.

O identificador do aplicativo é `com.mikemequis1.planner`; alterá-lo cria um novo
app e não migra os dados locais existentes.
