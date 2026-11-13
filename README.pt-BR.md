[English](README.md) | **Português (Brasil)**

# Stick2Planner

Planner visual offline-first para Android, Windows e Linux. Agenda, Caixinha e
notas Markdown ficam no aparelho em SQLite; a sincronização com um servidor
próprio é opcional.

Código-fonte: [github.com/MikeMequis1/Stick2Planner](https://github.com/MikeMequis1/Stick2Planner)

## Download

APK mais recente: **[GitHub Releases](https://github.com/MikeMequis1/Stick2Planner/releases/latest)**.

- `Stick2Planner-*-arm64.apk` — recomendado para a maioria dos celulares e tablets.
- `Stick2Planner-*-universal.apk` — alternativa para outros aparelhos Android.
- `Stick2Planner-*-windows-x64.zip` — build portátil para Windows 10/11.
- `Stick2Planner-*-linux-x64.tar.gz` / `stick2planner_*_amd64.deb` — bundle Linux
  e pacote Debian (AppImage quando publicado).
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
- **Rotinas:** quadro semanal por dia com progresso, cards expansíveis,
  atividades com arrastar e soltar, conclusão independente por ocorrência,
  ocorrências que nunca antecedem a criação da rotina e sync com o servidor.
- **Notificações:** resumo diário e lembretes por item (minutos antes), agendados
  localmente no Android sem internet.
- **Navegação:** trilho único adaptativo em paisagem/desktop (Config/Sync no
  rodapé) e barra inferior igualmente distribuída em retrato. No desktop há
  atalhos (`Ctrl+1…4`, `Ctrl+Tab`, `Ctrl+N`, `Ctrl+,`, `Ctrl+S`, `Ctrl+←/→`,
  `Alt+←/→`, `F1`) e arraste imediato com o mouse. Clique direito abre menus de
  contexto; linhas de checklist aceitam seleção com Ctrl/Shift+clique.
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

- Flutter / Dart; SDK Android, toolchain C++ do Windows e GTK 3 no Linux.
- Drift + SQLite (esquema v9, migrações v1 → v9). O mesmo esquema é usado no
  Android, Windows e Linux; no desktop os dados ficam no diretório de suporte de
  cada plataforma.
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

# Desktop (executar em cada sistema-alvo)
pwsh -File scripts/build_windows.ps1      # Windows x64 + ZIP portátil
bash scripts/build_linux.sh               # bundle + .deb (+ AppImage)
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
- [docs/DESKTOP.pt-BR.md](docs/DESKTOP.pt-BR.md) — requisitos Windows/Linux,
  empacotamento, diretórios de dados e limitações do desktop.
- [docs/SINCRONIZACAO.pt-BR.md](docs/SINCRONIZACAO.pt-BR.md) — conexão, pareamento e sync.
- [stick2server](https://github.com/MikeMequis1/stick2server) — servidor de sync,
  API e deploy.
- [docs/validacao/](docs/validacao/) — evidências visuais no aparelho.

## Requisitos

- Android 7.0 ou superior; Windows 10/11 x64; ou desktop Linux x64 com GTK 3.
- Build Windows: Visual Studio com "Desenvolvimento para desktop com C++" e Modo
  de Desenvolvedor do Windows (symlinks de plugins do Flutter).
- Build Linux: `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`,
  `libsecret-1-dev`, `dpkg-dev`; `appimagetool` para o AppImage opcional.
- Servidor de sync opcional: Dart 3.13+ ou Docker Compose, acessível por LAN, VPN
  ou proxy reverso com HTTPS.

O identificador do aplicativo é `com.mikemequis1.planner`; alterá-lo cria um novo
app e não migra os dados locais existentes. O Linux usa esse identificador no
diretório de dados; o Windows mantém os metadados existentes do `Runner.rc`
(`com.example`) para não mover dados já gravados em `%APPDATA%`. Consulte
[`docs/DESKTOP.pt-BR.md`](docs/DESKTOP.pt-BR.md).
