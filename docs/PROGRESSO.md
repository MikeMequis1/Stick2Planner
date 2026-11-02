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

## Etapa 2 — Agenda visual (concluída em 2026-11-02)

### Implementado

- `AgendaViewMode` no domínio (dia, 4 dias, semana, 2 semanas, mês).
- `CalendarPeriod`: janela derivada da data selecionada; semana começando na
  segunda; duas linhas de 7 dias; mês em grade dinâmica de 35/42 células com
  dias de borda; navegação por período com clamp de dia no mês.
- `layoutEventSegments`: eventos multi-dia viram barras por linha da grade,
  com faixas sem sobreposição, continuação nas pontas e limite de faixas com
  contador de excedentes. Título aparece uma vez por período; segmento
  seguinte mostra "continua".
- Grade visual: cabeçalho de dias da semana, células com número do dia,
  destaque de selecionado/hoje, cartões de post-it por dia (símbolos e estado
  também por ícone/riscado), overflow "+N mais" e folha com a lista completa
  do dia.
- Barra de evento multi-dia com identidade única (chave por post-it + semana),
  pontas de continuação e abertura da folha de detalhes.
- Ferramenta de período: anterior, próximo, "Hoje", `−`/`+` para ajustar a
  quantidade de dias; preferência por orientação persistida.
- Folha de detalhes somente leitura (tipo, estado, data/intervalo, detalhes,
  trecho de nota, nota vinculada).
- Cada página escuta seu controller (`ListenableBuilder`), corrigindo o caso
  em que widgets const reutilizados não refletiam mudanças de data/modo.

### Comandos executados

```bash
flutter analyze
flutter test
flutter build apk --debug
```

### Resultados

- `flutter analyze`: sem issues.
- `flutter test`: 70 testes aprovados (27 novos: períodos, barras, grade,
  navegação, overflow, orientação e persistência de dados).
- `flutter build apk --debug`: aprovado (~38 s).

### Critérios cobertos

- Sete dias em uma linha, 14 em duas linhas, mês compacto 35/42 sem truncar
  31 dias; retrato com dia/4 dias/semana.
- `+`/`−` e navegação sem perder a data selecionada; modo e data persistidos.
- Trocar modo ou orientação não altera quantidade, ordem nem datas dos dados
  (teste de widget comparando IDs e seleção antes/depois).
- Evento multi-dia é uma barra contínua, não cartões repetidos por dia; ao
  cruzar semana, não repete o título.
- Vários post-its no mesmo dia não quebram a célula; "+N mais" dá acesso à
  lista completa.

### Arquivos principais

- `lib/domain/calendar/`: `agenda_view_mode.dart`, `calendar_period.dart`,
  `event_bar_layout.dart`
- `lib/core/date_formatting.dart` (+ rótulos de período)
- `lib/features/planner/`: `agenda_page.dart` e `widgets/` (grade, linha,
  célula, barra, cartão, toolbar, folhas de detalhes)
- `lib/app/planner_view_mode.dart`, `lib/app/controllers/planner_controller.dart`
- `lib/features/shell/home_shell.dart`
- Testes: `test/domain/calendar_period_test.dart`,
  `test/domain/event_bar_layout_test.dart`,
  `test/app/calendar_view_test.dart`

### Limitações e pendências

- Sem criação/edição visual, arraste, reordenação ou redimensionamento
  (Etapa 3). A folha de detalhes é somente leitura.
- Evento que cruza semana é desenhado em um segmento por linha, com o mesmo
  ID; o título não se repete, mas a barra é interrompida fisicamente pela
  quebra de linha.
- Eventos excedentes do limite de faixas não aparecem na linha; continuam
  acessíveis pela lista do dia.
- Sem animações de transição de período e sem auditoria de acessibilidade
  completa (Etapa 6).
- Sem validação visual em aparelho/emulador nesta etapa; verificação por
  testes de widget em 1280×800, 800×1280 e 500×800 + build APK.

### Próximo passo

Etapa 3 — manipulação: criação/edição, arraste entre dias, reordenação,
alças de redimensionamento com persistência transacional e alternativas
acessíveis aos gestos. Aguardando aprovação para iniciar.

## Etapa 3 — Criação, edição e manipulação (implementada em 2026-11-02; aguardando revisão)

Status: implementação e testes automatizados concluídos; validação visual feita
em emulador Android. A etapa **não está encerrada** até a revisão das
pendências listadas ao final.

### Implementado

- Formulário de criação/edição: tarefa (título, detalhes opcionais, data
  única ou "Sem data"), evento (início/fim obrigatórios, marcante `+`
  opcional); tipo recorrente travado até a Etapa 4.
- Validação no domínio traduzida para mensagens pt-BR; erros aparecem no
  formulário e nada é persistido quando inválido. Propriedades de evento
  (intervalo/`+`) são normalizadas fora de eventos.
- Detalhes agora oferecem ações explícitas: editar, mover para data, alterar
  duração (eventos), subir/descer na ordem, excluir com confirmação.
- Arraste por long press move tarefas/eventos entre dias; eventos preservam a
  duração. Soltar um cartão sobre outro reordena; alças laterais (20 px, com
  prévia textual da data) redimensionam apenas a extremidade.
- `PlannerController` ganhou fila de mutações (`_exclusive`), `saveBatch`
  transacional no repositório, normalização de `sortOrder` e histórico para
  criação, edição, movimento, redimensionamento, reordenação e exclusão.
- Exclusão lógica mantém registro/histórico; conclusão/cancelamento e vínculos
  de nota são preservados nas edições.
- FAB "Novo post-it" na agenda e detalhes acessíveis por toque.
- Eventos de um dia passaram a ser desenhados na faixa de eventos (barra),
  liberando a célula para tarefas e permitindo alças em qualquer evento.

### Comandos executados

```bash
flutter analyze
flutter test
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

### Resultados automatizados

- `flutter analyze`: sem issues.
- `flutter test`: **99 testes aprovados** (29 novos nesta etapa).
- `flutter build apk --debug`: aprovado.
- Cobertura nova: criação/validação/edição, normalização de propriedades,
  mover tarefa/evento (incluindo virada de mês), redimensionar/clamp,
  reordenação persistida após reabrir, exclusão lógica com histórico,
  serialização de operações concorrentes, arraste entre dias, reordenação por
  arraste e por menu, alças inicial/final, data picker acessível, editor com
  teclado virtual e mensagem de título vazio.

### Validação em emulador Android

Ambiente: AVD `planner_tablet`, Android 35 (Google APIs, x86_64), 2560×1600 a
320 dpi (1280×800 dp), aceleração WHPX.

Executado com sucesso:

- Instalação e abertura do APK; agenda em paisagem.
- Criação de tarefa pelo formulário; teclado virtual abriu, o sheet se ajustou
  e o salvamento persistiu no SQLite.
- Formulário de evento, seletor de data pt-BR e alternância de marcante
  exibidos corretamente.
- Redimensionamento do evento pela alça final (arraste horizontal); banco
  atualizado de `2026-11-06` para `2026-11-07`.
- Arraste por long press de tarefa entre dias; banco atualizado e ordem
  reindexada.
- Reordenação por long press sobre outro cartão; `sort_order` trocado e
  refletido na UI.
- Detalhes, mover para data via seletor (persistido) e layout em retrato
  (dia), paisagem (semana) e mês compacto.
- Telas menores por override de tamanho: 1600×1000 (tablet pequeno) e
  800×1280 (celular, barra inferior) sem overflow visível.
- Preferências de modo/data persistidas entre reinícios do app.

Evidências: `docs/validacao/semana.png`, `mes.png`, `retrato.png`,
`detalhes.png`.

Limitações da validação: foi usado **emulador**, não aparelho físico; não
foram testados caneta, multitoque, TalkBack ativo nem teclado físico externo.
O arraste foi simulado por sequência de `motionevent` (long press + move), não
por dedo real. Criação de evento não foi concluída manualmente no emulador
(apenas formulário/data picker); o fluxo completo está coberto por teste de
widget.

### Problemas encontrados e corrigidos

- Alças de redimensionamento apareciam como faixas brancas sobre a barra;
  agora a área de toque é transparente com um grip discreto e realce só durante
  o arraste.
- Em modo mês, a altura compacta limita as faixas de eventos; excedentes são
  indicados por "+N eventos" e continuam acessíveis pela lista do dia.
- O FAB pode cobrir parte do rodapé em telas estreitas; o grid foi ajustado
  com padding inferior, mas em 400 dp ainda fica próximo do texto de ajuda.

### Limitações conhecidas

- Arrastar para dias fora do período visível não faz auto-scroll; nesse caso
  usar "Mover para data…". Documentado na interface/README.
- Eventos não entram na reordenação por `sortOrder` (seguem a faixa por data e
  lane); subir/descer é oferecido para tarefas/recorrentes.
- Sem desfazer após exclusão (há confirmação e tombstone).
- Sem sincronização/rollover recorrente: Etapa 4.
- O modo mês esconde barras excedentes atrás do contador; a lista do dia
  continua sendo a fonte completa.

### Arquivos principais

- `lib/app/controllers/planner_controller.dart` (fila, CRUD, move, resize,
  reorder, histórico)
- `lib/domain/entities/post_it.dart` (`copyWith` com limpeza de nulos)
- `lib/domain/repositories/post_it_repository.dart` e
  `lib/data/repositories/drift_post_it_repository.dart` (`saveBatch`,
  exclusão com histórico)
- `lib/features/planner/widgets/`: `post_it_editor_sheet.dart`,
  `post_it_details_sheet.dart`, `post_it_drag_data.dart`, `day_cell.dart`,
  `week_row.dart`, `event_bar.dart`
- `lib/features/shell/home_shell.dart` (FAB), `agenda_page.dart`
- Testes: `test/app/post_it_operations_test.dart`,
  `test/app/editor_and_drag_test.dart`, ajustes em
  `test/domain/event_bar_layout_test.dart`
- Evidências em `docs/validacao/`.

### Pendências desta etapa (para encerrar)

Itens conhecidos que ainda precisam de decisão/implementação antes de
considerar a Etapa 3 fechada:

1. **Aparelho físico:** validação feita apenas em emulador. Falta testar em
   tablet real, incluindo caneta, multitoque, TalkBack ativo e teclado físico.
2. **Arraste para fora do período visível:** não há auto-scroll nem navegação
   durante o arraste. Hoje é necessário usar "Mover para data…"; decidir se
   isso basta ou se o arraste deve atravessar semanas/meses.
3. **Reordenação de eventos:** subir/descer e `sortOrder` cobrem tarefas e
   recorrentes; eventos seguem a faixa por data/lane. Decidir se eventos também
   precisam de ordem manual na faixa.
4. **Indicador "+N eventos" no mês:** os eventos excedentes ficam acessíveis
   pela lista do dia, mas o contador não é acionável. Avaliar torná-lo um botão
   com a lista da semana.
5. **FAB em telas estreitas:** em ~400 dp ele fica próximo do rodapé; revisar
   posição/tamanho ou mover a criação para a AppBar nesse breakpoint.
6. **Falha de persistência:** há teste de falha de validação e serialização,
   mas falta simular falha do repositório/banco no meio de uma operação para
   validar rollback e feedback visual.
7. **Exclusão sem desfazer:** existe confirmação e tombstone, mas não há ação
   "Desfazer" no snackbar. Decidir se entra nesta etapa.
8. **Carga/legibilidade:** falta medir muitos post-its (ex.: 100–200) em modo
   semana/mês no emulador e revisar performance/overflow.
9. **Evento criado fim-a-fim no emulador:** o formulário e o date picker foram
   inspecionados no dispositivo, mas a criação completa de evento foi coberta
   só por teste de widget (o fluxo manual foi interrompido por limitação do
   `adb input`).
10. **Testes de gesto em tela real:** arraste e resize foram feitos via
    sequências de `motionevent`; confirmar sensação/tolerância em toque real.

### Próximo passo

Etapa 4 — organização: estados (concluir/cancelar sem apagar), caixinha com
filtros/busca, tarefas sem data e TO-DO recorrente com avanço diário
idempotente. Aguardando aprovação.
