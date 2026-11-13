# Desktop: Windows e Linux

O Stick2Planner mantém a mesma interface Flutter, controllers, esquema
Drift/SQLite e comportamento offline-first no Android, Windows e Linux. O
desktop é um alvo adicional, não uma reescrita.

## Plataformas suportadas

| Plataforma | Alvo | Situação |
| --- | --- | --- |
| Android | 7.0+ (`minSdk 24`), ARM64/x64 | Preservado; fluxo de APK inalterado |
| Windows | 10/11 x64 | Suportado; ZIP portátil e MSIX opcional |
| Linux | x64, desktop GTK 3 | Suportado; bundle, `.deb` e AppImage opcional |

O esquema do banco continua **v9**. Nenhuma tabela, coluna ou migração foi
alterada para o desktop. O mesmo código drift abre o arquivo
`planner.sqlite` em todas as plataformas.

## Onde ficam os dados

O aplicativo sempre usa `getApplicationSupportDirectory()` do `path_provider`;
nada é gravado ao lado do executável.

| Plataforma | Diretório típico | Banco |
| --- | --- | --- |
| Android | diretório privado de suporte do app | `planner.sqlite` |
| Windows | `%APPDATA%\com.example\Stick2Planner` | `planner.sqlite` |
| Linux | `$XDG_DATA_HOME/com.mikemequis1.planner` (normalmente `~/.local/share/com.mikemequis1.planner`) | `planner.sqlite` |

O nome de empresa do Windows (`com.example`) vem do
`windows/runner/Runner.rc` existente. Ele foi mantido de propósito para não
mover nem sobrescrever um diretório já criado. O nome do arquivo e o esquema
não mudaram, então um banco Android também pode ser restaurado em desktop por
backup JSON.

Snapshots automáticos ficam em `backups/` dentro do mesmo diretório. Exportação
e importação usam o seletor nativo de arquivos em todas as plataformas.

## Comportamento no desktop

- Janela inicial de 1280×800 pixels lógicos; mínimo de 900×600 (ajustado por
  DPI no Windows). O Linux também define tamanho mínimo no GTK.
- Janelas largas usam o `NavigationRail` existente; janelas estreitas mantêm a
  barra inferior dos celulares.
- Diálogos limitados a 640 pixels lógicos e folhas inferiores a 720 pixels,
  centralizados em janelas grandes. Larguras móveis não mudam.
- Post-its e barras de evento começam a arrastar imediatamente com o mouse; no
  toque continua o gesto de pressionar e segurar.
- Clique direito abre menus de contexto para dias, post-its, linhas da
  Caixinha, notas, rotinas/atividades e tags.
- Editores do desktop usam `Ctrl+S` / `Ctrl+Enter` para salvar e `Esc` para
  cancelar.
- Listas do desktop usam exclusão explícita em vez de pressionar e segurar.
- Em notas de checklist, `Ctrl+clique` seleciona uma linha e `Shift+clique`
  seleciona um intervalo; `Esc` limpa a seleção.
- Atalhos na janela principal:
  - `Ctrl+1…4`: Agenda, Caixinha, Notas, Rotinas.
  - `Ctrl+Tab` / `Shift+Ctrl+Tab`: próxima/seção anterior.
  - `Ctrl+N`: criar item na seção atual.
  - `Ctrl+,`: Configurações.
  - `Ctrl+Shift+S`: Sincronização.
  - `Ctrl+←` / `Ctrl+→`: período anterior/próximo.
  - `Alt+←` / `Alt+→`: dia anterior/seguinte.
  - `Ctrl++` / `Ctrl+-`: mais/menos dias visíveis.
  - `Ctrl+T`: hoje.
  - `Ctrl+S` / `Ctrl+Enter`: salvar no editor ou diálogo.
  - `Ctrl+B` / `Ctrl+I` / `Ctrl+K`: negrito/itálico/link Markdown.
  - `F1` ou `Ctrl+/`: ajuda de atalhos.
- Configurações tem a entrada exclusiva do desktop “Atalhos do desktop”; as
  dicas da Agenda, checklist e rotinas mudam para mouse/teclado no desktop.

## Integrações por plataforma

| Recurso | Android | Windows / Linux |
| --- | --- | --- |
| Agenda, caixinha, notas, rotinas | Sim | Sim |
| SQLite/Drift + migrações | Sim | Sim |
| Backup JSON e snapshots | Sim | Sim |
| Sync opcional com servidor | Sim | Sim, com o app aberto |
| Sync manual | Sim | Sim |
| Sync periódico em segundo plano (WorkManager) | Sim | Indisponível; sync manual/oportunista |
| Notificações locais agendadas | Sim | Não agendadas; Configurações explica |
| Leitor de QR | Câmera (`mobile_scanner`) | Código manual; o plugin não tem Windows/Linux |
| Token seguro de sync | Armazenamento do Android | Credential Manager / Secret Service (`libsecret`) |
| Manter tela ligada | Sim | Suportado pelo `wakelock_plus` quando a sessão permite |
| Abertura de links | Sim | Sim (`url_launcher`) |

Nenhuma dessas limitações afeta o uso local offline. O app abre e funciona sem
servidor, conta, rede ou câmera.

## Requisitos de desenvolvimento

Comum:

- Flutter 3.47.9+ (Dart 3.13.7+).
- Execute `flutter pub get`; o código gerado do Drift já está versionado. Use
  `dart run build_runner build --delete-conflicting-outputs` somente após
  mudanças de esquema/tabelas.

Windows:

- Visual Studio com a carga **Desenvolvimento para desktop com C++** (MSVC,
  CMake, Windows SDK).
- Modo de desenvolvedor habilitado, pois o Flutter cria symlinks para os
  plugins.
- Windows 10/11 64 bits.

Linux:

```bash
sudo apt-get install clang cmake ninja-build pkg-config \
  libgtk-3-dev libsecret-1-dev libjsoncpp-dev liblzma-dev \
  dpkg-dev appimagetool
```

`dpkg-dev` fornece o `dpkg-deb`; `appimagetool` só é necessário para AppImage e
pode baixar o runtime na primeira execução (depois reutiliza o cache).

## Comandos de build

```bash
flutter pub get
flutter analyze
flutter test

# Android (inalterado)
flutter build apk --release --split-per-abi
flutter build apk --release

# Windows x64 + ZIP portátil
pwsh -File scripts/build_windows.ps1

# Linux x64 + tar.gz + .deb (+ AppImage se appimagetool existir)
bash scripts/build_linux.sh
```

Os artefatos ficam em `dist/` (ignorado pelo git).

## Estrutura de distribuição

ZIP portátil do Windows
(`dist/windows/Stick2Planner-<versão>-windows-x64.zip`):

```text
stick2planner.exe
flutter_windows.dll
*.dll                       # runtimes de plugins e assets nativos
data/
  icudtl.dat
  flutter_assets/
  app.so                    # biblioteca AOT de release
README.txt
```

MSIX opcional:

```text
dist/windows/msix/Stick2Planner-<versão>-windows-x64.msix
```

O manifesto fica em `packaging/windows/msix/AppxManifest.xml`. O pacote fica
sem assinatura quando nenhum certificado é informado:

```powershell
pwsh -File scripts/package_windows_msix.ps1 `
  -Publisher "CN=Stick2Planner" `
  -CertificatePath ".\certs\stick2planner.pfx" `
  -CertificatePassword "<senha>"
```

Bundle Linux (dentro de `dist/linux/Stick2Planner-<versão>-linux-x64.tar.gz`):

```text
stick2planner
lib/libflutter_linux_gtk.so
lib/libapp.so               # biblioteca AOT de release
lib/*.so                    # plugins e assets nativos
data/icudtl.dat
data/flutter_assets/
README.txt
```

O `.deb`
(`dist/linux/stick2planner_<versão>_amd64.deb`) instala:

```text
/opt/stick2planner/                 bundle completo
/usr/bin/stick2planner              symlink
/usr/share/applications/stick2planner.desktop
/usr/share/icons/hicolor/256x256/apps/stick2planner.png
```

O AppImage, quando gerado, inclui o bundle Flutter, mas ainda usa GTK 3 e
Secret Service do sistema, como é normal no modelo AppImage.

## Validação e limitações conhecidas

Validado na máquina de desenvolvimento:

```bash
flutter analyze          # sem issues
flutter test             # 304 testes aprovados
flutter build apk --release
```

O release Linux foi validado no WSL Ubuntu 26.04 com Flutter 3.47.9:

```bash
FLUTTER_BIN=/opt/flutter-linux/flutter/bin/flutter bash scripts/build_linux.sh
```

Foram gerados `Stick2Planner-0.6.2-linux-x64.tar.gz`,
`stick2planner_0.6.2+14_amd64.deb` e
`Stick2Planner-0.6.2-linux-x64.AppImage`.

O release Windows também passou após habilitar o Modo de Desenvolvedor e
instalar a carga C++ de desktop do Visual Studio:

```powershell
flutter build windows --release
pwsh -File scripts/build_windows.ps1
pwsh -File scripts/package_windows_msix.ps1
```

Foram gerados `Stick2Planner-0.6.2-windows-x64.zip` e um MSIX não assinado
`Stick2Planner-0.6.2-windows-x64.msix`. O MSIX precisa ser assinado com um
certificado confiável antes da instalação normal.

O ZIP portátil não precisa de certificado e é a distribuição suportada sem
assinatura. A instalação do MSIX não assinado com
`Add-AppxPackage -AllowUnsigned` foi testada e recusada com `0x80073D2C`,
porque o publisher não está no namespace especial de pacotes não assinados do
Windows. Além disso, a instalação não assinada exigiria PowerShell elevado e um
publisher de manifesto com o OID de desenvolvimento; essa variante não serve
para distribuição.

Os scripts falham com mensagem clara quando falta toolchain ou Modo de
Desenvolvedor; nunca removem bibliotecas de runtime para forçar sucesso.

Limitações restantes:

- `mobile_scanner` e `workmanager` não têm implementação Windows/Linux. Os dois
  são protegidos em tempo de execução e continuam no APK Android.
- Notificações no desktop ainda não são agendadas. A pilha de plugins suporta
  canais desktop, mas isso exigiria permissões e identidade de aplicativo fora
  do escopo desta migração.
- O armazenamento seguro no Linux requer um Secret Service ativo (GNOME
  Keyring, KWallet etc.). Sem ele, o pareamento falha de forma controlada e o
  restante do app continua funcionando.
- O Windows precisa do runtime do Microsoft Visual C++. Ele normalmente já
  existe no Windows 10/11; em máquinas limpas, distribua o redistribuível x64
  ou use a dependência no MSIX. As DLLs do Flutter sempre vão no ZIP.
