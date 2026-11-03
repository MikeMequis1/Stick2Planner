/// Textos da interface em pt_BR, centralizados para permitir i18n futura.
abstract final class AppStrings {
  static const appName = 'Planner';

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

  static const notesPlaceholderTitle = 'Notas privadas em construção';
  static const notesPlaceholderBody =
      'O caderno, as listas e a criação de post-its a partir de uma linha '
      'chegam na Etapa 5.';

  static const today = 'Hoje';
  static const selectedDate = 'Data selecionada';
  static const postItsOnDay = 'Post-its no dia';
  static const undated = 'Sem data';
  static const active = 'Ativas';
  static const done = 'Concluídas';
  static const cancelled = 'Canceladas';
  static const notesCount = 'Notas';

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
      'Toque em um dia para selecionar; toque em um post-it para ver os '
      'detalhes.';
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
  static const movedMessage = 'Post-it movido.';
  static const resizedMessage = 'Duração atualizada.';
  static const reorderedMessage = 'Ordem atualizada.';

  static const errorTitleEmpty = 'Informe um título.';
  static const errorTitleLong = 'O título deve ter no máximo 120 caracteres.';
  static const errorEventDate = 'Escolha a data do evento.';
  static const errorEndBeforeStart =
      'A data final não pode ser anterior à inicial.';
  static const errorEndWithoutStart =
      'Informe a data inicial antes da final.';
  static const errorIntervalOnTask =
      'Apenas eventos podem ocupar vários dias.';
  static const errorHighlightEvent =
      'O símbolo + só pode ser usado em eventos.';
  static const errorSave =
      'Não foi possível salvar. Verifique os dados e tente novamente.';
  static const errorMove = 'Não foi possível mover o post-it.';
  static const errorResize = 'Não foi possível redimensionar o evento.';
  static const errorDelete = 'Não foi possível excluir o post-it.';
  static const errorReorder = 'Não foi possível alterar a ordem.';

  static String moreItems(int count) => '+$count mais';
  static String hiddenEvents(int count) => '+$count eventos';
}
