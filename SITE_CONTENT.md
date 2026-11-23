# Stick2Planner — conteúdo para o Mike's Stash

Material de transição para a futura página do Stick2Planner no Mike's Stash.
Este documento é explicativo e pode repetir informações que não precisam
permanecer na documentação técnica do repositório. Ele não é a página final e não
substitui `README.md`, `docs/ARCHITECTURE.md`, `docs/DEVELOPMENT.md`,
`docs/SYNC.md` ou `docs/QUALITY.md`.

Estado de referência: **23 de novembro de 2026**, app **0.10.5+23**, esquema
SQLite **v13**, Stick2Server **0.2.3**.

---

## 1. Visão geral e motivação

**Stick2Planner** é um planner visual offline-first para Android, Windows e Linux.
A ideia central é simples: a agenda, as tarefas, as rotinas e as notas devem
funcionar como um mural de post-its — rápido de ler, fácil de reorganizar e
inteiramente local.

O projeto nasceu como uma alternativa pessoal a aplicativos de agenda que
dependem de conta, assinatura ou conexão permanente. Em vez de sincronizar tudo
com uma nuvem de terceiros, o Stick2Planner mantém um banco SQLite no aparelho e
oferece sincronização **opcional** com um servidor próprio, o
[Stick2Server](https://github.com/MikeMequis1/stick2server).

É um projeto de uso real, desenvolvido de forma incremental e multiplataforma:
tablet Android como cenário principal, desktop Windows/Linux como extensão do
mesmo código e do mesmo modelo de dados.

## 2. Problema que a aplicação procura resolver

Aplicativos de agenda costumam separar três coisas que, na prática, andam juntas:

- o compromisso com data e hora;
- a tarefa solta, que pode nem ter data;
- a nota ou o contexto que explica a tarefa.

Além disso, muitos produtos exigem conta, conexão constante e entregam pouca
previsibilidade sobre onde os dados ficam. O Stick2Planner procura resolver isso
com:

- **um único lugar** para eventos, tarefas, pendências, rotinas e notas;
- **estados explícitos** (ativa, concluída, cancelada) em vez de exclusão
  silenciosa;
- **persistência local** como fonte de verdade;
- **sincronização opcional** entre dispositivos, sem transformar o servidor em
  dependência;
- **interface adaptativa** para toque, mouse e teclado;
- **portabilidade** por backup JSON e por um esquema de banco versionado.

O objetivo não é competir com suítes corporativas. É ser um planner pessoal
confiável, legível e sustentável.

## 3. Filosofia de design e experiência de uso

### O post-it como unidade visual

Tudo na agenda é um post-it: tarefa, evento, pendência recorrente ou registro
**Feito**. A diferença aparece no tipo, no ícone, na cor e nas ações disponíveis,
não em telas separadas.

### Ordem, não coordenadas

Os itens têm uma ordem por dia (`sortOrder`), mas não uma posição x/y livre. Isso
mantém a leitura previsível em retrato, paisagem, tablet e desktop. Mover um item
é uma ação explícita; a grade se reorganiza sem quebrar o layout.

### Estados não apagam conteúdo

Concluir ou cancelar não remove o registro. A exclusão permanente grava um
tombstone (`deletedAt`), preservando histórico e permitindo que a sincronização
represente a remoção. O usuário vê o que aconteceu, em vez de perder o rastro.

### Cor não é a única informação

As cores vêm da paleta ativa e do tipo/estado, mas sempre acompanhadas de ícone,
símbolo ou texto. Isso mantém a interface compreensível em daltonismo, tema claro
e tema escuro.

### Offline por padrão

A ausência de servidor não é um modo degradado: é o modo normal. O app abre, edita,
busca, faz backup e reorganiza tudo sem rede. Quando há servidor, a sincronização
é um adicional.

### Desktop sem virar outro produto

A mesma interface se adapta: trilho lateral e atalhos no desktop, barra inferior
no celular. O objetivo é usar o mesmo domínio e o mesmo banco, não criar uma
segunda aplicação.

## 4. Funcionalidades principais

### Concluído e disponível

**Agenda**

- Modos dia, 4 dias, semana, 2 semanas e mês, com conjuntos específicos por
  orientação.
- Eventos de vários dias como um único registro contínuo, dividido visualmente
  por semana.
- Arraste, redimensionamento, reordenação, criação rápida e folha completa do dia.
- Janela de 4 dias ancorada e grade mensal de 35 ou 42 células.
- Dias passados com tom discreto; seleção, “hoje” e alças acessíveis.
- Carrossel horizontal contínuo, com transição que acompanha o dedo.

**Recorrência**

- Diária, a cada N semanas, a cada N meses ou anual.
- Data final opcional, independente da duração da ocorrência.
- Conclusão/cancelamento por ocorrência ou pela série inteira.
- Divisão da série ao arrastar uma ocorrência: o trecho anterior termina antes da
  ocorrência movida e um novo segmento começa na nova data, preservando o
  vínculo (`seriesId`) e os estados futuros.
- Tarefas também podem ser séries recorrentes. A pendência (`recurringTodo`)
  continua sendo um único registro que avança diariamente.

**Tarefas, Caixinha e tags**

- Tarefas com ou sem data, detalhes e vínculo com nota.
- Caixinha com busca, filtros por estado, “sem data”, filtros por tag e ordenação.
- Tags compartilhadas entre eventos e tarefas, com cinco tons derivados da paleta.
- Ações de estado no detalhe e na Caixinha.

**Feito**

- Registro positivo de um único dia, com ícone de lápis e explicação curta.
- Sem tags, duração ou recorrência; concluir, cancelar e redimensionar ficam
  indisponíveis de propósito.

**Notas**

- Notas de texto em Markdown ou listas de checklist.
- Barra rápida (títulos, negrito, itálico, listas, citação, link, código e
  prévia), com prévia ao lado em telas largas.
- Seleção de linhas por toque longo, com barra de ações.
- Snapshot de trecho: cópia literal que não muda quando a nota muda.
- Vínculo vivo: o post-it aponta para a nota inteira e oferece “Abrir nota”.
- Navegação entre nota, Caixinha e Agenda sem duplicar registros.

**Rotinas**

- Formato **simples**: lista semanal com conclusão por dia.
- Formato **completo**: cards com título, horário inicial/final, horários
  intermediários e uma tarefa por intervalo.
- Identidade estável de cards e intervalos: dividir um horário preserva a tarefa
  e as conclusões do lado esquerdo; remover um limite une os vizinhos; se ambos
  tiverem tarefa, o usuário escolhe qual manter.
- Conclusão por dia, arraste para reordenar, exclusão por toque longo.
- Lembretes por frequência ou horários explícitos, com ação **Concluir**.
- Histórico de execução append-only, independente do checkbox atual.
- Dashboard com totais, sequência, média, evolução, barras por período, heatmap de
  90 dias e totais por atividade.

**Notificações**

- Resumo diário dos próximos sete dias.
- Lembretes por item e por rotina, com antecedência configurável.
- Agendamento local no Android, sem internet.
- Alarme exato quando autorizado; caso contrário, entrega inexata.
- Ação de conclusão na notificação, registrando uma execução idempotente.

**Backup**

- Exportação JSON versionada com checksum SHA-256 canônico.
- Importação transacional, com snapshot automático verificado antes de substituir
  os dados.
- Retenção dos cinco snapshots pré-importação mais recentes.
- Backups antigos de esquemas 4 a 13 são aceitos.

**Sincronização opcional**

- Pareamento por QR code ou código textual.
- Token individual por dispositivo, revogável.
- Sincronização manual/automática, com revisão local × remoto.
- Cópias de conflito para não perder conteúdo.
- Mesclagem de rotinas por elemento (cards, intervalos, tarefas e datas).
- Funciona com servidor próprio em LAN, VPN/Tailscale ou proxy HTTPS.

**Interface**

- Tema claro/escuro/sistema, seis paletas e português/inglês.
- Layout adaptativo para tablet, celular e desktop.
- Atalhos de teclado, menus de contexto, arraste imediato com mouse.
- Dicas globais, manter tela ligada e animações desligáveis.

### Em desenvolvimento / validação

- Validação manual das versões 0.5–0.10 em aparelho físico. A última instalação
  Android registrada foi a 0.4.1; tags, rotinas, cards completos, lembretes de
  rotina, dashboard e carrossel estão cobertos por testes, mas não por uma sessão
  manual recente.
- Revisão do build Windows em uma máquina limpa (todas as telas, mouse, teclado,
  DPI, backup e caminho de dados).
- Teste real da interface Linux (GTK, keyring, janela) e publicação de artefatos
  Linux atualizados.
- Atualização das capturas de tela, que hoje são anteriores a tags, rotinas,
  desktop e carrossel.
- Assinatura do MSIX e definição do canal de distribuição desktop.

### Planejado / avaliado, não implementado

- CalDAV/iCalendar/Radicale para interoperabilidade externa.
- Notificações agendadas no desktop.
- Conta pública, multiusuário ou serviço de nuvem.
- Posicionamento livre de post-its por coordenadas.
- Edição WYSIWYG de Markdown e abertura de links externos dentro das notas.
- Busca dedicada no caderno de notas e undo de exclusão de nota.
- Redução de movimento como preferência explícita (as animações já podem ser
  desligadas e o carrossel respeita a preferência do sistema).

## 5. Arquitetura e tecnologias

### Aplicativo

- **Flutter/Dart** para Android, Windows e Linux.
- **Material 3** com tema, paleta e tipografia próprios.
- **Drift + SQLite** para persistência relacional, transações e migrações.
- **`flutter_secure_storage`** para tokens de sincronização.
- **`flutter_local_notifications`** para notificações locais no Android.
- **`workmanager`** para sincronização periódica best-effort no Android.
- **`mobile_scanner`** para QR no Android; desktop usa código manual.
- **`file_picker`**, **`url_launcher`**, **`wakelock_plus`**,
  **`connectivity_plus`**, **`package_info_plus`** e **`device_info_plus`** para
  integrações de plataforma.

### Camadas

```text
features (UI)
    ↓
app (controllers, composição, serviços)
    ↓
domain (entidades, regras, casos de uso)
    ↑
data (Drift, repositórios, backup, sync)
```

- `domain` é Dart puro, sem Flutter ou Drift.
- `data` implementa as interfaces de repositório do domínio.
- `app` monta o grafo de dependências e expõe os controllers por um
  `InheritedWidget` (`AppScope`).
- `features` só conversa com controllers; não acessa o banco diretamente.
- Estado com `ChangeNotifier` e `ListenableBuilder`, sem Riverpod/Bloc.

### Servidor

- Dart/shelf + SQLite, sem Flutter.
- Entidades opacas com revisão monotônica por item.
- Log de mudanças com cursor, idempotência por `changeId` e concorrência por
  `baseRev`.
- Tokens de dispositivo revogáveis, armazenados como SHA-256.
- Pareamento por token de uso único com TTL de 5 minutos.
- Imagens Docker `linux/amd64` e `linux/arm64`.

## 6. Persistência local e estratégia offline-first

- O banco fica em `planner.sqlite`, no diretório de suporte da plataforma.
- O esquema atual é **v13**, com migrações desde a v1.
- O app usa WAL, `busy_timeout` e chaves estrangeiras para lidar com escrita
  concorrente e integridade.
- Toda ação do usuário grava primeiro no SQLite.
- A outbox de sincronização é gravada na mesma transação da mudança de domínio.
- Exclusões usam tombstones; o histórico não é reescrito.
- O arquivo SQLite **não** é sincronizado diretamente entre dispositivos.
- O backup JSON é o caminho de portabilidade; a sincronização é por entidades.
- Sem servidor, o app continua abrindo, editando, buscando e exportando.

### Modelo conceitual

- **Post-it:** tarefa, evento, pendência recorrente ou Feito; datas, recorrência,
  ocorrências, tags, horário, lembrete, vínculo com nota e ordem.
- **Nota:** Markdown ou linhas de checklist; snapshots e vínculos vivos ficam no
  post-it.
- **Tag:** definição compartilhada; o post-it guarda os IDs.
- **Rotina:** simples (itens + conclusões) ou completa (cards + intervalos +
  tarefas + conclusões), com lembretes e histórico de execução.
- **Metadados de sync:** outbox, revisões aplicadas, bases de mesclagem e estado
  do dispositivo/servidor.

## 7. Desenvolvimento multiplataforma

O mesmo código Flutter, o mesmo domínio e o mesmo esquema rodam nas três
plataformas. O que muda é a camada de apresentação e o suporte a plugins nativos.

| Recurso | Android | Windows/Linux |
| --- | --- | --- |
| Agenda, Caixinha, notas, rotinas, backup, sync | Sim | Sim |
| Notificações locais agendadas | Sim | Não |
| Leitor de QR | Câmera | Código manual |
| Sync periódico em segundo plano | WorkManager | Oportunístico, com o app aberto |
| Token seguro | Armazenamento seguro Android | Credential Manager / Secret Service |
| Arraste | Toque longo | Mouse imediato |
| Atalhos e menus de contexto | Limitado | Completo |

### Desktop

- Janela inicial 1280×800, mínimo 900×600.
- Trilho lateral em janelas largas; barra inferior em janelas estreitas.
- `Ctrl+1…4`, `Ctrl+Tab`, `Ctrl+N`, `Ctrl+,`, `Ctrl+Shift+S`, `Ctrl+S`,
  `Ctrl+Enter`, `Ctrl+←/→`, `Alt+←/→`, `Ctrl++/-`, `Ctrl+T`, `F1`.
- Clique direito em dias, post-its, linhas da Caixinha, notas, rotinas e tags.
- Diálogos e folhas com largura limitada e centralizados.
- Exclusão explícita em listas, sem toque longo.

### Caminhos de dados

| Plataforma | Diretório |
| --- | --- |
| Android | diretório privado de suporte do app |
| Windows | `%APPDATA%\com.example\Stick2Planner` |
| Linux | `$XDG_DATA_HOME/com.mikemequis1.planner` |

O Windows mantém o nome de empresa legado `com.example` de propósito, para não
mover dados já existentes.

## 8. Stick2Server e sincronização

O Stick2Server é um serviço separado, auto-hospedado, feito em Dart/shelf +
SQLite. Ele não interpreta o conteúdo: armazena payloads JSON opacos por entidade,
com revisão por item e um cursor global de mudanças.

### Entidades

`postIt`, `note`, `history`, `tag`, `routine` e `routineExecution`.

### Pareamento

1. O servidor mostra um QR/código com URL, `serverId` e token de pareamento.
2. O token expira em 5 minutos e só pode ser usado uma vez.
3. O app troca o token por um token individual de dispositivo.
4. O token do dispositivo vai para o armazenamento seguro.
5. O pareamento já salva a URL, ativa a sincronização automática e dispara um
   sync imediato.

### Credenciais

- `ADMIN_TOKEN`: senha administrativa do servidor e da página web.
- Token de pareamento: temporário, de uso único.
- Token de dispositivo: autentica o sync; revogável individualmente.

Nunca publique tokens reais, endereços privados ou arquivos `.env`.

### Revisão local × remoto

Antes de sincronizar, o app compara contagens de post-its, notas, eventos,
tarefas, tags e rotinas. Se os dois lados têm dados e as contagens divergem, a
operação para e oferece:

- **Manter local:** envia o conjunto local; o que só existe no servidor vira
  tombstone.
- **Manter remoto:** substitui o conteúdo local pelo snapshot do servidor.
- **Cancelar:** não altera nenhum lado.

O sync automático nunca decide sozinho: fica em “Revisão necessária” até o usuário
escolher.

### Conflitos

- Entidades comuns: vence o maior `updatedAt`; empate mantém o servidor. A versão
  perdedora vira uma cópia `[Conflito]`.
- Rotinas: mesclagem de três vias (`base`, `local`, `servidor`) por IDs estáveis.
  Edições em cards/intervalos diferentes se combinam. O mesmo elemento alterado
  dos dois lados mantém o servidor e cria uma cópia local.
- Exclusão: tombstone do servidor com conteúdo local gera cópia; tombstone local
  não gera cópia.
- Aplicação, acks, revisões e cursor são gravados em uma única transação local.

### Compatibilidade

- Servidor 0.2.2+: aceita `routine`.
- Servidor 0.2.3+: aceita `routineExecution`.
- Servidor mais antigo: as entidades desconhecidas ficam na outbox local; o
  restante do sync continua.

### Segurança

- Tokens de dispositivo não entram em backups, logs ou banco local.
- A página web usa sessão em memória com cookie `HttpOnly`/`SameSite=Strict`.
- Exposição esperada: LAN, Tailscale/VPN ou proxy HTTPS. Não publique a porta
  8090 diretamente na internet.
- HTTP sem TLS é aceito apenas para servidor próprio em rede confiável.

## 9. Decisões técnicas importantes

| Decisão | Por quê | Efeito |
| --- | --- | --- |
| Drift + SQLite | Relações, transações, migrações e testes em memória | Codegen obrigatório; código gerado versionado |
| `ChangeNotifier` + `AppScope` | App pequeno, composição explícita | Menos framework; fiação manual de listeners |
| `DateOnly` para datas | Evita DST/fuso nas regras de calendário | Horários separados em minutos locais |
| `sortOrder` em vez de x/y | Layout legível em qualquer tela | Sem posicionamento livre |
| Tombstones | Histórico e sync precisam da exclusão | Consultas filtram `deletedAt` |
| Nota e rotina atômicas no sync | Evita estruturas parciais | Payloads maiores; servidor agnóstico |
| Mesclagem de rotina por ID | Edições independentes não devem gerar conflito | `sync_bases` é necessário |
| Histórico de execução sem FK | Excluir rotina não apaga histórico | Execuções órfãs são intencionais |
| Servidor opcional, nunca primário | Offline-first é requisito de produto | Sync tolera ausência e versões antigas |
| Desktop como alvo Flutter | Um só domínio e esquema | Plugins nativos são condicionais |

## 10. Desafios de implementação e soluções

### Arraste sem brigar com rolagem e seleção

No toque, o arraste começa com toque longo; no desktop, com o mouse imediato.
Alças de redimensionamento têm área de 24×24 dp e ficam separadas do corpo do
evento. Em listas, a alça de reordenação isola o gesto dos campos de texto e
checkboxes.

### Eventos de vários dias como um cartão contínuo

Um evento é um único registro, mas a grade é semanal. O layout calcula segmentos
por semana, marca continuações e mostra o título uma vez por período visível. As
faixas são ordenadas de forma determinística para não “pular” depois de um
arraste.

### Divisão de séries recorrentes

Mover uma ocorrência não pode desconectar o restante da série. A solução usa dois
registros com o mesmo `seriesId`: o primeiro termina antes da ocorrência movida;
o segundo começa na nova data e mantém a regra e a data final. Estados futuros são
remapeados pelo índice da ocorrência.

### Identidade de intervalos de rotina

Horários intermediários são limites, não itens independentes. Ao dividir, o lado
esquerdo conserva ID, tarefa e conclusões; o direito recebe novo ID. Ao remover um
limite, os vizinhos se unem; se ambos têm tarefa, o usuário escolhe qual manter.
Isso evita perda silenciosa de conteúdo.

### Conflitos de rotina sem depender do relógio

O servidor guarda a última versão aceita (`sync_bases`). Em conflito, o cliente
mescla base/local/servidor por ID. Edições em elementos diferentes se combinam; o
mesmo elemento alterado dos dois lados vira cópia `[Conflito]`, em vez de overwrite
silencioso.

### Ícone de notificação removido pelo build

O resource shrinking removeu o drawable pequeno e o plugin passou a lançar
`invalid_icon`. A correção fixa o ícone com `res/raw/keep.xml` e usa o drawable
`ic_stat_planner` na inicialização e nos detalhes.

### Histórico órfão no sync

Uma entrada de histórico podia referenciar um post-it já ausente, causando
`SQLITE_CONSTRAINT_FOREIGNKEY` e rollback do pull inteiro. A aplicação agora
verifica o pai e ignora a entrada órfã, registrando a revisão sem fabricar dados.

### Carrossel pintando fora da área

`RenderStack` não reporta overflow de transformação como overflow de layout. O
carrossel foi envolvido em `ClipRect` para não invadir o trilho de navegação. A
transição duplicada foi resolvida recriando o `AnimatedSwitcher` com apenas o
período revelado no mesmo frame do reset do offset.

### Compatibilidade com clientes antigos de rotina

Um cliente anterior a 0.8 não entende `mode`/`sections`. O servidor preserva os
cards completos já armazenados quando chega uma atualização sem essas chaves, em
vez de apagá-los. O cliente antigo continua sem exibir cards, mas não destrói a
estrutura.

## 11. Testes e validação

### Automação

Estado em 23/11/2026:

```text
flutter analyze  → sem problemas
flutter test     → 381 testes aprovados
```

O número inclui as regressões do destaque do dia ativo, da janela de toques no
dia selecionado e das cores de evento por tag.

A suíte cobre domínio, banco e migrações v1 → v13, backup, sync entre dois
dispositivos, mesclagem de rotinas, UI, acessibilidade com texto 1.3×, carga de
200 post-its e contrato offline.

O Stick2Server 0.2.3 teve, no último registro, `dart analyze` limpo e 20 testes
aprovados, incluindo séries de tarefas recorrentes e histórico de execução.

### Builds

- Android 0.10.5: APK arm64 (~30 MB) e universal (~84 MB), publicados na release.
- Windows 0.10.5: ZIP portátil (~15 MB) e MSIX não assinado (~15 MB), publicados
  na release.
- Linux: último build registrado foi 0.6.2 (tar.gz, `.deb` e AppImage) em WSL
  Ubuntu 26.04; não publicado na release atual.

### Validação manual

- Tablet Android 16/HyperOS 3.0, 3200×2136, tema escuro: etapas 1-6 validadas em
  03/11/2026.
- Notificações: teste imediato e agendado em 10 s validado na 0.4.1.
- Sync real com tablet e celular via Tailscale/LAN na fase 0.2.x.
- Windows: build e empacotamento aprovados; revisão em máquina limpa pendente.
- Linux: empacotamento aprovado; teste real de GUI pendente.
- Android 0.10.5: build de trabalho instalado; carrossel, recorte, toque no dia,
  cores por tag, rotinas/dashboard e navegação gravada com dados de teste.

### O que ainda não foi validado manualmente

Divisão de séries, lembretes de rotina, cards completos em uso real, TalkBack,
caneta e multitouch contínuo não têm sessão manual registrada. Essas áreas têm
cobertura automatizada, mas isso não é o mesmo que validação em aparelho.

## 12. Limitações conhecidas

### Produto

- Sync exige servidor próprio; não há conta pública, nuvem ou multiusuário.
- CalDAV/iCalendar/Radicale ainda não existem.
- Divergência local/remoto exige decisão manual.
- Conflito no mesmo elemento de rotina gera cópia, não fusão automática.
- Links Markdown não abrem navegador.
- Um post-it aceita um vínculo vivo de nota por vez.
- Snapshot de texto usa o Markdown bruto, não seleção WYSIWYG.
- Não há undo de exclusão de nota nem busca dedicada no caderno.
- Filtros da Caixinha não persistem ao reiniciar.
- Snapshots anteriores à migração v4 não têm proveniência.
- “Abrir na Agenda” fica desabilitado para post-its sem data.
- Feito não aceita tags, duração, recorrência, conclusão ou redimensionamento.
- Não há posicionamento livre de post-its.

### Plataforma

- Notificações agendadas, QR e sync periódico são Android-only.
- WorkManager é best-effort e pode atrasar.
- `USE_EXACT_ALARM` tem restrição de política; sem permissão, a entrega é inexata.
- Desktop não agenda notificações nem lê QR.
- Windows exige Developer Mode para build e o runtime VC++; o MSIX é não assinado
  por padrão.
- Linux exige Secret Service para token seguro; o AppImage ainda usa GTK do host.
- O build Android de release usa assinatura de debug até que um keystore real seja
  configurado.

### Validação

- Sem CI; analyze, testes e builds são manuais.
- Sem benchmark em aparelhos fracos.
- Capturas de tela de 03/11/2026 estão desatualizadas.
- Uma captura de mês contém uma notificação pessoal de mensagens e não deve ser
  publicada.

## 13. Evolução do projeto

Resumo de marcos, não um changelog completo:

- **0.1.x (nov/2026):** MVP local com agenda, Caixinha, notas, Markdown,
  acessibilidade, i18n, paletas e backup JSON.
- **0.2.x:** servidor próprio, pareamento, tokens, sync manual/automático,
  revisão local × remoto e página web administrativa.
- **0.3.x:** tags, horário de evento, conclusão automática, backup com contagem
  de ativos e ajustes de interface.
- **0.4.x:** rotinas simples, notificações locais, correção do ícone e teste de
  notificação.
- **0.5–0.6.x:** data de criação da rotina, reordenação por alça, exclusão por
  toque longo, sync de rotinas, backfill da outbox e correção de histórico órfão.
- **0.7.0:** ocorrências recorrentes com data final, status por ocorrência e
  ajustes de Feito/faixas.
- **0.8.0:** rotinas completas com cards, intervalos e tarefas.
- **0.9.0:** mesclagem de conflitos de rotina por elemento e proteção de cards
  completos contra clientes antigos.
- **0.10.x:** novo carrossel contínuo, seletor de mês/ano, divisão de séries,
  lembretes de rotina, histórico de execução, dashboard e séries de tarefas
  recorrentes.
- **Desktop:** alvo Windows/Linux adicionado entre 0.9 e 0.10, com ZIP, MSIX,
  tar.gz, `.deb` e AppImage opcional.

## 14. Capturas de tela recomendadas

**Atenção:** todas as imagens de `docs/validacao/` são de 03/11/2026 e mostram uma
versão anterior a tags, rotinas, notificações, desktop e carrossel. Elas servem
como referência de linguagem visual, não como retrato fiel da versão 0.10.5.
Recomenda-se recapturar antes de publicar a página.

Seleção de transição (7 imagens), mantendo os originais intactos:

| Imagem | Uso sugerido | Justificativa |
| --- | --- | --- |
| `etapa6-agenda.png` | Hero / agenda semanal | Mostra eventos multi-dia, estados, barras e leitura geral da agenda |
| `rodada-redimensionar-ao-vivo.png` | Redimensionamento / eventos longos | Expõe alças, faixas e eventos sobrepostos |
| `etapa4-caixinha.png` | Caixinha | Busca, filtros por estado e lista de itens |
| `etapa5-markdown-previa-direita.png` | Notas / editor | Barra Markdown, editor e prévia lado a lado |
| `etapa5-nota-detalhe.png` | Notas / vínculos | Página da nota, ações e post-it vinculado |
| `etapa5-snapshot-postit.png` | Snapshot | Detalhe do post-it com trecho copiado e ações |
| `aparelho-retrato.png` | Layout retrato | Mostra a adaptação para celular/tablet em pé |

Não selecionar:

- `round-carga-mes.png`: contém uma notificação pessoal de mensagens.
- `configuracoes.png`: mostra uma versão antiga, sem sync, e uma paleta incompleta.
- `aparelho-arraste.png` e `aparelho-resize.png`: mostram o resultado, mas não o
  gesto; prefira recapturar.
- Capturas de estados intermediários ou de telas que mudaram de cabeçalho,
  navegação ou número de seções.

Recapturas prioritárias para a página final:

1. Agenda em paisagem com rotinas e tags visíveis.
2. Arraste de um post-it em andamento.
3. Redimensionamento de evento com alça visível.
4. Caixinha com filtros de tag.
5. Rotina completa com cards, intervalos e dashboard.
6. Notas com Markdown, snapshot e vínculo.
7. Desktop Windows com trilho, atalhos e menu de contexto.
8. Retrato em celular.

As versões otimizadas podem ficar no site; o repositório não precisa manter uma
galeria extensa.

## 15. Links e estrutura sugerida para a página

### Links

- Repositório: <https://github.com/MikeMequis1/Stick2Planner>
- Releases: <https://github.com/MikeMequis1/Stick2Planner/releases>
- Stick2Server: <https://github.com/MikeMequis1/stick2server>
- Documentação técnica: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md),
  [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md), [`docs/SYNC.md`](docs/SYNC.md),
  [`docs/QUALITY.md`](docs/QUALITY.md)
- Perfil: <https://github.com/MikeMequis1>

### Estrutura sugerida (modelo Asher)

```text
🗓️ Stick2Planner
├── 🎯 Visão geral
├── 🧠 Arquitetura
├── ✨ Funcionalidades
├── 📱 Plataformas e instalação
├── 🔄 Stick2Server e sincronização
├── 🧪 Testes e validação
├── 📊 Status e roadmap
├── ❓ FAQ
└── ⬇️ Releases
```

### FAQ curta sugerida

- **Preciso de conta?** Não.
- **Funciona sem internet?** Sim, por completo.
- **O servidor é obrigatório?** Não; é opcional e auto-hospedado.
- **Há versão para iPhone?** Não no estado atual.
- **Onde ficam meus dados?** Em SQLite local, com backup JSON e sync opcional.
- **Linux tem instalador?** O script gera tar.gz, `.deb` e AppImage; os artefatos
  Linux ainda não estão publicados na release atual.
- **As capturas são da versão atual?** Não; foram feitas em 03/11/2026 e serão
  substituídas.

### Texto curto para o topo da página

> **Stick2Planner** é um planner visual offline-first para Android, Windows e
> Linux. Agenda, tarefas, rotinas e notas Markdown ficam no seu aparelho; a
> sincronização com um servidor próprio é opcional. Sem conta, sem nuvem
> obrigatória e sem dependência de conexão.
