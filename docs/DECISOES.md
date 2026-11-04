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
- **Configurações:** tela com tema Sistema/Claro/Escuro, quatro paletas com
  gradiente (Verde, Oceano, Pôr do sol e Lavanda), animações, manter tela
  ligada e dicas da agenda. Preferências ficam em `app_settings`; desligar
  animações zera as transições principais e o folhear/morphing.
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
- **Paletas:** quatro gradientes (Verde, Oceano, Pôr do sol, Lavanda) combinados
  com claro/escuro; a cor-semente continua vindo do Material 3.
- **Desempenho:** build release split é a referência. O debug carrega runtime e
  símbolos (~188 MB); release arm64 ~21 MB. Grade principal em
  `RepaintBoundary`; animações podem ser desligadas em Configurações.
- **Dados:** SQLite compacto (~80 KB para 17 post-its, 3 notas e 58 registros de
  histórico). Histórico é mantido por auditoria, não por duplicação de eventos.
- README enxuto; detalhes históricos ficam em `docs/PROGRESSO.md`.

## Ambiente de validação

- **Somente dispositivo físico**, via `adb` (tablet Android 16 / HyperOS 3.0).
  Não há AVD, system image ou pacote `emulator` instalado; nada no projeto
  depende do emulador.
- Gestos podem ser injetados com `adb shell input`/`motionevent` no próprio
  aparelho; o build release é a referência de fluidez e tamanho.
- Em HyperOS/MIUI, instalar com `adb install -r -i com.android.vending` quando o
  install direto for bloqueado.

## Interoperabilidade, backup e sincronização (etapa futura)

**Status:** decisões registradas; nada implementado nesta rodada. Não há
servidor, CalDAV, importação, exportação ou sincronização no código atual.

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
  credenciais e chaves `planner.sync.*` nunca entram no arquivo.
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

Uma sincronização completa entre instalações pode exigir um serviço próprio,
também executável em Docker. A arquitetura poderá considerar:

- outbox de alterações;
- UUIDs estáveis;
- versionamento;
- tombstones;
- ETags;
- detecção e resolução de conflitos;
- sincronização oportunística, sem impedir o uso offline.

### Escopo

A implementação pertence a uma etapa futura ainda não iniciada. Esta rodada
apenas registra as decisões e mantém o MVP local intacto.

## Fora de escopo no MVP

- Servidor, autenticação remota, sincronização distribuída.
- Posicionamento livre de post-its.
- Editor WYSIWYG para Markdown e abertura de links externos.
- Seleção de substring arbitrária em listas (MVP: linha ou intervalo; em notas
  de texto o snapshot usa seleção no Markdown cru).

## Consistência otimista e qualidade final

- **Mover/redimensionar:** o estado em memória é atualizado antes do banco para
  evitar flicker; `saveBatch`/`save` seguem transacionais e o estado anterior é
  restaurado em falha.
- **Acessibilidade:** dias têm rótulo completo, estados “hoje/selecionado” e ação
  de toque; textos ampliados em 1,3× são validados em agenda e notas.
- **Offline:** teste de contrato garante ausência da permissão `INTERNET`; os
  dados permanecem em SQLite local.
- **Entrega:** `docs/QUALIDADE.md` concentra matriz de validação, limitações e
  critérios finais.

## Pendente de decisão

Nenhuma no momento.
