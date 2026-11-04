/// Textos da interface em pt_BR, centralizados para permitir i18n futura.
abstract final class AppStrings {
  static const appName = 'Stick2Planner';

  static const agenda = 'Agenda';
  static const inbox = 'Caixinha';
  static const notes = 'Notas';

  static const agendaPlaceholderTitle = 'Agenda visual em construção';
  static const agendaPlaceholderBody =
      'A grade de dias, os post-its e os gestos de arrastar entram na '
      'próxima etapa. A data e as preferências já são persistidas.';

  static const inboxPlaceholderTitle = 'Caixinha em construção';
  static const inboxPlaceholderBody =
      'Filtros por estado, busca e tarefas sem data chegam na Etapa 4.';

  static const notesEmptyMessage =
      'Crie uma nota livre ou uma lista; depois selecione linhas para gerar '
      'post-its.';

  static const today = 'Hoje';
  static const selectedDay = 'selecionado';
  static const selectedDate = 'Data selecionada';
  static const postItsOnDay = 'Post-its no dia';
  static const undated = 'Sem data';
  static const active = 'Ativas';
  static const done = 'Concluídas';
  static const cancelled = 'Canceladas';
  static const notesCount = 'Notas';

  static const newNote = 'Nova nota';
  static const editNote = 'Editar nota';
  static const noteTitle = 'Título da nota';
  static const noteTypeText = 'Texto';
  static const noteTypeMarkdown = 'Texto · Markdown';
  static const noteTypeChecklist = 'Lista';
  static const markdownLabel = 'Markdown';
  static const markdownFieldHint =
      '# Título\n\nEscreva livremente. Use **negrito**, *itálico*, listas, '
      'links e blocos de código.';
  static const markdownHint =
      'Markdown: # título, **negrito**, *itálico*, - item, 1. item, '
      '[link](url), `código`.';
  static const markdownToolsHeading1 = 'Título 1';
  static const markdownToolsHeading2 = 'Título 2';
  static const markdownToolsHeading3 = 'Título 3';
  static const markdownToolsBold = 'Negrito';
  static const markdownToolsItalic = 'Itálico';
  static const markdownToolsBulletList = 'Lista com marcadores';
  static const markdownToolsNumberedList = 'Lista numerada';
  static const markdownToolsLink = 'Link';
  static const markdownToolsInlineCode = 'Código inline';
  static const markdownToolsCodeBlock = 'Bloco de código';
  static const markdownToolsQuote = 'Citação';
  static const markdownToolsShowPreview = 'Mostrar prévia';
  static const markdownToolsHidePreview = 'Ocultar prévia';
  static const markdownPreviewTitle = 'Prévia';
  static const markdownPreviewEmpty = 'Nada para pré-visualizar.';
  static const markdownLinkPlaceholder = 'texto';
  static const createPostItFromMarkdown = 'Criar post-it de trecho…';
  static const snapshotSelectionHint =
      'Selecione um trecho abaixo. Sem seleção, será usada a nota inteira.';
  static const selectWholeNote = 'Nota inteira';
  static const noMarkdown = 'Nota sem conteúdo.';
  static const addLine = 'Adicionar linha';
  static const lineHint = 'Escreva uma linha';
  static const noteTitleRequired = 'Informe um título para a nota.';
  static const noteSaveError = 'Não foi possível salvar a nota.';
  static const noteDeleteError = 'Não foi possível excluir a nota.';
  static const selectLinesHint =
      'Mantenha pressionada uma linha para selecionar um trecho.';
  static const createPostItFromSelection = 'Criar post-it do trecho';
  static const clearSelection = 'Limpar seleção';
  static const noteLinkedPostIts = 'Post-its vinculados';
  static const createTaskFromNote = 'Criar tarefa com esta nota';
  static const linkToPostIt = 'Vincular a post-it…';
  static const linkNote = 'Vincular nota…';
  static const unlinkNote = 'Desvincular nota';
  static const openNote = 'Abrir nota';
  static const openInAgenda = 'Abrir na Agenda';
  static const postItNotFound = 'Post-it não encontrado.';
  static const postItWithoutDate = 'Este post-it não tem data definida.';
  static const showPostItDetails = 'Ver detalhes';
  static const noteSnapshots = 'Trechos desta nota';
  static const selectNote = 'Selecionar nota';
  static const selectPostIt = 'Selecionar post-it';
  static const noteDeleted = 'Nota excluída.';
  static const deleteNote = 'Excluir nota';
  static const deleteNoteQuestion = 'Excluir nota?';
  static const deleteNoteExplanation =
      'A nota sairá do caderno, mas o registro será preservado no banco.';
  static const deleteNoteLinkedWarning =
      'Esta nota está vinculada a post-its. Os vínculos serão removidos; '
      'trechos já copiados são preservados.';
  static const noteSnapshotHint =
      'Snapshot: editar a nota não altera este texto.';
  static const noteLiveLink =
      'Nota vinculada: o conteúdo acompanha as edições da nota.';
  static const linkedNoteChip = 'Nota vinculada';
  static const noteExcerptChip = 'Trecho copiado';
  static const noNotes = 'Nenhuma nota ainda.';
  static const noLines = 'Nenhuma linha.';
  static const selectPostItEmpty = 'Nenhum post-it disponível.';
  static const linkNoteError = 'Não foi possível vincular a nota.';
  static const createPostItError = 'Não foi possível criar o post-it.';
  static const noteLines = 'linhas';

  static String noteCount(int count) =>
      '$count ${count == 1 ? 'nota' : 'notas'}';
  static String linkedPostItsCount(int count) =>
      '$count ${count == 1 ? 'post-it' : 'post-its'}';

  static String selectedLines(int count) => '$count selecionada(s)';

  static const loading = 'Carregando dados locais…';
  static const loadError = 'Não foi possível carregar os dados locais.';
  static const emptyInbox = 'Nada na caixinha ainda.';
  static const emptyNotes = 'Nenhuma nota criada ainda.';
  static const allFilter = 'Todas';
  static const itemsCount = 'itens';
  static const searchHint = 'Buscar por título, detalhe ou nota';
  static const sortBy = 'Ordenar';
  static const sortDate = 'Data';
  static const sortUpdated = 'Atualização';
  static const sortTitle = 'Título';
  static const noResults = 'Nenhum post-it encontrado.';
  static const editInInbox = 'Editar';
  static const statusMenu = 'Ações de estado';

  static const nextStage = 'Próxima etapa';
  static const offlineNotice = 'Funciona offline: dados salvos neste tablet.';

  static const settings = 'Configurações';
  static const settingsAppearance = 'Aparência';
  static const settingsTheme = 'Tema';
  static const settingsThemeSystem = 'Sistema';
  static const settingsThemeLight = 'Claro';
  static const settingsThemeDark = 'Escuro';
  static const settingsPalette = 'Paleta de cores';
  static const settingsPaletteHelp =
      'Gradiente de fundo e cor de destaque do aplicativo.';
  static const settingsAnimations = 'Animações';
  static const settingsAnimationsHelp =
      'Ativa transições, folhear de páginas e efeitos de toque.';
  static const settingsKeepAwake = 'Manter tela ligada';
  static const settingsKeepAwakeHelp =
      'Evita que a tela desligue enquanto o planner estiver aberto.';
  static const settingsHints = 'Dicas da agenda';
  static const settingsHintsHelp =
      'Mostra a dica de gestos e a contagem de post-its sem data.';
  static const settingsAbout = 'Sobre';
  static const settingsLocalData =
      'Dados salvos localmente neste tablet, sem sincronização nesta versão.';

  static const viewModeDay = 'Dia';
  static const viewModeFourDays = '4 dias';
  static const viewModeWeek = 'Semana';
  static const viewModeTwoWeeks = '2 semanas';
  static const viewModeMonth = 'Mês';
  static const recurringShort = 'Recorrente';
  static const recurringHelp =
      'Aparece hoje e avança sozinho para o próximo dia enquanto estiver '
      'pendente, até ser concluído ou cancelado.';
  static const postponed = 'Adiado';
  static const advancesDaily = 'Avança diariamente';
  static const postponedUntil = 'Adiado até';
  static const recurringPostponedHelp =
      'Enquanto adiado, não avança. Depois da data, volta a ser carregado '
      'para o dia atual se continuar pendente.';
  static const statusDoneAction = 'Concluir';
  static const statusCancelAction = 'Cancelar tarefa';
  static const statusReopenAction = 'Reabrir';
  static const statusUpdatedMessage = 'Estado atualizado.';

  static const previousPeriod = 'Período anterior';
  static const nextPeriod = 'Próximo período';
  static const decreaseDays = 'Menos dias';
  static const increaseDays = 'Mais dias';

  static const taskType = 'Tarefa';
  static const eventType = 'Evento';
  static const recurringType = 'TO-DO recorrente';
  static const highlightType = 'Evento marcante';
  static const eventSymbol = '✮';
  static const highlightSymbol = '+';

  static const detailsTitle = 'Detalhes do post-it';
  static const detailsSection = 'Detalhes';
  static const noDetails = 'Sem detalhes adicionais.';
  static const periodLabel = 'Período';
  static const noteExcerptTitle = 'Trecho copiado da nota';
  static const linkedNoteTitle = 'Nota vinculada';
  static const close = 'Fechar';
  static const emptyDay = 'Nenhum post-it neste dia.';
  static const calendarHint =
      'Toque: selecionar · 2/3 toques: tarefa/evento · segure: prévia · '
      'deslize: período/dias';
  static const todayBadge = 'hoje';
  static const continuation = 'continua';

  static const newPostIt = 'Novo post-it';
  static const editPostIt = 'Editar post-it';
  static const fieldTitle = 'Título';
  static const fieldDetails = 'Detalhes (opcional)';
  static const fieldType = 'Tipo';
  static const fieldDate = 'Data';
  static const fieldNoDate = 'Sem data';
  static const fieldStartDate = 'Início';
  static const fieldEndDate = 'Fim';
  static const fieldHighlight = 'Evento marcante (+)';
  static const save = 'Salvar';
  static const cancel = 'Cancelar';
  static const edit = 'Editar';
  static const delete = 'Excluir';
  static const actions = 'Ações';
  static const moveToDate = 'Mover para data…';
  static const changeDuration = 'Alterar duração…';
  static const moveUp = 'Subir na ordem';
  static const moveDown = 'Descer na ordem';
  static const resizeStart = 'Redimensionar início';
  static const resizeEnd = 'Redimensionar fim';
  static const deleting = 'Excluir post-it?';
  static const deleteExplanation =
      'O post-it sairá da agenda, mas o histórico e o registro serão '
      'preservados no banco.';
  static const confirmDelete = 'Excluir';
  static const savedMessage = 'Post-it salvo.';
  static const deletedMessage = 'Post-it excluído.';
  static const restoredMessage = 'Post-it restaurado.';
  static const undo = 'Desfazer';
  static const movedMessage = 'Post-it movido.';
  static const resizedMessage = 'Duração atualizada.';
  static const reorderedMessage = 'Ordem atualizada.';

  static const errorTitleEmpty = 'Informe um título.';
  static const errorTitleLong = 'O título deve ter no máximo 120 caracteres.';
  static const errorEventDate = 'Escolha a data do evento.';
  static const errorEndBeforeStart =
      'A data final não pode ser anterior à inicial.';
  static const errorEndWithoutStart = 'Informe a data inicial antes da final.';
  static const errorIntervalOnTask = 'Apenas eventos podem ocupar vários dias.';
  static const errorHighlightEvent =
      'O símbolo + só pode ser usado em eventos.';
  static const errorSave =
      'Não foi possível salvar. Verifique os dados e tente novamente.';
  static const errorMove = 'Não foi possível mover o post-it.';
  static const errorResize = 'Não foi possível redimensionar o evento.';
  static const errorDelete = 'Não foi possível excluir o post-it.';
  static const errorReorder = 'Não foi possível alterar a ordem.';

  static String moreItems(int count) => '+$count mais';
  static const hiddenEventsTitle = 'Eventos adicionais';
  static const hiddenEventsHelp =
      'Eventos que não couberam nas faixas desta semana.';
  static String hiddenEvents(int count) => '+$count eventos';
}
