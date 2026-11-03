# Planner

Planner visual offline-first para tablets Android. A agenda é organizada em
folhas por data, com post-its de tarefas, eventos, eventos marcantes e TO-DOs
recorrentes. Todo o conteúdo fica em um banco SQLite local; nenhuma
funcionalidade essencial depende de internet.

## Estado do projeto

Etapas 0 a 6 concluídas. A agenda, organização, caderno de notas e a rodada de
qualidade/acessibilidade estão implementados no MVP offline.

- [x] Etapa 0 — preparação, dependências, persistência básica e build Android
- [x] Etapa 1 — fundação (domínio, esquema, repositórios, tema, navegação)
- [x] Etapa 2 — agenda visual (períodos, grade, eventos contínuos, overflow)
- [x] Etapa 3 — criação/edição, arraste, reordenação e redimensionamento
- [x] Etapa 4 — estados, caixinha, tarefas sem data e TO-DO recorrente
- [x] Etapa 5 — notas, listas, trechos e vínculos com post-its
- [x] Etapa 6 — qualidade, acessibilidade, offline e documentação final

Histórico detalhado: `docs/PROGRESSO.md`. Decisões: `docs/DECISOES.md`.
Checklist final: `docs/QUALIDADE.md`.

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

Em HyperOS/MIUI, o `adb install` pode falhar com
`INSTALL_FAILED_USER_RESTRICTED`; além de habilitar “Instalar via USB”, o
workaround usado foi `adb install -r -i com.android.vending app-debug.apk`.

## Estrutura

```
lib/
  main.dart                     # entrada, pt_BR, bootstrap
  core/                         # DateOnly, Clock, formatação de datas
  domain/
    calendar/                   # AgendaViewMode, CalendarPeriod, barras de evento
    entities/                   # PostIt, Note/NoteLine, histórico
    repositories/               # contratos (post-it, nota, preferências)
    usecases/                   # validação de post-it
  data/
    db/                         # esquema drift v3, conversores, migrações
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
    planner/                    # agenda + grade + folhas de detalhes
    inbox/                      # caixinha
    notes/                      # caderno
    shared/                     # componentes reutilizáveis
test/
  core/  domain/  data/db/  app/  helpers/
docs/
```

Regra de dependência: `features -> app -> domain`, `data -> domain`; `domain`
não importa Flutter nem drift.

## Agenda visual

- Paisagem: semana, 2 semanas e mês compacto; retrato: dia, 4 dias e semana.
- `+`/`−` alternam os modos da orientação atual; a escolha fica persistida.
- Navegação anterior/próximo move a data selecionada em um período; "Hoje"
  volta à data local. No modo mês o dia é preservado quando possível
  (31 jan → 28/29 fev).
- Eventos multi-dia aparecem como uma barra contínua por linha da grade, com
  ID único e pontas de continuação. Não são repetidos como cartões por dia;
  ao cruzar a quebra de semana, o título aparece uma vez e o trecho seguinte é
  marcado como "continua".
- Células limitam a quantidade de cartões e mostram "+N mais", que abre a
  lista completa do dia. Eventos excedentes mostram "+N eventos", acionável,
  que abre a lista de eventos ocultos da semana.
- Mês compacto usa grade dinâmica de 35 ou 42 células, com dias de borda
  atenuados; meses de 31 dias nunca são truncados.

## Criação e manipulação

- Botão **Novo post-it** cria tarefa (título e detalhes opcionais), evento
  (data/intervalo obrigatórios, com marcação `+` opcional) ou TO-DO recorrente.
- Tarefas aceitam data única ou "Sem data"; intervalo só existe em eventos.
  Erros de validação aparecem no próprio formulário.
- Arrastar o corpo de um post-it move o registro (long press de 200 ms no
  toque). Eventos mantêm a duração ao mudar de dia; no mesmo dia, soltar sobre
  outro cartão reordena.
- Alças nas extremidades dos eventos redimensionam início/fim, com prévia da
  nova data; soltar aplica e persiste. O corpo move; as alças redimensionam.
  A área de toque é de 24×24 dp lógicos (grip visual discreto).
- Alternativas aos gestos ficam no detalhe do post-it: mover para data,
  alterar duração (eventos), subir/descer na ordem, editar e excluir com
  confirmação. Após excluir, há **Desfazer** no snackbar (restaura o tombstone).
- Mutações são validadas, transacionais e serializadas no controller; ao
  falhar, a interface mantém o último estado persistido e mostra uma mensagem.
- Mover para outro período visível pode ser feito por arraste; para períodos
  fora da tela use "Mover para data…". O auto-scroll durante o arraste foi
  avaliado e não entrou nesta rodada (ver `docs/DECISOES.md`).

## Estados, caixinha e TO-DO recorrente

- Concluir risca o post-it; cancelar usa `X`. Nenhum dos dois apaga o registro:
  o estado fica no banco, com histórico. Reabrir restaura para ativa.
- A caixinha lista todos os post-its, inclusive sem data, com filtros (todas,
  ativas, concluídas, canceladas, sem data), busca por título/detalhes/trecho e
  ordenação por data, atualização ou título.
- TO-DO recorrente: uma única pendência sem cópias. Pendente e atrasada avança
  para o dia local na abertura/retomada e antes de mutações; a operação é
  idempotente e registra histórico.
- Adiamento manual: arrastar para uma data futura fixa a pendência até lá e
  mostra “adiado”/ícone de agenda; arrastar para o passado normaliza para hoje.
  Concluir ou cancelar interrompe o avanço.
- Não há timers nem serviços contínuos: o cálculo usa a data local na
  inicialização, no `resumed` e em operações relevantes.

## Decisões desta rodada

- **Auto-scroll durante arraste:** não implementado. A navegação explícita
  "Mover para data…" é determinística, acessível e evita conflitos entre arraste,
  scroll e alvos; auto-scroll fica registrado como evolução futura.
- **Ordenação manual de eventos:** não implementada. As barras seguem data de
  início e faixas; ordenação manual não traz benefício claro e conflita com
  eventos multi-dia.
- **Desfazer exclusão:** implementado via tombstone + histórico (`restored`),
  com ação no snackbar após a confirmação.
- **Eventos ocultos:** o contador "+N eventos" é acionável e lista os eventos
  da semana com data e acesso aos detalhes; a lista completa do dia continua
  disponível ao tocar na célula.
- **Telas estreitas:** abaixo de 600 dp o FAB é substituído por um ícone “+”
  na AppBar, evitando cobrir a agenda; a grade rola quando necessário.
- **Cabeçalho:** navegação de período e controles de modo ficam em cápsulas
  separadas, com "Hoje", `+`/`-` e espaçamento uniforme entre os ícones.
- **Gestos na grade:** um toque seleciona o dia; dois toques abrem a criação de
  tarefa; três abrem a criação de evento; segurar mostra uma prévia do dia que
  fecha ao soltar.
- **Barras de evento:** conteúdo recuado das alças, grips visíveis nas pontas e
  arraste após 200 ms; as alças mantêm área de toque de 24×24 dp lógicos.
- **Bordas:** o app usa edge-to-edge, com barras de sistema transparentes e
  fundo cobrindo a área útil.
- **Animações:** seleção de dia animada, cartões/barras reagem ao toque,
  feedback de arraste com escala, badges com fade/scale e cross-fade ao trocar
  período ou modo. Ao redimensionar, a barra acompanha a largura do dedo em
  tempo real e a alça ativa recebe destaque.
- **Soltura sem flicker:** mover ou redimensionar atualiza a barra
  imediatamente; a persistência acontece em seguida e o estado anterior é
  restaurado se a escrita falhar.

## Notas privadas

- Caderno independente dos post-its: criar, editar e excluir notas; títulos e
  dois modos.
- **Texto:** um único editor Markdown, renderizado formatado no detalhe
  (títulos, negrito/itálico, listas, links, parágrafos e blocos de código).
- Barra rápida no editor: H1/H2/H3, negrito, itálico, listas, citação, link,
  código inline, bloco de código e prévia rápida. As ações respeitam a seleção
  e o nível de título é substituído ao trocar H1/H2/H3. Em telas largas a prévia
  fica à direita do campo; em telas estreitas, abaixo dele.
- **Lista:** linhas individuais com adicionar/remover, reordenar e marcar;
  **mantenha pressionada** uma linha para selecionar e converter o trecho em
  post-it pela barra inferior.
- Em notas de texto, “Criar post-it de trecho…” abre o Markdown selecionável;
  sem seleção, usa a nota inteira.
- Trecho convertido vira **snapshot** (`noteExcerpt`, sem `noteId`): editar a
  nota não altera o texto já copiado. O detalhe do post-it mostra “Trecho
  copiado”.
- Nota inteira pode ser vinculada a uma tarefa (`noteId`, referência viva):
  “Criar tarefa com esta nota”, “Vincular a post-it…” e “Abrir nota” no detalhe
  do post-it. O detalhe mostra “Nota vinculada”.
- Excluir a nota remove os vínculos vivos, com aviso, mas não apaga as tarefas;
  snapshots existentes permanecem. A nota usa tombstone.
- Limitações conscientes: a barra insere sintaxe (não é WYSIWYG); a prévia é
  um painel de conferência; dois/três toques abrem o formulário já configurado e
  só gravam ao salvar; links não abrem navegador; o snapshot de texto é escolhido
  no Markdown cru; em listas a seleção é por linha/intervalo.

## Domínio e persistência

- `PostIt`: UUID, título, tipo (`task`, `event`, `recurringTodo`), estado
  (`active`, `done`, `cancelled`), `isHighlight` (`+`), detalhes, vínculo de
  nota (`noteId` + snapshot `noteExcerpt`), data/início/fim, `sortOrder`,
  timestamps e tombstone (`deletedAt`).
- `Note` + `NoteLine`: nota de texto com `markdown` integral ou lista com
  linhas ordenadas.
- `PostItHistoryEntry`: auditoria de criação, edição, movimento, status,
  rollover etc., sem duplicar o post-it.
- Esquema drift v3: `app_settings`, `notes`, `note_lines`, `post_its`,
  `post_it_history_entries`, com índices e migrações v1 → v2 → v3.
- Datas de calendário usam `DateOnly` (sem hora), persistido como
  `aaaa-mm-dd`; timestamps em UTC (ms).

`drift + SQLite` foi escolhido por relacionamentos, transações, consultas por
data/estado e migrações testáveis. Versões atuais: `drift 2.35.3`,
`sqlite3 3.8.0` (biblioteca embutida via hooks), `path_provider 2.1.6`,
`drift_dev 2.35.2`, `build_runner 2.17.1`, `wakelock_plus 1.8.2`.

`wakelock_plus` mantém a tela ligada durante o uso (permissão `WAKE_LOCK`),
isolado no `ScreenWakeService`; a opção de desligar pela tela de configurações
fica para uma etapa futura.

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
