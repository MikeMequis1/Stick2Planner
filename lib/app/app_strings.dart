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

  static const nextStage = 'Próxima etapa';
  static const offlineNotice = 'Funciona offline: dados salvos neste tablet.';

  static const viewModeDay = 'Dia';
  static const viewModeFourDays = '4 dias';
  static const viewModeWeek = 'Semana';
  static const viewModeTwoWeeks = '2 semanas';
  static const viewModeMonth = 'Mês';
}
