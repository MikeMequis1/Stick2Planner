[English](QUALITY.md) | **Português (Brasil)**

# Qualidade e entrega

Checklist do MVP local do Stick2Planner e das rodadas pós-MVP (sync opcional,
backup, página web e ajustes de celular).

## Escopo validado

- Agenda visual: períodos, eventos contínuos, criação, edição, arraste,
  reordenação, redimensionamento, estados, recorrência e janela ancorada de
  4 dias.
- Repetição de eventos: diária, a cada N semanas, a cada N meses e anual.\n- Horário de evento, tags compartilhadas e conclusão automática de eventos.\n- Caixinha: filtros, busca, tarefas sem data e acesso aos detalhes.
- Notas: texto Markdown, listas, snapshots e vínculos com post-its.
- Navegação: post-it vinculado/snapshot → Agenda → detalhe existente; Caixinha
  com “Abrir na Agenda” para post-its datados.
- Persistência local: drift/SQLite, transações, migrações v1 → v9 e tombstones.
- Configurações: tema, idioma Português/English, seis paletas com gradiente,
  animações, wakelock, dicas, conexão/sync e atalho para a tela Sobre.
- Sobre: versão instalada lida do pacote, descrição e links do GitHub.
- Backup: JSON versionado com checksum canônico, validação de versão/esquema,
  importação transacional com snapshot prévio e restauração de snapshots. As
  contagens exibidas ignoram itens apagados; os tombstones permanecem no JSON.
- Sync: servidor próprio, pareamento por QR/código, tokens revogáveis, página
  web em português/inglês, sync manual/automático, cópia de conflitos e
  conferência de contagens local × remoto antes de aplicar (manter local,
  manter remoto ou cancelar).

## Matriz de validação

| Área | Cobertura |
| --- | --- |
| Domínio | datas, recorrência, validação, layout de eventos |
| Banco | repositórios, transações, rollback, migrações |
| Backup | canonicalização, checksum, versões, round-trip, snapshots |
| Sync | outbox transacional, coalescência, migração v5, apply remoto |
| Servidor | auth, pareamento, idempotência, conflito, paginação, revogação |
| Web | login, sessão, QR vivo, dispositivos, renomear/revogar, PT/EN, retrato/paisagem |
| UI | agenda, caixinha, notas, editor, detalhes, vínculos, backup, Sobre |
| Layout | 1280×800, 800×1280, 780×360, 360×780, 500×800 e texto 1,3× |
| Aparelho | tablet Android 3200×2136 e celular 1080×2340, tema escuro |
| Carga | 200 post-its na agenda |
| Offline | sem servidor o app segue local; `INTERNET` só para sync opcional |

## Acessibilidade

- Dias da agenda expõem rótulo com data completa, indicação de “hoje” e
  “selecionado”, além da ação de toque.
- Post-its e barras de evento têm rótulo semântico próprio.
- Botões de ícone usam tooltip/`Semantics`.
- Alças de redimensionamento mantêm área de toque de 24×24 dp lógicos.
- Diálogos, campos e botões seguem os componentes Material 3 com rótulos.
- Alternativas aos gestos: FAB/AppBar para criar, detalhes para mover, editar,
  reordenar, redimensionar e alterar status.
- Teste de texto ampliado (1,3×) cobre agenda e editor Markdown.

## Offline e privacidade

- `INTERNET`/`ACCESS_NETWORK_STATE` existem apenas para sincronização opcional;
  sem servidor o app abre e opera normalmente.
- Dados ficam em SQLite no aparelho; o servidor é opcional e usa token por
  dispositivo guardado em armazenamento seguro.
- Serviços de plataforma: wakelock (tela ativa) e WorkManager (sync periódico
  best-effort).

## Consistência

- Mutações do planner são serializadas e persistidas em transações.
- Mover e redimensionar atualizam a UI de forma otimista; em falha de escrita o
  estado anterior é restaurado.
- Excluir nota remove vínculos vivos na mesma transação e preserva snapshots.
- Migrações preservam notas de texto legadas e listas.

## Limitações conhecidas

- CalDAV/iCalendar e Radicale não estão implementados; a interoperabilidade
  planejada está em `docs/DECISOES.pt-BR.md`.
- A sincronização exige um servidor próprio configurado e rede; não há conta
  pública nem multiusuário. Sem servidor, o app continua local.
- Quando local e remoto divergem, o sync automático pausa em “Revisão
  necessária” até o usuário escolher manter local, manter remoto ou cancelar.
- Links Markdown das notas são renderizados, mas não abrem navegador; os links
  da tela Sobre usam `url_launcher`.
- Snapshot de texto usa o Markdown cru; não é uma seleção WYSIWYG.
- Um post-it aceita um vínculo de nota por vez.
- Não há desfazer para exclusão de nota nem busca própria no caderno.
- Não há preferência de “reduzir movimento”; as animações são curtas.
- A grade mantém gutter óptico de 1,5 px entre células no mês.
- Dois/três toques abrem o formulário configurado; a gravação ocorre ao salvar.
- Snapshots criados antes da migração v4 não têm `sourceNoteId` e não aparecem
  em “Trechos desta nota”; continuam acessíveis pela Caixinha.
- “Abrir na Agenda” em Notas fica desabilitado para post-its sem data; o popup
  de detalhes continua disponível.
- WorkManager periódico é best-effort; o sistema pode adiar a execução.
- Filtros da Caixinha não são persistidos entre reinícios.

## Tamanho e desempenho

- APK debug: ~188 MB (runtime/símbolos de depuração).
- APK release split: ~25–31 MB por ABI, principalmente pelo ML Kit do leitor de
  QR; arm64 medido em ~25,8 MB no build mais recente.
- Banco local: ~80 KB para 17 post-its, 3 notas e 58 registros de histórico.
- Release é a referência para avaliar fluidez; animações podem ser desligadas.

## Comandos finais

```bash
flutter analyze
flutter test
flutter build apk --release --split-per-abi

cd stick2server
dart analyze
dart test
```

## Resultado

- `flutter analyze`: sem issues.
- `flutter test`: 298 testes aprovados.
- `dart analyze` / `dart test` no servidor: sem issues; 16 testes aprovados.
- `flutter build apk --release --split-per-abi`: aprovado e instalado no celular.
