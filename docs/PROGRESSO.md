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

### Validação em aparelho físico (2026-11-03)

Aparelho: `2410CRP4CG` (`9a80298a`), Android 16 / HyperOS 3.0, arm64,
2136×3200 a 440 dpi (776×1164 dp), modo escuro do sistema.

Executado com sucesso:

- Instalação do APK. O `adb install` normal falhou com
  `INSTALL_FAILED_USER_RESTRICTED` mesmo com “Instalar via USB” habilitado;
  a instalação funcionou usando `adb install -r -i com.android.vending`.
- Abertura do app, tema escuro e layout de tablet.
- Criação de tarefa pelo formulário, com teclado virtual e persistência.
- Arraste por long press da tarefa de terça para quinta; UI e banco
  confirmaram `2026-11-05`.
- Evento multi-dia (dados semeados no SQLite via `run-as` porque a criação
  completa de evento pelo formulário não foi concluída no `adb`) e
  redimensionamento pela alça final: fim alterado de `2026-11-05` para
  `2026-11-06`.
- Folha de detalhes, ações visíveis, modo retrato (dia) e mês compacto.
- Persistência após `force-stop` + reabertura: tarefa e evento permaneceram.
- Verificação do banco por `run-as ... cat files/planner.sqlite` e
  `sqlite3` no host.

Evidências: `docs/validacao/aparelho-tarefa-criada.png`,
`aparelho-arraste.png`, `aparelho-resize.png`, `aparelho-detalhes.png`,
`aparelho-retrato.png`, `aparelho-mes.png`.

Limitações: gestos foram injetados por `motionevent`, não por toque manual
contínuo; não foram testados caneta, multitoque, TalkBack nem teclado físico.
A criação de evento pelo formulário não foi concluída no aparelho (o fluxo
está coberto por widget tests e o resize foi validado com evento semeado).

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

1. **Confirmação manual em aparelho:** a validação física foi feita com
   gestos injetados por `motionevent`. Falta confirmar com dedo/caneta reais,
   multitoque, TalkBack ativo e teclado físico externo.
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
9. **Evento criado fim-a-fim no aparelho:** o formulário e o date picker foram
   inspecionados no aparelho; a criação completa de evento foi coberta só por
   teste de widget (o resize usou evento semeado no banco).
10. **Testes de gesto com dedo/caneta:** arraste e resize foram injetados via
    `motionevent`; confirmar sensação/tolerância em toque real e caneta.

### Próximo passo

Etapa 4 — organização: estados (concluir/cancelar sem apagar), caixinha com
filtros/busca, tarefas sem data e TO-DO recorrente com avanço diário
idempotente. Aguardando aprovação.

## Etapa 4 — Estados, caixinha e TO-DO recorrente (implementada em 2026-11-03; aguardando revisão)

### Implementado

- Domínio: `EnsureRecurringRollover` calcula o avanço pendente → hoje, preserva
  adiamentos futuros e não mexe em concluídos/cancelados; retorna atualizações
  e histórico em lote.
- Controller: avanço na inicialização, no `resumed` (observer) e antes de
  operações relevantes; fila `_exclusive` mantém idempotência/concorrência.
  `setPostItStatus` grava `statusChanged`, reabre e recarrega recorrente
  atrasado para hoje.
- Editor: terceiro tipo “Recorrente”, sem data obrigatória; dica sobre o
  avanço diário. Criação sem data usa a data local de hoje.
- Agenda: concluídos riscados com check; cancelados com `X`; adiados mostram
  ícone de agenda + rótulo “adiado”, distinto do avanço automático.
- Detalhe: ações explícitas Concluir/Cancelar/Reabrir, chip de recorrente
  (“Avança diariamente”/“Adiado até…”) e explicação de que o adiado volta a
  avançar se continuar pendente.
- Caixinha: lista completa com busca (título/detalhes/trecho), filtros Todas/
  Ativas/Concluídas/Canceladas/Sem data, ordenação por data/atualização/
  título e menu rápido de estado. Tarefas sem data aparecem na lista.
- Movimento de recorrente: data futura vira adiamento (`manualPostponed`);
  data passada normaliza para hoje; concluir/cancelar interrompe o avanço.

### Comandos e resultados

```bash
flutter analyze
flutter test
flutter build apk --debug
adb install -r -i com.android.vending build/app/outputs/flutter-apk/app-debug.apk
```

- `flutter analyze`: sem issues.
- `flutter test`: **123 testes aprovados** (24 novos).
- `flutter build apk --debug`: aprovado (~15 s com cache).
- Instalação no aparelho físico com o workaround de installer spoof.

### Validação no aparelho físico (2026-11-03)

- Banco semeado com recorrente atrasado (`02/11`), recorrente adiado (`06/11`),
  tarefa sem data, concluída e cancelada.
- Ao abrir o app, o atrasado foi carregado para `03/11`, com **um** registro
  `rolloverAdvanced` (`02/11 → 03/11`); o adiado permaneceu em `06/11`.
- Fechar/reabrir não duplicou o avanço (histórico continuou com 1 entrada) nem
  moveu o adiado.
- UI escura: “Feito” riscado/check, “Cancelado” com X, “Tomar remedio” com
  ícone de repetição e “Alongar” com ícone de agenda + “adiado”.
- Caixinha com 7 itens, busca, chips de filtro e ordenação visíveis; datas,
  tipo e estado recorrente exibidos abaixo de cada cartão.
- `run-as` + `sqlite3` confirmaram datas e histórico no banco.

Evidências: `docs/validacao/etapa4-recorrente-adiado.png` e
`docs/validacao/etapa4-caixinha.png`.

### Arquivos principais

- `lib/domain/usecases/ensure_recurring_rollover.dart`
- `lib/app/controllers/planner_controller.dart`
- `lib/features/planner/widgets/post_it_editor_sheet.dart`
- `lib/features/planner/widgets/post_it_details_sheet.dart`
- `lib/features/planner/widgets/post_it_tile.dart`,
  `day_cell.dart`, `week_row.dart`
- `lib/features/inbox/inbox_page.dart`
- `lib/features/shell/home_shell.dart` (lifecycle)
- Testes: `test/domain/ensure_recurring_rollover_test.dart`,
  `test/app/recurring_and_status_test.dart`,
  `test/app/inbox_and_recurring_test.dart`

### Pendências e limitações

1. O avanço não usa timer: app aberto durante a virada da meia-noite só
   atualiza no próximo `resumed`/operação relevante. Isso é intencional
   (requisito), mas deve ser confirmado na revisão.
2. Ações de estado no aparelho foram cobertas por testes de widget; a
   validação física focou em rollover, adiamento e caixinha.
3. Criação de recorrente pelo formulário foi validada em teste de widget; no
   aparelho, os dados de recorrência foram semeados para testar o avanço.
4. Filtros/busca/ordenação da caixinha não são persistidos entre reinícios.
5. Sem “Desfazer” após exclusão; segue confirmação + tombstone.
6. Gestos continuam validados por `motionevent`; falta teste manual com dedo,
   caneta e TalkBack.
7. Carga com 100–200 post-its e acessibilidade completa continuam para a
   Etapa 6.

### Próximo passo

Etapa 5 — notas privadas: caderno, listas, seleção de linha/trecho, criação de
post-it a partir do texto e vínculos persistidos. Aguardando aprovação.

## Rodada de fechamento das Etapas 3 e 4 (2026-11-03)

### Pendências resolvidas

- **Falhas de persistência/rollback:** decorator de repositório com falha
  simulada cobre criação, edição, movimento, redimensionamento, reordenação e
  exclusão; memória e banco permanecem iguais. Testes de rollback real usam FK
  inválida no histórico para provar que o lote é revertido. UI de arraste e
  formulário mostram erro compreensível e mantêm o estado persistido.
- **Eventos fim a fim no aparelho:** criados via formulário:
  - evento comum de um dia (`endDate` nulo);
  - evento comum de vários dias (`03/11` a `05/11`);
  - evento marcante `+` de um dia (`is_highlight = 1`);
  - evento marcante de vários dias (`03/11` a `05/11`).
  Todos persistidos e exibidos como barras; validações e seletores pt-BR
  exercitados.
- **Alças de resize:** `SizedBox` de 24×24 dp lógicos; verificado no aparelho
  (66×66 px @440 dpi = 24 dp) e em teste de widget. Grip visual continua
  discreto (2×12 dp).
- **"+N eventos":** agora é botão; abre a lista de eventos ocultos da semana,
  com data e acesso aos detalhes. Teste de widget + verificação no aparelho.
- **FAB em telas estreitas:** abaixo de 600 dp o FAB foi substituído por um
  ícone “+” na AppBar. Padding inferior compacto evita cobrir conteúdo; tela
  de 1000×1600 (≈364 dp) sem overflow de layout.
- **Carga:** teste de widget com 200 post-its (tarefas, eventos simples e
  multi-dia) e teste no aparelho com 170 registros. Sem travamento; ajustes
  feitos para eliminar overflow e preservar datas/contadores no mês compacto.
- **Desfazer exclusão:** snackbar “Desfazer” restaura o tombstone e grava
  `restored` no histórico; teste de controller e widget.
- **Wakelock:** `wakelock_plus 1.8.2` + permissão `WAKE_LOCK`; serviço isolado
  em `ScreenWakeService`, ativado no boot. Tela permaneceu ligada após 20 s com
  timeout de 15 s. Opção de desligar nas configurações fica para etapa futura.

### Decisões registradas

- **Auto-scroll durante arraste:** não implementado nesta rodada. “Mover para
  data…” é determinístico, acessível e evita conflitos; fica como possível
  evolução futura.
- **Ordenação manual de eventos:** não implementada. Data de início + faixas
  atende e evita complexidade com eventos multi-dia.
- **Desfazer exclusão:** implementado, como descrito acima.

### Resultados dos testes

- `flutter analyze`: sem issues.
- `flutter test`: **138 testes aprovados**.
- `flutter build apk --debug`: aprovado (~15 s com cache).
- Carga de 200 itens no teste de widget: primeira renderização entre ~1,1 s e
  ~1,4 s no host; sem exceção de layout.
- Carga no aparelho (170 itens): cold start `am start -W` **2341 ms**;
  navegação e troca de modo sem travamento; amostras de frame ~12 ms
  (gfxinfo). No modo mês de alta densidade, células exibem resumo “+N mais” e
  “+N eventos” em vez de cartões individuais; datas permanecem legíveis.

### Validação física complementar

- Eventos comuns/marcantes e recorrente criados pelo formulário, persistidos no
  SQLite, sobrevivendo a force-stop/reabertura.
- Recorrente UI: 1 instância, data de hoje, histórico `created`; sem duplicação.
- Teclado virtual: formulário se ajusta sem overflow na agenda de fundo
  (`resizeToAvoidBottomInset: false`).
- Retrato/paisagem, mês compacto, tela estreita via override e wakelock
  verificados.
- Limitações mantidas: gestos injetados por `motionevent`; sem dedo/caneta/
  TalkBack/teclado físico externo; criação de recorrência via formulário foi
  validada, mas o avanço diário foi observado com registro semeado em rodada
  anterior.

### Evidências

- `docs/validacao/round-evento-comum.png`
- `round-evento-comum-multidia.png`
- `round-evento-marcante-multidia.png`
- `round-evento-marcante-um-dia.png`
- `round-recorrente-ui.png`
- `round-eventos-ocultos.png`
- `round-carga-mes.png`
- `round-tela-estreita.png`

### Pendências mantidas

- Auto-scroll e ordenação manual de eventos permanecem fora (decisão).
- Opção de desligar wakelock nas configurações (futuro).
- Filtros da caixinha não persistem.
- Falta teste manual com dedo/caneta/TalkBack/teclado físico.
- Falta otimização dedicada para muitos itens; não foi necessária nesta carga.

### Próximo passo

Etapa 5 — notas privadas. Aguardando avaliação desta rodada; não iniciada.

## Etapa 5 — Notas privadas (implementada em 2026-11-03; ajuste Markdown)

### Implementado

- Caderno independente: lista de notas, criação, edição e exclusão com
  confirmação; título e dois modos: texto Markdown ou lista.
- **Notas de texto:** um único campo multilinha Markdown, com expansão vertical
  e dicas de sintaxe; aceita títulos, negrito, itálico, listas ordenadas e não
  ordenadas, links, parágrafos, quebras de linha e blocos de código.
- **Listas:** mantêm o editor por linhas com adicionar, remover, subir/descer e
  marcar itens; ordem persistida por `position`.
- Detalhe de nota de texto renderiza o Markdown formatado (sem exibir a sintaxe
  crua) e permite criar um post-it de trecho.
- Detalhe de lista mantém a seleção por toque em uma ou várias linhas, com barra
  inferior estável e ação “Criar post-it do trecho”.
- Conversão em snapshot: `noteExcerpt` com o texto escolhido e `noteId` nulo; o
  post-it é criado sem data, acessível pela caixinha. A UI mostra “Trecho
  copiado” e o aviso de snapshot.
- Vínculo vivo: “Criar tarefa com esta nota” (nota inteira) e “Vincular a
  post-it…” escolhendo tarefa existente; “Abrir nota” no detalhe do post-it e
  “Desvincular nota”. A UI mostra “Nota vinculada” e registra
  `noteLinked`/`noteUnlinked` no histórico do post-it.
- Excluir nota vinculada avisa, remove os `noteId` em transação e preserva
  tarefas/snapshots; nota fica como tombstone.
- Editar a nota atualiza a referência viva, mas não altera snapshots.
- Integração com detalhes do post-it em Agenda e Caixinha.

### Modelo e decisões

- Esquema drift **v3**: `notes.markdown` (texto nullable) guarda o conteúdo
  integral das notas de texto; `note_lines` continua exclusivo das listas.
- Migração v2 → v3 converte as linhas das notas `type='text'` em um único
  Markdown separado por `\n`, remove essas linhas e preserva as listas.
- `Note.plainText` usa `markdown` para texto e as linhas para listas; serve de
  fallback para dados legados.
- Renderização com `flutter_markdown_plus 1.0.12` (o `flutter_markdown` oficial
  está descontinuado). `softLineBreak: true` mantém a quebra de linha visível ao
  pressionar Enter, sem exigir linha em branco.
- Snapshot de texto usa um diálogo com o Markdown cru selecionável: o usuário
  escolhe o trecho, ou “Nota inteira” quando não há seleção; o título vem
  preenchido com o título da nota.
- Link vivo e snapshot continuam mutuamente exclusivos: vincular uma nota limpa
  o `noteExcerpt`; copiar trecho não cria `noteId`.
- Seleção de listas continua por linha/intervalo; não há substring dentro de
  uma linha nesse modo.
- Exclusão de nota não apaga post-its; desvincula e mantém o conteúdo próprio
  do post-it e snapshots.
- Não há tabela de histórico de notas; eventos de vínculo ficam no histórico
  dos post-its. Exclusão de nota não tem “Desfazer” nesta etapa.

### Testes e resultados

- `flutter analyze`: sem issues.
- `flutter test`: **158 testes aprovados** (6 novos nesta revisão).
- `flutter build apk --debug`: aprovado (~15 s com cache).
- Novos testes: criação/edição de Markdown preservando formatação após reabrir,
  fallback de linhas legadas, migração v2 → v3 com texto e checklist, criação de
  nota Markdown pela UI com renderização formatada e snapshot de trecho
  Markdown.
- Testes anteriores de lista, snapshot, vínculo vivo, desvínculo e exclusão
  continuam passando.

### Validação física

- Banco v2 existente no tablet migrou para v3: nota de texto legada
  (`Pao`, `Leite`) virou `markdown = 'Pao\nLeite'`, `note_lines` ficou vazia e
  `PRAGMA user_version = 3`.
- Nota Markdown criada e editada no aparelho; negrito, itálico, lista, título e
  quebras de linha renderizados corretamente no detalhe.
- Snapshot de nota Markdown persistiu com `note_id` nulo e o trecho selecionado
  no diálogo; “Nota inteira” também disponível.
- Lista criada em modo Lista: `type = checklist`, `markdown` nulo, linhas na
  ordem; seleção de duas linhas mostrou “2 selecionada(s)” e a ação de criar
  post-it.
- Vínculo de nota existente permaneceu visível em “Post-its vinculados” após a
  migração e a edição.
- Telas verificadas em tablet Android (3200×2136, 440 dpi, tema escuro), com
  reinício do aplicativo para confirmar persistência. Evidências:
  `docs/validacao/etapa5-markdown-editor.png`,
  `etapa5-markdown-detalhe.png`, `etapa5-markdown-snapshot.png` e
  `etapa5-lista-selecao.png`.

### Limitações

- Links Markdown são renderizados, mas não abrem navegador nesta etapa (não há
  integração externa; o texto continua selecionável/copiável).
- O snapshot de texto é escolhido no Markdown cru, não no texto renderizado;
  isso mantém a implementação simples e preserva a sintaxe escolhida.
- Alternar uma nota entre Texto e Lista converte o conteúdo (linhas ↔ Markdown)
  e descarta formatação Markdown; a ação é intencional e não gera undo.
- Seleção em listas é por linha/intervalo, não substring dentro da linha.
- Nota tem um vínculo por post-it; vincular outra substitui a referência.
- Excluir nota remove vínculos vivos sem undo; snapshots permanecem.
- Não há busca/ordenação própria no caderno nesta etapa.
- Snapshot é cópia intencional: editar a nota não o atualiza.

### Próximo passo

Etapa 6 — qualidade e documentação final (testes de integração, acessibilidade,
ajustes de layout, verificação offline e documentação). Não iniciada; aguardando
avaliação.

## Rodada de ajustes — Markdown, toque longo e agenda (2026-11-03)

### Editor Markdown

- Barra de ferramentas acima do campo de texto com H1, H2, H3, negrito,
  itálico, lista com marcadores, lista numerada, citação, link, código inline,
  bloco de código e prévia rápida.
- As ações respeitam a seleção: envolvem o texto escolhido ou prefixam as linhas
  atingidas. H1/H2/H3 substituem o nível anterior em vez de acumular `#`; listas
  numeradas renumeram o bloco.
- O campo recupera o foco e a seleção após usar a barra.
- Prévia rápida fica à direita do campo em telas largas (abaixo em telas
  estreitas), com renderização Markdown, rolagem própria e alternância pelo botão
  de olho.

### Seleção de notas

- Linhas de lista agora são selecionadas por **toque longo**, com feedback
  tátil; toque simples não seleciona.
- Checkbox continua marcando/desmarcando; a barra inferior, o snapshot e o
  vínculo vivo não mudaram.
- As dicas no detalhe e no editor foram atualizadas para “Mantenha pressionada
  uma linha…”.

### Agenda

- Navegação de período e controles de modo agrupados em cápsulas com borda,
  “Hoje” separado por divisor e ícones `+`/`−` alinhados.
- Rodapé com ícone de dica alinhado e contagem “Sem data” em pill.
- Célula compacta do mês com 1 px a menos de padding interno para preservar ao
  menos uma tarefa visível junto do indicador de overflow quando a altura é
  reduzida.
- Ajustes somente visuais; gestos, regras e persistência permanecem iguais.

### Testes e resultados

- `flutter analyze`: sem issues.
- `flutter test`: **159 testes aprovados** (1 novo nesta rodada).
- `flutter build apk --debug`: aprovado.
- Novo teste: barra Markdown aplica H1 e negrito, abre a prévia e persiste o
  conteúdo; teste de lista confirma que toque simples não seleciona e toque
  longo seleciona.

### Validação física

- Barra Markdown, prévia e detalhe renderizado verificados no tablet.
- Toque longo em linha de lista mostrou “1 selecionada(s)” e a ação de criar
  post-it; toque simples não abriu seleção.
- Cabeçalho da agenda, cápsulas, rodapé e grade verificados no tablet.
- Evidências: `docs/validacao/etapa5-markdown-barra.png`,
  `etapa5-markdown-previa.png`, `etapa5-selecao-toque-longo.png` e
  `rodada-agenda-cabecalho.png`.

### Limitações

- A barra insere sintaxe Markdown; o editor não é WYSIWYG e os marcadores
  continuam visíveis.
- A prévia fica à direita do editor em telas largas e empilhada abaixo em telas
  estreitas; não é um editor WYSIWYG.
- Não há undo/redo próprio na barra; vale o undo do campo de texto do sistema.
- Selecionar linhas exige toque longo; toque simples não seleciona (decisão
  deliberada para evitar seleção acidental).
- Os ajustes da agenda são visuais e não alteram atalhos, arraste ou regras de
  negócio.
- Permanecem as limitações anteriores: links não abrem navegador, snapshot de
  texto usa Markdown cru, um vínculo por post-it, sem busca/histórico de notas.

## Rodada de gestos e ajustes visuais (2026-11-03)

### Prévia do editor

- Em telas largas, a prévia Markdown fica **à direita** do campo de edição, com
  a barra de ferramentas ocupando a largura total acima dos dois.
- Em telas estreitas, editor e prévia são empilhados.
- O painel tem altura mínima de 320 px e rolagem própria até 360 px; a altura do
  campo acompanha o conteúdo.

### Barras de eventos e agenda

- Conteúdo das barras de evento recebeu recuo nas pontas para não ficar sob as
  alças de redimensionamento; o ícone deixou de coincidir com o início da barra.
- Alças de redimensionamento ficaram mais visíveis (grip arredondado) e mantêm
  área de toque de 24 px.
- Arraste de eventos e post-its começa após 200 ms, reduzindo a sensação de
  travamento sem transformar rolagem em arraste acidental.
- Cabeçalho, rodapé e espaçamentos principais normalizados para múltiplos de
  8 px; ajustes finos usam múltiplos de 4 px.
- App passou a usar **edge-to-edge**: barras de status e navegação transparentes
  e fundo do app cobrindo a área útil da tela.

### Gestos na grade

- **Um toque:** seleciona o dia imediatamente.
- **Dois toques:** abre a criação de tarefa já com a data e o tipo Tarefa.
- **Três toques:** abre a criação de evento já com a data e o tipo Evento.
- **Toque longo:** abre uma janela de prévia do dia; ao soltar o dedo, a janela
  fecha. A prévia lista até quatro post-its e indica o restante.
- O intervalo para encadear 2/3 toques é de 300 ms; a seleção do dia não espera
  esse intervalo.

### Testes e resultados

- `flutter analyze`: sem issues.
- `flutter test`: **162 testes aprovados**.
- `flutter build apk --debug`: aprovado.
- Novos testes: dois toques abrem tarefa e três abrem evento; toque longo mostra
  prévia e soltar remove; prévia Markdown fica à direita do campo.

### Validação física

- Prévia Markdown à direita conferida no tablet.
- Dois toques abriram “Novo post-it” em Tarefa com a data correta; três toques
  abriram o mesmo formulário em Evento.
- Barras de evento com conteúdo recuado e grips visíveis nas pontas.
- Evidências: `docs/validacao/rodada-agenda-gestos.png`,
  `rodada-agenda-toque-duplo.png`, `rodada-agenda-toque-triplo.png` e
  `etapa5-markdown-previa-direita.png`.

### Limitações

- Dois/três toques abrem o formulário de criação já configurado; o post-it só é
  gravado ao salvar, evitando títulos provisórios.
- O encadeamento de três toques precisa ocorrer dentro de 300 ms.
- Gestos de múltiplos toques não são disparados quando o toque começa sobre um
  post-it; nesse caso vale o cartão.
- A prévia por toque longo fecha apenas ao soltar; não é uma janela modal.
- O ajuste de margens cobre os espaçamentos principais; a grade mantém um
  gutter óptico de 1,5 px entre células para não perder densidade no mês.
- Permanecem as limitações anteriores de notas, links e vínculos.

## Animações da agenda (2026-11-03)

### Implementado

- Seleção de dia anima cor, borda e uma escala sutil (160 ms, `easeOut`).
- Célula sob arraste cresce levemente e o alvo de soltura ganha borda animada.
- Cartões de post-it e barras de evento encolhem levemente ao toque (100 ms).
- Feedback de arraste entra com escala (180 ms, `easeOutBack`); o cartão de
  origem desbota em 160 ms.
- Prévia de redimensionamento e botão “+N eventos” entram com fade/scale.
- Rótulo do período faz cross-fade e o rótulo do modo usa fade + scale.
- Ao trocar período ou modo, a grade faz cross-fade de 180 ms; atualizações de
  dados no mesmo período continuam instantâneas.

### Limitações

- O redimensionamento contínuo segue o dedo sem animação para não introduzir
  atraso; só o selo de prévia é animado.
- Não há preferência explícita de “reduzir movimento”; as animações são curtas
  e não bloqueiam a interação.
- Animações não alteram dados, persistência ou regras de negócio.
