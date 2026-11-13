[English](DECISIONS.md) | **Português (Brasil)**

# Decisões técnicas

Registro das decisões aprovadas e das restrições que valem para as próximas
etapas. Cada item: contexto, decisão, consequência.

## Arquitetura

- **Contexto:** app offline-first, tablet-first, com futura sincronização em
  servidor próprio na rede local.
- **Decisão:** camadas `features` (UI) → `app` (controllers/composição) →
  `domain` (entidades + casos de uso) e `data` (drift) implementando interfaces
  do domínio. Estado com `ChangeNotifier` exposto por um único `AppScope`;
  sem Riverpod/Bloc no MVP.
- **Consequência:** regras de negócio testáveis sem Flutter; sem abstração de
  rede vazia. Sincronização futura entra como implementação adicional dos
  repositórios e resolução de conflitos, sem reescrever a UI.

## Banco local

- **Decisão:** drift + SQLite.
- **Justificativa:** relacionamentos (post-it ↔ nota ↔ histórico), transações
  para mover/reordenar/redimensionar, consultas por data/estado, migrações
  versionadas e testes com banco em memória. `sqflite` exigiria mapeamento e
  migrações manuais; `isar`/ObjectBox/Hive não oferecem o mesmo suporte
  relacional.
- **Consequência:** codegen obrigatório (`dart run build_runner build`).

## Identidade do aplicativo

- **Decisão:** `applicationId` / `namespace` `com.mikemequis1.planner`; nome de
  exibição Stick2Planner.
- **Consequência:** definido antes de existirem dados reais. Mudar o
  `applicationId` depois cria outro app e perde o banco local; o nome de
  exibição pode mudar sem afetar os dados.

## Datas e IDs

- **Decisão:** datas de calendário usam `DateOnly` (sem hora, persistido como
  `yyyy-MM-dd`); timestamps de auditoria usam UTC em milissegundos; IDs são
  UUID v4.
- **Consequência:** sem deslocamento de fuso/DST em regras de agenda; `Clock`
  injetável para testes determinísticos (nenhum `DateTime.now()` no domínio).

## Modelo de post-it

- Uma tabela `post_its` com `type` (`task`, `event`, `recurringTodo`),
  `status` (`active`, `done`, `cancelled`), `isHighlight` (símbolo `+`),
  `details`, `noteId` + `noteExcerpt`, `startDate`/`endDate`, `recurrence` +
  `recurrenceInterval`, `sortOrder`, `createdAt`/`updatedAt`, `deletedAt`.
- Tarefa simples e detalhada compartilham o mesmo tipo: `details` preenchido
  caracteriza a detalhada. Eventos exigem data; intervalo e `+` são
  normalizados/validados apenas para eventos.
- **Ordem, não coordenadas:** não há posição livre x/y. O layout é responsivo
  e ordenado por `sortOrder` por dia; coordenadas absolutas quebrariam a
  legibilidade em outra orientação. Eventos usam faixas próprias e não entram
  na ordenação dos cartões de tarefa.
- **Cor não é dado:** cores derivam de tipo/estado e sempre vêm acompanhadas
  de ícone, símbolo ou rótulo.
- **Exclusão:** concluir/cancelar nunca apaga; exclusão definitiva grava
  tombstone (`deletedAt`), preservando histórico e preparando sync.

## Tipos e validação

- Tarefa: título obrigatório; detalhes e data única opcionais; sem intervalo
  e sem marcação `+` (normalizados pelo controller e recusados pela validação).
- Evento: data obrigatória; fim ≥ início; `endDate` igual ao início é
  normalizado para `null` (evento de um dia); `+` permitido.
- Recorrente: sem intervalo; tipo travado na edição até a Etapa 4.
- Erros do domínio (`PostItValidationError`) são traduzidos para mensagens
  pt-BR no formulário; o salvamento só ocorre após validação.

## Alvos desktop

- **Contexto:** o mesmo planner precisa rodar em Windows e Linux sem duplicar a
  interface Dart, as regras de negócio, o esquema drift ou o comportamento
  Android.
- **Decisão:** desktop é um alvo Flutter adicional. Um pequeno
  `core/platform_support.dart` expõe verificações de capacidade em tempo de
  execução; somente integrações nativas opcionais são condicionais. Post-its e
  eventos usam `LongPressDraggable` no toque e `Draggable` imediato no desktop.
  Diálogos e folhas recebem largura máxima; os runners nativos definem tamanho
  inicial e mínimo. Os dados continuam em `getApplicationSupportDirectory()`,
  com o mesmo `planner.sqlite` e esquema v9.
- **Consequência:** nenhuma migração de dados e nenhuma camada de persistência
  paralela. `mobile_scanner` e `workmanager` continuam exclusivos do Android em
  tempo de execução e ficam ocultos/desativados no desktop. O Windows mantém o
  nome de empresa legado do `Runner.rc` para não mover o diretório de dados.
  Os scripts de empacotamento copiam a saída de release; nunca removem
  bibliotecas de runtime.

## Movimentação, reordenação e redimensionamento

- Arrastar o corpo usa `LongPressDraggable` no toque (evita arraste acidental
  ao rolar) e `Draggable` imediato no desktop; células e cartões são
  `DragTarget`.
- Mover evento preserva `durationInDays`; mover tarefa altera a data única.
  Reindexação de origem/destino e histórico são gravados em uma transação
  (`saveBatch`).
- Reordenar no mesmo dia aceita índice de destino; a ordem é renormalizada
  (`sortOrder` 0..n-1) e persistida.
- Alças laterais dos eventos (20 px, com prévia textual) alteram somente a
  extremidade; o corpo continua movendo o evento. Somente as pontas reais do
  evento recebem alças (segmentos de continuação não).
- Alternativas acessíveis: mover para data, alterar duração por seletores,
  subir/descer na ordem, editar e excluir com confirmação.

## Consistência de escrita

- Todas as mutações do `PlannerController` passam por uma fila (`_exclusive`),
  serializando arrastes/edições rápidos.
- Estado em memória só é atualizado depois do commit no banco; falha de
  validação ou persistência mantém a última visão consistente.
- Histórico e alterações múltiplas usam `saveBatch`/transações do drift.

## Eventos de múltiplos dias — cartão contínuo

- **Decisão aprovada:** um evento estendido é **um único post-it contínuo**
  entre os dias, não cartões repetidos.
- **Consequência de implementação (Etapa 2/3):** todos os eventos (inclusive
  de um dia) são desenhados na faixa de eventos, nunca como cartão de tarefa.
  A grade usa uma faixa por linha de semana; o evento vira um segmento com o
  mesmo ID, pontas de continuação e título exibido uma única vez por período
  visível; se cruzar a quebra de semana, o segmento seguinte mostra "continua"
  em vez de repetir o cartão inteiro. Arrastar o corpo move o intervalo
  inteiro; arrastar as alças altera apenas a extremidade correspondente.

## TO-DO recorrente

- Rótulo na interface: **Pendência**. O tipo interno continua `recurringTodo`;
  mudou apenas o nome exibido.

- Uma única linha; nunca gera cópias. Pendente e com data nula/atrasada →
  `startDate = hoje local`. Recálculo é absoluto e idempotente; executar várias
  vezes não duplica nem avança além do necessário.
- Implementado em `EnsureRecurringRollover` (domínio puro), que só atualiza
  `startDate`/`lastRolloverAt` e registra `rolloverAdvanced` no histórico;
  identidade, título, detalhes, nota e estado são preservados.
- Executado no boot, no `resumed` do ciclo de vida e antes de operações de
  agenda. Sem timers contínuos e sem serviço em background. Fechado por vários
  dias → salta direto para o dia atual na próxima abertura.
- Concluído/cancelado para de avançar e permanece na caixinha. Reabrir um
  recorrente atrasado recarrega para hoje.
- **Adiamento manual:** soltar em data futura fixa a data e suspende o avanço
  até ela; soltar em data passada/hoje normaliza para hoje. O histórico recebe
  `manualPostponed`; o cartão mostra ícone de agenda + “adiado” (texto, não só
  cor), e o detalhe explica que volta a avançar se continuar pendente.
- Tipo “Recorrente” no editor não pede data; a data corrente é derivada de
  hoje, sem duplicar o registro.

## Estados e caixinha

- `status` (`active`, `done`, `cancelled`) nunca implica exclusão. Concluir
  risca o cartão; cancelar mostra `X`; ambos continuam no banco e no histórico.
  Reabrir volta para ativa (recorrente atrasado recarrega para hoje).
- Ações de estado ficam no detalhe (acessíveis) e no menu da caixinha; mudar de
  estado não altera data, ordem ou vínculo.
- A caixinha lista todos os post-its (com e sem data), com filtros por estado e
  “sem data”, busca em título/detalhes/trecho e ordenação por data,
  atualização ou título.
- O estado é independente da posição temporal; arrastar não altera status.

## Falhas, rollback e consistência

- Escritas passam por transações drift; `saveBatch` grava post-its + histórico
  atomicamente. Falha em qualquer item reverte o lote.
- O controller só atualiza a memória depois do commit (`_reload`); validação ou
  falha do repositório mantém a UI no último estado persistido.
- Operações são serializadas por fila; erros chegam à UI como snackbar/mensagem
  de formulário.
- Testes cobrem falhas simuladas em criação, edição, movimento,
  redimensionamento, reordenação e exclusão, além de rollback por FK inválida.

## Alças e acessibilidade

- Área de interação de **24×24 dp lógicos** no Flutter (não pixels físicos),
  com grip visual de 2×12 dp. O corpo do evento continua sendo o alvo de
  movimento; a alça só redimensiona.
- Em telas estreitas (<600 dp), o “+” fica na AppBar nas seções Agenda e
  Caixinha e some em Notas; em telas largas a Agenda mantém o FAB estendido e a
  Caixinha usa o “+” da AppBar.

## Eventos adicionais no mês

- "+N eventos" é um botão; abre uma folha com os eventos que não couberam nas
  faixas da semana, com datas e acesso aos detalhes.
- O mês continua sendo visão compacta; tarefas que não couberem usam "+N mais"
  e abrem a lista do dia ao tocar na célula.

## Decisões desta rodada

- **Auto-scroll no arraste:** adiado. A ação “Mover para data…” cobre o caso e
  evita riscos de interação; pode ser reavaliado após uso real.
- **Ordenação manual de eventos:** não necessária. A organização por data de
  início e faixas atende; ordem manual conflita com eventos multi-dia.
- **Desfazer exclusão:** implementado com o tombstone existente; snackbar
  “Desfazer” restaura e grava `restored` no histórico.
- **Tela ligada:** `wakelock_plus` ativo por padrão durante o uso, isolado em
  `ScreenWakeService`; a opção “Manter tela ligada durante o uso” permite
  desligar. Preferência persistida em `app_settings`.

## Notas

- **Modelo v3:** notas de texto guardam o conteúdo integral em
  `notes.markdown`; notas de lista guardam itens ordenados em `note_lines` e
  deixam `markdown` nulo. A UI mantém os modos Texto e Lista.
- **Migração v2 → v3:** as linhas das notas `type='text'` são unidas em um único
  Markdown (`\n`), essas linhas são removidas e as listas ficam intactas. O
  fallback `Note.plainText` cobre dados antigos sem perder conteúdo.
- **Markdown:** `flutter_markdown_plus 1.0.12`, pois `flutter_markdown` está
  descontinuado. O detalhe renderiza a formatação; `softLineBreak: true` trata
  Enter como quebra visível, mantendo parágrafos separados por linha em branco.
- **Barra rápida:** acima do campo Markdown há atalhos para H1/H2/H3, negrito,
  itálico, listas, citação, link, código inline, bloco de código e prévia. As
  ações operam sobre a seleção ou a linha atual; títulos trocam de nível em vez
  de acumular `#`.
- **Prévia rápida:** em telas largas fica à direita do campo; em telas
  estreitas, empilhada abaixo. Tem altura mínima de 320 px, rolagem própria até
  360 px e é uma conferência, não um editor WYSIWYG. Não há undo/redo próprio —
  usa o undo do campo do sistema.
- **Seleção de linhas:** exige toque longo (com feedback tátil), evitando
  seleção acidental ao rolar ou tocar no checkbox. Toque simples não seleciona;
  a barra inferior e o snapshot continuam iguais.
- **Snapshot de texto:** diálogo com o Markdown cru selecionável e título
  preenchido; sem seleção, usa a nota inteira. O snapshot é cópia literal do
  trecho, incluindo a sintaxe Markdown escolhida.
- **Snapshot de lista:** seleção por toque em uma ou várias linhas, como antes.
- **Snapshot:** `noteExcerpt` com `noteId = null`; editar a nota não altera o
  texto copiado. A UI marca “Trecho copiado”.
- **Vínculo vivo:** `noteId` (referência à nota inteira); a UI marca “Nota
  vinculada” e oferece “Abrir nota”. Vincular limpa o snapshot anterior.
- **Exclusão:** a nota vira tombstone; ao excluir uma nota vinculada, os
  `noteId` dos post-its são removidos na mesma transação, preservando título,
  detalhes e snapshots. A UI avisa antes da ação.
- Notas não possuem tabela de histórico própria; as alterações de vínculo são
  registradas no histórico do post-it (`noteLinked`/`noteUnlinked`).

## Calendário

- Paisagem: semana, duas semanas, mês compacto.
- Retrato: dia, quatro dias, semana.
- **Cabeçalho:** navegação e controles de modo em cápsulas visuais separadas,
  com ícones `+`/`-`, "Hoje" e divisor; apenas layout, sem mudança de regras.
- **Gestos de data:** um toque seleciona; dois toques abrem a criação de tarefa;
  três abrem a criação de evento; toque longo abre uma prévia flutuante que
  fecha ao soltar. O encadeamento de múltiplos toques usa janela de 300 ms.
- **Prévia acompanha o dedo:** durante o toque longo, mover o dedo sobre outros
  dias visíveis atualiza a data e os post-its da prévia. O gesto fica preso à
  célula de origem, então as células registram sua geometria em um
  `DayPreviewRegistry` por grade; o retângulo sob o dedo define a data exibida.
- **Eventos entre semanas:** arraste normal alcança qualquer semana visível,
  inclusive soltando na faixa de eventos (lanes) de outra semana — a linha da
  semana é um `DragTarget` que converte a posição horizontal em coluna/dia. Nas
  bordas do grid aparecem zonas para mover ±7 dias e atualizar a data
  selecionada.
- **Posição do dedo no drop:** `DragTargetDetails.offset` traz o canto do
  feedback ancorado, não o toque. `PostItDragData.anchorOffset` registra a âncora
  no início do arraste para recuperar o ponto real e escolher a coluna certa.
- **Transições:** a chave do `AnimatedSwitcher` fica no filho direto
  (`RepaintBoundary`), garantindo folhear horizontal e morphing vertical.
- **Barras de evento:** o conteúdo é recuado das alças para o ícone não ficar sob
  o início; as alças têm grip visível e 24×24 dp de toque. O arraste começa após
  200 ms, evitando a sensação de travamento sem arrastar por acidente.
- **Moldura:** app em edge-to-edge com barras de status/navegação transparentes;
  espaçamentos principais em múltiplos de 8 px e ajustes finos em múltiplos de
  4 px. A grade mantém gutter óptico de 1,5 px entre células para preservar a
  densidade do mês.
- **Movimento:** seleção e alvo de arraste usam escala/cor/sombra; cartões e
  barras reagem ao toque; feedback de arraste usa `easeOutBack`; período
  horizontal folheia com rotação 3D (520 ms) e a mudança vertical de dias usa
  morphing fade + escala (360 ms). Redimensionamento acompanha o dedo em tempo
  real. O post-it destacado usa borda, escala 1,05 e elevação por 4 s.
- **Configurações:** tela com tema Sistema/Claro/Escuro, seis paletas com
  gradiente (Verde, Oceano, Pôr do sol, Lavanda, Rosa e Grafite), animações,
  manter tela
  ligada e dicas da agenda. Preferências ficam em `app_settings`; desligar
  animações zera as transições principais e o folhear/morphing. O acesso à
  sincronização fica em “Conexão e sincronização” e “Sobre o aplicativo” abre
  uma tela com versão, descrição e links.
- No mês compacto, o padding interno da célula é reduzido para preservar ao
  menos uma tarefa visível junto do indicador de overflow.
- A data selecionada é a âncora. Anterior/próximo move a seleção em um período
  (1, 4, 7, 14 dias; mês com dia preservado e clampado). No modo de 4 dias a
  janela começa na data selecionada e permanece ancorada ao tocar em outro dia
  visível; navegar desloca a janela inteira em 4 dias e preserva o offset.
- Mês compacto: grade dinâmica de 35 ou 42 células conforme o mês, incluindo
  dias de borda atenuados; nunca recortado em 30 dias.
- Trocar modo ou orientação não altera data, ordem ou qualquer dado; apenas
  preferência de visualização.
- Muitos post-its: limite por célula + indicador "+N" abrindo o dia.

## Repetição de eventos (esquema v6)

- Eventos podem repetir diariamente, a cada N semanas, a cada N meses ou
  anualmente. `recurrence` e `recurrenceInterval` ficam no post-it; tarefas e
  pendências nunca carregam repetição.
- Ocorrências são cópias virtuais geradas para o período visível, mantendo o ID
  da série e a duração. O evento base é a primeira ocorrência.
- Ocorrências mensais/anuais usam aritmética de calendário com clamp do dia
  (31 jan → 28/29 fev; 29 fev → 28 fev em anos não bissextos).
- Arrastar e redimensionar ficam desabilitados nas ocorrências geradas para não
  mover a âncora da série; tocar abre a série e o editor altera a regra.
- O esquema v6 migra de v1–v5; payloads/backups antigos sem os campos assumem
  `none`/`1`.

## Horário, tags e conclusão (esquema v7)

- Horário do evento é `timeMinutes` opcional (0–1439), relógio local; não é
  timestamp UTC nem participa da ordenação.
- Tags são uma tabela compartilhada (`id`, `name`, tom, timestamps) e
  `post_its.tag_ids` guarda as associações. Excluir tag gera tombstone e remove
  associações, nunca apaga o post-it.
- As tags usam papéis/containers do `ColorScheme`, acompanhando a paleta ativa em
  tema claro/escuro.
- Eventos ativos com `endDate` anterior a hoje viram concluídos automaticamente;
  a verificação é idempotente e grava um único `eventCompleted` no histórico.
  Eventos sem data final mantêm o comportamento anterior.
- O ícone junto ao título nos detalhes alterna concluída/reabrir sem fechar a
  folha.
- O esquema v7 migra de v1–v6; payloads/backups antigos assumem sem horário, sem
  tags e sem repetição.

## Descrições de tipo e prévia do dia

- O editor exibe um card único de descrição do tipo selecionado, no estilo do
  antigo card de Pendência; Feito reutiliza o texto de acontecimentos positivos.
- A prévia por toque longo reutiliza o overlay/registro existente e resolve os
  itens com `itemsCoveringDate`, incluindo eventos no mesmo formato das tarefas.
  As linhas de evento mantêm o rótulo do tipo e o horário opcional.
- As novas paletas são valores adicionais do enum; a preferência continua salva
  pelo nome da paleta, então seleções existentes não mudam.
- Os tons suaves de tag usam um destaque mais claro sobre a superfície, mantendo
  as seis opções do seletor visivelmente diferentes das sólidas.
- A Caixinha mantém a seleção de tags no topo, com botão de gerenciar/nova tag e
  estados vazios para ausência de tags, filtro sem resultados e busca sem
  resultados.
- Segurar um item na Caixinha abre um seletor de tags; é uma atualização
  focada (`setPostItTags`) que preserva todos os demais campos.
- Os tons de tag ficam limitados a cinco; o esquema v8 converte tags legadas
  `tertiarySoft` para `tertiary`, preservando a matiz em vez de descartar a tag.

## Rotinas e notificações (esquema v9)

- Rotinas são armazenadas localmente (`routines`, `routine_items`,
  `routine_completions`) e sincronizadas como uma entidade atômica `routine`.
  A conclusão usa `routine_item_id + data`, então cada ocorrência tem estado
  próprio; não existe conclusão global.
- `post_its.reminder_minutes` guarda a antecedência; lembretes exigem
  `time_minutes` e item ativo. O reagendamento cancela e reconstrói o conjunto
  local, sem duplicar e descartando itens resolvidos/passados.
- Notificações Android usam `flutter_local_notifications`. O ícone pequeno fica
  em `res/drawable/ic_stat_planner.xml` e é fixado por `res/raw/keep.xml`, pois
  o encolhimento de recursos o remove e o plugin lança `invalid_icon`.
- O agendamento prefere alarmes exatos (`exactAllowWhileIdle`) quando
  autorizados e cai para `inexactAllowWhileIdle` caso contrário. O manifesto
  declara `SCHEDULE_EXACT_ALARM` e `USE_EXACT_ALARM`; este último é concedido
  automaticamente no Android 13+, mas a política do Play o restringe a apps
  centrados em alarme/calendário.
- As Configurações expõem uma ação de teste que publica uma notificação
  imediata e agenda outra para 10 segundos depois, permitindo validar canal,
  permissão e agendador sem depender de lembretes reais.
- Windows e testes são no-op. O resumo diário é agendado para os próximos sete
  dias às 08:00.
- A casca de navegação agora tem uma superfície adaptativa: trilho em paisagem
  com Config/Sync no rodapé e barra de seis ações em retrato.
- Rotinas ainda não entram no sync nem no backup JSON; lembretes de post-its
  entram nos dois.

## Data de criação da rotina e interações de lista

- `createdAt` é o instante de criação da rotina e nunca é recalculado na edição.
  As ocorrências são ancoradas na data local de criação (`createdOn`); `runsOn`
  recusa datas anteriores. Isso é deliberadamente separado dos dias semanais de
  programação e de uma eventual data de início configurável.
- O sync de rotinas envia o `createdAt` original no payload; a mesclagem nunca
  usa o horário de recebimento como criação. A exclusão é um tombstone e o
  conjunto de atividades/conclusões viaja na mesma entidade.
- Servidores abaixo de 0.2.2 não aceitam a entidade; o app mantém as alterações
  de rotina na outbox local e continua sincronizando as demais entidades até o
  servidor ser atualizado.
- A reordenação é exclusiva da alça (`ReorderableDragStartListener`), para que
  campos de texto, checkboxes, navegação horizontal por dia e arraste não
  disputem o mesmo gesto. Cards de rotina persistem na hora; notas e rotinas já
  existentes também salvam a nova ordem ao terminar o arraste, enquanto
  rascunhos novos ainda usam o botão Salvar.
- Excluir um item de lista exige pressão contínua com confirmação circular.
  Soltar antes cancela; não há diálogo extra porque o gesto já é deliberado.
- A tela de Rotinas reutiliza a linguagem visual da Agenda (faixa de dias, cards
  na paleta ativa, tipografia compacta) sem copiar recursos específicos do
  calendário.
- A seleção de trechos da Nota usa um modo explícito: pressão longa entra nele,
  toques alternam linhas e um botão de fechar sai. Assim o toque para editar
  continua disponível fora da seleção e evita abrir o editor sem querer.
- Nenhuma migração de esquema foi necessária: `createdAt` já existia desde a v9.

## Localização

- **App:** Português (BR) e English, persistido em `app_settings`. `AppStrings`
  resolve textos em runtime e `DateFormats.locale` escolhe os padrões de data,
  sem serviço externo e sem reiniciar o app.
- **Página web do servidor:** português e inglês, com troca dinâmica no cliente
  (sem recarregar), persistida em `localStorage` e aplicada a textos, estados,
  contagem do QR e ações de dispositivo. O HTML mantém fallback em português
  para navegadores sem JavaScript.

## Navegação entre notas, caixinha e agenda

- **Seção compartilhada:** `AppNavigationController` mantém a seção atual da
  casca e permite que rotas empilhadas (detalhe de nota) voltem para a Agenda.
- **Abertura por UUID:** um único helper busca o post-it existente, abre o mesmo
  detalhe/edição e não cria cópia. Se o UUID não existir, mostra aviso e não
  navega.
- **Notas:** post-its com vínculo vivo (`noteId`) e snapshots com proveniência
  (`sourceNoteId`) listados no detalhe da nota têm duas ações: “Ver detalhes”
  (popup no local) e “Abrir na Agenda” (data selecionada + realce temporário).
- **Conteúdo editável:** tocar no Markdown renderizado ou em uma linha de lista
  abre o editor da nota; o toque longo continua reservado à seleção de linhas.
- **Caixinha:** o menu `...` mostra “Abrir na Agenda” somente quando
  `startDate != null`; as ações de status permanecem inalteradas.
- **Gestos da agenda:** arrastar na horizontal folheia o período com transição
  de página; arrastar na vertical aumenta/reduz a quantidade de dias.
- **Barra lateral:** trilho com largura mínima de 88 dp e altura total da
  casca, sem faixa vazia nas bordas.
- **Proveniência do snapshot:** `sourceNoteId` é metadado de origem para
  navegação; não é vínculo vivo, não altera o snapshot e não impede a nota de
  ser editada/excluída. Snapshots anteriores à migração v4 não têm proveniência.

## Idioma, desempenho e tamanho

- **Idioma:** Português (BR) e English, persistido em `app_settings`.
  `AppStrings` resolve textos em runtime; `DateFormats.locale` escolhe os
  padrões de data. Sem serviço externo e sem reiniciar o app.
- **Paletas:** seis gradientes (Verde, Oceano, Pôr do sol, Lavanda, Rosa e
  Grafite) combinados com claro/escuro; a cor-semente continua vindo do
  Material 3.
- **Desempenho:** build release split é a referência. O debug carrega runtime e
  símbolos (~188 MB); release arm64 ~21 MB. Grade principal em
  `RepaintBoundary`; animações podem ser desligadas em Configurações.
- **Dados:** SQLite compacto (~80 KB para 17 post-its, 3 notas e 58 registros de
  histórico). Histórico é mantido por auditoria, não por duplicação de eventos.
- README enxuto; detalhes históricos ficam em `docs/PROGRESSO.pt-BR.md`.

## Ambiente de validação

- **Somente dispositivo físico**, via `adb` (tablet Android 16 / HyperOS 3.0).
  Não há AVD, system image ou pacote `emulator` instalado; nada no projeto
  depende do emulador.
- Gestos podem ser injetados com `adb shell input`/`motionevent` no próprio
  aparelho; o build release é a referência de fluidez e tamanho.
- Em HyperOS/MIUI, instalar com `adb install -r -i com.android.vending` quando o
  install direto for bloqueado.

## Interoperabilidade, backup e sincronização

**Status:** backup e sincronização implementados (Etapas 1–6). CalDAV/iCalendar
continua como interoperabilidade futura; não há conta pública nem multiusuário.

### Configuração, pareamento e automação

- URL do servidor em `sync_state`; token individual em `flutter_secure_storage`.
- Página web administrativa no servidor: login com `ADMIN_TOKEN`, QR de
  pareamento renovado enquanto aberta, lista/revogação de dispositivos. O token
  temporário nunca é persistido no cliente; o QR contém o JSON aceito pelo app.
  A página alterna português/inglês no cliente e persiste a escolha no navegador.
- Configurações separa o estado do sync das ações de endereço: o card mostra
  “Pareado/Não pareado”, pendências, último sync e erro; o endereço e o teste de
  conexão ficam na tela **Endereço e teste de conexão**. O ícone de nuvem no
  topo reflete o estado e abre a seção já focada.
- A tela **Sobre** lê a versão do pacote (`package_info_plus`), mostra descrição
  curta e abre o repositório e o perfil do GitHub (`url_launcher`).
- Sessão web em memória (cookie HttpOnly/SameSite=Strict), separada dos tokens
  de dispositivo.
- O CLI `pair` permanece para automação e diagnóstico.
- Nome do dispositivo usa o modelo Android (`device_info_plus`) e pode ser
  corrigido/renomeado na página web (`POST /api/devices/<id>/label`), sem
  precisar reparear.
- Pareamento por JSON/QR gerado no servidor, com token de uso único (TTL 5 min);
  cada dispositivo recebe token próprio, revogável no servidor.
- Gatilhos: mudança local (watch da outbox + debounce), retomada, reconexão,
  botão manual e WorkManager periódico (15 min, best-effort, restrito a rede).
- Antes de aplicar, o app consulta `/v1/sync/stats` e compara com as contagens
  locais. Se ambos os lados têm dados, as contagens divergem e este é o primeiro
  sync ou não há outbox pendente, a operação para e pede escolha: manter local
  (envia o snapshot local e tombstone do que só existe no servidor), manter
  remoto (substitui o conteúdo local pelo snapshot remoto) ou cancelar. O sync
  automático nunca decide sozinho: fica em “Revisão necessária” até a escolha do
  usuário.
- Falha de sync não bloqueia a UI; estado e erro ficam visíveis em Configurações.
- `INTERNET`/`ACCESS_NETWORK_STATE` entraram apenas para o sync opcional;
  cleartext é aceito para servidor próprio na LAN/Tailscale.
- Cópia de conflito é o último recurso para não perder conteúdo; o vencedor é
  reenviado uma vez com `baseRev` alinhado.

### Banco local como fonte principal

- Drift/SQLite continua sendo a fonte de verdade do aplicativo.
- O Planner deve continuar funcionando integralmente offline.
- O arquivo SQLite não deve ser sincronizado diretamente entre dispositivos.
- A arquitetura local não deve ser substituída por uma solução dependente de
  servidor.

### Backup e restauração em JSON próprio

- Formato JSON versionado (`formatVersion` 1) com `schemaVersion`, versão do app,
  data de exportação, contagens e checksum SHA-256 sobre JSON canônico.
- Canonicalização: chaves ordenadas por code units, apenas inteiros, UTF-8
  literal, listas em ordem determinística (UUID, nota+posição, data+UUID).
- Exporta post-its, notas, linhas, histórico, tombstones e preferências de UI;
  credenciais e chaves `planner.sync.*` nunca entram no arquivo. As contagens do
  documento consideram apenas itens ativos (sem `deletedAt`), embora o backup
  continue preservando tombstones e todo o histórico. Backups antigos com
  contagens legadas continuam aceitos.
- Importação substitui todos os dados, com confirmação explícita, em uma única
  transação e após snapshot automático verificado (retenção de 5).
- Compatibilidade: aceita `formatVersion` 1 com `schemaVersion` 4 ou 5; recusa
  0/2+ e esquemas ≤ 3 ou > 5. Cada versão aceita tem upgrader testado.
- Snapshots e restauração ficam no diretório privado do app; a tela oferece
  restaurar um snapshot, que gera outro antes de aplicar.
- Formatos externos (iCalendar/CalDAV) continuam fora do backup principal.

### Interoperabilidade: Radicale, CalDAV e iCalendar

- **Radicale** é a referência de servidor CalDAV leve, open-source, executável
  por Docker; imagem considerada: `ghcr.io/kozea/radicale:stable`.
- **CalDAV** (RFC 4791) é o protocolo de comunicação/sincronização.
- **iCalendar** (RFC 5545) é o formato de interoperabilidade.
- Mapeamento previsto: eventos → `VEVENT`; tarefas → `VTODO`; propriedades
  específicas → `X-*`.
- O Radicale é uma camada de interoperabilidade, não um substituto do banco
  local nem uma sincronização completa do Planner.
- Recorrências com rollover próprio, Markdown, checklists, snapshots, histórico,
  vínculos e ordenação podem não ter equivalente no iCalendar. Dados internos
  não devem ser descartados para caber no padrão.
- Documentação: <https://radicale.org/>, <https://github.com/Kozea/Radicale>.
- O pacote Dart `caldav` pode ser avaliado em protótipo futuro, mas não é
  dependência aprovada sem testes reais de compatibilidade com o Radicale.

### Possível serviço próprio de sincronização

Implementado no repositório separado [stick2server](https://github.com/MikeMequis1/stick2server) (shelf + SQLite), sem
dependência de Flutter:

- entidades opacas com `rev` monotônica por item, log de mudanças com `seq` e
  cursor de pull;
- outbox local coalescente, com `changeId` para idempotência;
- tombstones transportados no payload;
- conflito por `baseRev`: servidor devolve a versão atual e o cliente resolve
  por `updatedAt` (cópia de conflito + reenvio do vencedor na Etapa 4);
- tokens individuais por dispositivo, revogáveis, guardados como SHA-256;
- pareamento por token de uso único (conteúdo do QR), TTL de 5 min;
- limite de corpo/payload/lote e comparação de token em tempo constante;
- importação de backup descarta outbox/cursor locais e preserva configuração.

### Conflitos e consistência (implementado)

- Push compara `baseRev` com a revisão atual; divergência devolve a versão do
  servidor, sem aplicar.
- Vencedor é o maior `updatedAt`; empate ou conteúdo idêntico → servidor.
- Servidor vence → versão aplicada e conteúdo local preservado como
  `[Conflito] <título>` (novo UUID; nota copia linhas com novos IDs).
- Local vence → `baseRev` alinhado e reenvio único; conflito residual vira cópia.
- Exclusão: tombstone do servidor gera cópia do conteúdo local; tombstone local
  não gera cópia.
- Ack remove a outbox somente se o `changeId` permanecer o mesmo; edição durante
  o push apenas atualiza `baseRev`.
- Pull, ack, revisões e cursor são gravados em uma transação local; falha desfaz
  tudo. Falha de rede mantém outbox e cursor intactos.

### Fundação local de sincronização (esquema v5)

- `sync_outbox`: payload canônico completo, `base_rev`, `change_id`, tentativas e
  erro; coalescência por `(entity, entity_id)`.
- `sync_row_states`: revisão do servidor aplicada por entidade.
- `sync_states`: `device_id`, cursor, servidor, habilitado, último sync/erro.
- Repositórios Drift gravam a outbox na mesma transação; aplicação remota usa
  caminho separado e não realimenta a fila.
- Nota é a unidade atômica (linhas/checklists no payload); histórico é
  append-only; preferências/credenciais não sincronizam.


### Escopo

Implementado: servidor próprio no repositório [stick2server](https://github.com/MikeMequis1/stick2server), pareamento por QR/código, tokens
individuais revogáveis, sync manual/automático, página web administrativa em
português/inglês e backup JSON. Continua fora do escopo: conta pública,
multiusuário e CalDAV/iCalendar.

## Fora de escopo no MVP

- Conta pública, multiusuário e CalDAV/iCalendar (interoperabilidade futura).
- Posicionamento livre de post-its.
- Editor WYSIWYG para Markdown e abertura de links externos dentro das notas.
- Seleção de substring arbitrária em listas (MVP: linha ou intervalo; em notas
  de texto o snapshot usa seleção no Markdown cru).

## Consistência otimista e qualidade final

- **Mover/redimensionar:** o estado em memória é atualizado antes do banco para
  evitar flicker; `saveBatch`/`save` seguem transacionais e o estado anterior é
  restaurado em falha.
- **Acessibilidade:** dias têm rótulo completo, estados “hoje/selecionado” e ação
  de toque; textos ampliados em 1,3× são validados em agenda e notas.
- **Offline:** o app abre e opera sem servidor; `INTERNET` e
  `ACCESS_NETWORK_STATE` existem apenas para a sincronização opcional. Os dados
  permanecem em SQLite local.
- **Entrega:** `docs/QUALIDADE.pt-BR.md` concentra matriz de validação, limitações e
  critérios finais.

## Pendente de decisão

Nenhuma no momento.
