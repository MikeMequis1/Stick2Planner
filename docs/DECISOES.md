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
  exibição Planner.
- **Consequência:** definido antes de existirem dados reais. Mudar depois cria
  outro app e perde o banco local.

## Datas e IDs

- **Decisão:** datas de calendário usam `DateOnly` (sem hora, persistido como
  `yyyy-MM-dd`); timestamps de auditoria usam UTC em milissegundos; IDs são
  UUID v4.
- **Consequência:** sem deslocamento de fuso/DST em regras de agenda; `Clock`
  injetável para testes determinísticos (nenhum `DateTime.now()` no domínio).

## Modelo de post-it

- Uma tabela `post_its` com `type` (`task`, `event`, `recurringTodo`),
  `status` (`active`, `done`, `cancelled`), `isHighlight` (símbolo `+`),
  `details`, `noteId` + `noteExcerpt`, `startDate`/`endDate`, `sortOrder`,
  `createdAt`/`updatedAt`, `deletedAt`.
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

## Movimentação, reordenação e redimensionamento

- Arrastar o corpo usa `LongPressDraggable` (evita arraste acidental ao
  rolar); células e cartões são `DragTarget`.
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
- Em telas estreitas (<600 dp), o FAB dá lugar a um ícone “+” na AppBar para
  não cobrir conteúdo.

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
  `ScreenWakeService`; a opção de desligar nas configurações fica para etapa
  futura (não implementada agora).

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
- **Prévia rápida:** painel compacto (até 200 px) acima do campo, com rolagem
  própria. É uma conferência, não um editor WYSIWYG; a sintaxe permanece no
  campo. Não há undo/redo próprio — usa o undo do campo do sistema.
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
  com ícones `+`/`−`, "Hoje" e divisor; apenas layout, sem mudança de regras.
- No mês compacto, o padding interno da célula é reduzido para preservar ao
  menos uma tarefa visível junto do indicador de overflow.
- A data selecionada é a âncora. Anterior/próximo move a seleção em um
  período (1, 4, 7, 14 dias; mês com dia preservado e clampado).
- Mês compacto: grade dinâmica de 35 ou 42 células conforme o mês, incluindo
  dias de borda atenuados; nunca recortado em 30 dias.
- Trocar modo ou orientação não altera data, ordem ou qualquer dado; apenas
  preferência de visualização.
- Muitos post-its: limite por célula + indicador "+N" abrindo o dia.

## Localização

- Interface exclusivamente pt_BR no MVP, com `flutter_localizations` e
  `intl` configurados. Textos em um único ponto para permitir i18n futura sem
  reescrever telas.

## Fora de escopo no MVP

- Servidor, autenticação remota, sincronização distribuída.
- Posicionamento livre de post-its.
- Editor WYSIWYG para Markdown e abertura de links externos.
- Seleção de substring arbitrária em listas (MVP: linha ou intervalo; em notas
  de texto o snapshot usa seleção no Markdown cru).

## Pendente de decisão

Nenhuma no momento.
