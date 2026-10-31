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
- **Ordem, não coordenadas:** não há posição livre x/y. O layout é responsivo
  e ordenado por `sortOrder` por dia; coordenadas absolutas quebrariam a
  legibilidade em outra orientação.
- **Cor não é dado:** cores derivam de tipo/estado e sempre vêm acompanhadas
  de ícone, símbolo ou rótulo.
- **Exclusão:** concluir/cancelar nunca apaga; exclusão definitiva grava
  tombstone (`deletedAt`), preservando histórico e preparando sync.

## Eventos de múltiplos dias — cartão contínuo

- **Decisão aprovada:** um evento estendido é **um único post-it contínuo**
  entre os dias, não cartões repetidos.
- **Consequência de implementação (Etapa 2/3):** a grade precisa de uma camada
  de sobreposição para desenhar o cartão atravessando colunas/dias, com
  identidade única, extremidades arrastáveis nas pontas e indicação de
  continuação. O layout por célula deve reservar "faixas" para esses eventos.
  Arrastar o corpo move o intervalo inteiro; arrastar as alças altera apenas a
  extremidade correspondente.

## TO-DO recorrente

- Uma única linha; nunca gera cópias. Pendente e com data nula/atrasada →
  `startDate = hoje local`. Recálculo é absoluto e idempotente; executar várias
  vezes não duplica nem avança além do necessário.
- Executado no boot, no `resumed` do ciclo de vida e antes de operações de
  agenda. Sem timers contínuos e sem serviço em background.
- Concluído/cancelado para de avançar e permanece na caixinha.
- **Adiamento manual:** soltar em data futura fixa a data e suspende o avanço
  até ela; soltar em data passada/hoje normaliza para hoje. O cartão recebe
  indicação visual de "adiado" (distinta do avanço automático), e a regra é
  explicada na interface.

## Notas

- Notas têm linhas (`note_lines`) para texto e checklists; a seleção para
  criar post-it é um intervalo de linhas contíguas.
- Vínculo: `noteId` (referência viva, "Abrir nota") e `noteExcerpt` opcional
  (snapshot do trecho). O snapshot não acompanha edições posteriores e isso é
  informado na interface. Uma nota pode alimentar vários post-its.

## Calendário

- Paisagem: semana, duas semanas, mês compacto.
- Retrato: dia, quatro dias, semana.
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
- Seleção de substring arbitrária em notas (MVP: linha ou intervalo de linhas).

## Pendente de decisão

Nenhuma no momento.
