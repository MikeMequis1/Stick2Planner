# Qualidade e entrega — Etapa 6

Checklist final do MVP local do Planner.

## Escopo validado

- Agenda visual: períodos, eventos contínuos, criação, edição, arraste,
  reordenação, redimensionamento, estados e recorrência.
- Caixinha: filtros, busca, tarefas sem data e acesso aos detalhes.
- Notas: texto Markdown, listas, snapshots e vínculos com post-its.
- Navegação: post-it vinculado/snapshot → Agenda → detalhe existente; Caixinha
  com “Abrir na Agenda” para post-its datados.
- Persistência local: drift/SQLite, transações, migrações v1 → v2 → v3 → v4 e
  tombstones.
- Configurações: tema, idioma Português/English, quatro paletas com gradiente,
  animações, wakelock e dicas persistidos localmente.
- Backup: JSON versionado com checksum canônico, validação de versão/esquema,
  importação transacional com snapshot prévio e restauração de snapshots.

## Matriz de validação

| Área | Cobertura |
| --- | --- |
| Domínio | datas, recorrência, validação, layout de eventos |
| Banco | repositórios, transações, rollback, migrações |
| Backup | canonicalização, checksum, versões, round-trip, snapshots |
| UI | agenda, caixinha, notas, editor, detalhes, vínculos, backup |
| Layout | 1280×800, 800×1280, 500×800 e texto ampliado em 1,3× |
| Aparelho | tablet Android 3200×2136, tema escuro |
| Carga | 200 post-its na agenda |
| Offline | ausência de permissão `INTERNET` e banco local |

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

- Nenhuma permissão de internet no `AndroidManifest.xml`.
- Dados ficam em SQLite no aparelho; não há sincronização nesta etapa.
- O único serviço de plataforma é o wakelock, usado para manter a tela ativa
  durante o uso do planner.

## Consistência

- Mutações do planner são serializadas e persistidas em transações.
- Mover e redimensionar atualizam a UI de forma otimista; em falha de escrita o
  estado anterior é restaurado.
- Excluir nota remove vínculos vivos na mesma transação e preserva snapshots.
- Migrações preservam notas de texto legadas e listas.

## Limitações conhecidas

- O app não sincroniza entre dispositivos.
- Links Markdown são renderizados, mas não abrem navegador.
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
- Importação, exportação, CalDAV e sincronização não foram implementados;
  decisões registradas em `docs/DECISOES.md`.

## Tamanho e desempenho

- APK debug: ~188 MB (runtime/símbolos de depuração).
- APK release split: ~19–22 MB; arm64 ~21 MB.
- Banco local: ~80 KB para 17 post-its, 3 notas e 58 registros de histórico.
- Release é a referência para avaliar fluidez; animações podem ser desligadas.

## Comandos finais

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Resultado

- `flutter analyze`: sem issues.
- `flutter test`: 195 testes aprovados.
- `flutter build apk --debug`: aprovado.
