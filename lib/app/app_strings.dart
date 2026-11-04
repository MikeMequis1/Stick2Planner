import 'package:flutter/widgets.dart';

/// Idiomas disponíveis no aplicativo.
enum AppLanguage {
  ptBr,
  en;

  Locale get locale =>
      this == AppLanguage.en ? const Locale('en') : const Locale('pt', 'BR');

  String get dateLocale => this == AppLanguage.en ? 'en' : 'pt_BR';

  String get label => this == AppLanguage.en ? 'English' : 'Português (BR)';
}

/// Textos da interface, com tradução em tempo de execução.
abstract final class AppStrings {
  static AppLanguage _language = AppLanguage.ptBr;

  static AppLanguage get language => _language;

  static void setLanguage(AppLanguage language) {
    _language = language;
  }

  static String _t(String pt, String en) =>
      _language == AppLanguage.en ? en : pt;

  static const appName = 'Stick2Planner';

  static String get agenda => _t('Agenda', 'Agenda');
  static String get inbox => _t('Caixinha', 'Inbox');
  static String get notes => _t('Notas', 'Notes');

  static String get agendaPlaceholderTitle =>
      _t('Agenda visual em construção', 'Visual calendar under construction');
  static String get agendaPlaceholderBody => _t(
    'A grade de dias, os post-its e os gestos de arrastar entram na próxima etapa. A data e as preferências já são persistidas.',
    'The day grid, post-its and drag gestures arrive in the next stage. The date and preferences are already persisted.',
  );

  static String get inboxPlaceholderTitle =>
      _t('Caixinha em construção', 'Inbox under construction');
  static String get inboxPlaceholderBody => _t(
    'Filtros por estado, busca e tarefas sem data chegam na Etapa 4.',
    'Status filters, search and undated tasks arrive in Stage 4.',
  );

  static String get notesEmptyMessage => _t(
    'Crie uma nota livre ou uma lista; depois selecione linhas para gerar post-its.',
    'Create a free note or a list, then select lines to create post-its.',
  );

  static String get today => _t('Hoje', 'Today');
  static String get selectedDay => _t('selecionado', 'selected');
  static String get selectedDate => _t('Data selecionada', 'Selected date');
  static String get postItsOnDay =>
      _t('Post-its no dia', 'Post-its on the day');
  static String get undated => _t('Sem data', 'Undated');
  static String get active => _t('Ativas', 'Active');
  static String get done => _t('Concluídas', 'Done');
  static String get cancelled => _t('Canceladas', 'Cancelled');
  static String get notesCount => _t('Notas', 'Notes');

  static String get newNote => _t('Nova nota', 'New note');
  static String get editNote => _t('Editar nota', 'Edit note');
  static String get noteTitle => _t('Título da nota', 'Note title');
  static String get noteTypeText => _t('Texto', 'Text');
  static String get noteTypeMarkdown =>
      _t('Texto · Markdown', 'Text · Markdown');
  static String get noteTypeChecklist => _t('Lista', 'List');
  static String get markdownLabel => _t('Markdown', 'Markdown');
  static String get markdownFieldHint => _t(
    '# Título\n\nEscreva livremente. Use **negrito**, *itálico*, listas, links e blocos de código.',
    '# Title\n\nWrite freely. Use **bold**, *italic*, lists, links and code blocks.',
  );
  static String get markdownHint => _t(
    'Markdown: # título, **negrito**, *itálico*, - item, 1. item, [link](url), `código`.',
    'Markdown: # heading, **bold**, *italic*, - item, 1. item, [link](url), `code`.',
  );
  static String get markdownToolsHeading1 => _t('Título 1', 'Heading 1');
  static String get markdownToolsHeading2 => _t('Título 2', 'Heading 2');
  static String get markdownToolsHeading3 => _t('Título 3', 'Heading 3');
  static String get markdownToolsBold => _t('Negrito', 'Bold');
  static String get markdownToolsItalic => _t('Itálico', 'Italic');
  static String get markdownToolsBulletList =>
      _t('Lista com marcadores', 'Bullet list');
  static String get markdownToolsNumberedList =>
      _t('Lista numerada', 'Numbered list');
  static String get markdownToolsLink => _t('Link', 'Link');
  static String get markdownToolsInlineCode =>
      _t('Código inline', 'Inline code');
  static String get markdownToolsCodeBlock =>
      _t('Bloco de código', 'Code block');
  static String get markdownToolsQuote => _t('Citação', 'Quote');
  static String get markdownToolsShowPreview =>
      _t('Mostrar prévia', 'Show preview');
  static String get markdownToolsHidePreview =>
      _t('Ocultar prévia', 'Hide preview');
  static String get markdownPreviewTitle => _t('Prévia', 'Preview');
  static String get markdownPreviewEmpty =>
      _t('Nada para pré-visualizar.', 'Nothing to preview.');
  static String get markdownLinkPlaceholder => _t('texto', 'text');
  static String get createPostItFromMarkdown =>
      _t('Criar post-it de trecho…', 'Create post-it from excerpt…');
  static String get snapshotSelectionHint => _t(
    'Selecione um trecho abaixo. Sem seleção, será usada a nota inteira.',
    'Select an excerpt below. Without a selection, the whole note is used.',
  );
  static String get selectWholeNote => _t('Nota inteira', 'Whole note');
  static String get noMarkdown =>
      _t('Nota sem conteúdo.', 'Note has no content.');
  static String get addLine => _t('Adicionar linha', 'Add line');
  static String get lineHint => _t('Escreva uma linha', 'Write a line');
  static String get noteTitleRequired =>
      _t('Informe um título para a nota.', 'Enter a note title.');
  static String get noteSaveError =>
      _t('Não foi possível salvar a nota.', 'Could not save the note.');
  static String get noteDeleteError =>
      _t('Não foi possível excluir a nota.', 'Could not delete the note.');
  static String get selectLinesHint => _t(
    'Mantenha pressionada uma linha para selecionar um trecho.',
    'Press and hold a line to select an excerpt.',
  );
  static String get createPostItFromSelection =>
      _t('Criar post-it do trecho', 'Create post-it from excerpt');
  static String get clearSelection => _t('Limpar seleção', 'Clear selection');
  static String get noteLinkedPostIts =>
      _t('Post-its vinculados', 'Linked post-its');
  static String get createTaskFromNote =>
      _t('Criar tarefa com esta nota', 'Create task with this note');
  static String get linkToPostIt =>
      _t('Vincular a post-it…', 'Link to post-it…');
  static String get linkNote => _t('Vincular nota…', 'Link note…');
  static String get unlinkNote => _t('Desvincular nota', 'Unlink note');
  static String get openNote => _t('Abrir nota', 'Open note');
  static String get openInAgenda => _t('Abrir na Agenda', 'Open in Calendar');
  static String get postItNotFound =>
      _t('Post-it não encontrado.', 'Post-it not found.');
  static String get postItWithoutDate =>
      _t('Este post-it não tem data definida.', 'This post-it has no date.');
  static String get showPostItDetails => _t('Ver detalhes', 'View details');
  static String get noteSnapshots =>
      _t('Trechos desta nota', 'Excerpts from this note');
  static String get selectNote => _t('Selecionar nota', 'Select note');
  static String get selectPostIt => _t('Selecionar post-it', 'Select post-it');
  static String get noteDeleted => _t('Nota excluída.', 'Note deleted.');
  static String get deleteNote => _t('Excluir nota', 'Delete note');
  static String get deleteNoteQuestion => _t('Excluir nota?', 'Delete note?');
  static String get deleteNoteExplanation => _t(
    'A nota sairá do caderno, mas o registro será preservado no banco.',
    'The note leaves the notebook, but the record is preserved in the database.',
  );
  static String get deleteNoteLinkedWarning => _t(
    'Esta nota está vinculada a post-its. Os vínculos serão removidos; trechos já copiados são preservados.',
    'This note is linked to post-its. Links will be removed; copied excerpts are preserved.',
  );
  static String get noteSnapshotHint => _t(
    'Snapshot: editar a nota não altera este texto.',
    'Snapshot: editing the note does not change this text.',
  );
  static String get noteLiveLink => _t(
    'Nota vinculada: o conteúdo acompanha as edições da nota.',
    'Linked note: content follows note edits.',
  );
  static String get linkedNoteChip => _t('Nota vinculada', 'Linked note');
  static String get noteExcerptChip => _t('Trecho copiado', 'Copied excerpt');
  static String get noNotes => _t('Nenhuma nota ainda.', 'No notes yet.');
  static String get noLines => _t('Nenhuma linha.', 'No lines.');
  static String get selectPostItEmpty =>
      _t('Nenhum post-it disponível.', 'No post-it available.');
  static String get linkNoteError =>
      _t('Não foi possível vincular a nota.', 'Could not link the note.');
  static String get createPostItError =>
      _t('Não foi possível criar o post-it.', 'Could not create the post-it.');
  static String get noteLines => _t('linhas', 'lines');

  static String noteCount(int count) => _language == AppLanguage.en
      ? '$count ${count == 1 ? 'note' : 'notes'}'
      : '$count ${count == 1 ? 'nota' : 'notas'}';

  static String linkedPostItsCount(int count) => _language == AppLanguage.en
      ? '$count ${count == 1 ? 'post-it' : 'post-its'}'
      : '$count ${count == 1 ? 'post-it' : 'post-its'}';

  static String selectedLines(int count) =>
      _language == AppLanguage.en ? '$count selected' : '$count selecionada(s)';

  static String get loading =>
      _t('Carregando dados locais…', 'Loading local data…');
  static String get loadError => _t(
    'Não foi possível carregar os dados locais.',
    'Could not load local data.',
  );
  static String get emptyInbox =>
      _t('Nada na caixinha ainda.', 'Inbox is empty.');
  static String get emptyNotes =>
      _t('Nenhuma nota criada ainda.', 'No notes created yet.');
  static String get allFilter => _t('Todas', 'All');
  static String get itemsCount => _t('itens', 'items');
  static String get searchHint =>
      _t('Buscar por título, detalhe ou nota', 'Search title, details or note');
  static String get sortBy => _t('Ordenar', 'Sort');
  static String get sortDate => _t('Data', 'Date');
  static String get sortUpdated => _t('Atualização', 'Updated');
  static String get sortTitle => _t('Título', 'Title');
  static String get noResults =>
      _t('Nenhum post-it encontrado.', 'No post-it found.');
  static String get editInInbox => _t('Editar', 'Edit');
  static String get statusMenu => _t('Ações de estado', 'Status actions');

  static String get nextStage => _t('Próxima etapa', 'Next stage');
  static String get offlineNotice => _t(
    'Funciona offline: dados salvos neste tablet.',
    'Works offline: data saved on this tablet.',
  );

  static String get settings => _t('Configurações', 'Settings');
  static String get settingsAppearance => _t('Aparência', 'Appearance');
  static String get settingsTheme => _t('Tema', 'Theme');
  static String get settingsThemeSystem => _t('Sistema', 'System');
  static String get settingsThemeLight => _t('Claro', 'Light');
  static String get settingsThemeDark => _t('Escuro', 'Dark');
  static String get settingsPalette => _t('Paleta de cores', 'Color palette');
  static String get paletteEmerald => _t('Verde', 'Emerald');
  static String get paletteOcean => _t('Oceano', 'Ocean');
  static String get paletteSunset => _t('Pôr do sol', 'Sunset');
  static String get paletteLavender => _t('Lavanda', 'Lavender');
  static String get settingsPaletteHelp => _t(
    'Gradiente de fundo e cor de destaque do aplicativo.',
    'App background gradient and accent color.',
  );
  static String get settingsAnimations => _t('Animações', 'Animations');
  static String get settingsAnimationsHelp => _t(
    'Ativa transições, folhear de páginas e efeitos de toque.',
    'Enables transitions, page turning and touch effects.',
  );
  static String get settingsKeepAwake =>
      _t('Manter tela ligada', 'Keep screen awake');
  static String get settingsKeepAwakeHelp => _t(
    'Evita que a tela desligue enquanto o planner estiver aberto.',
    'Prevents the screen from sleeping while the planner is open.',
  );
  static String get settingsHints => _t('Dicas da agenda', 'Calendar hints');
  static String get settingsHintsHelp => _t(
    'Mostra a dica de gestos e a contagem de post-its sem data.',
    'Shows gesture hints and the undated post-it count.',
  );
  static String get settingsSync => _t('Sincronização', 'Sync');
  static String get settingsSyncHelp => _t(
    'Envie e receba alterações de um servidor próprio. O app continua funcionando offline.',
    'Send and receive changes from your own server. The app keeps working offline.',
  );
  static String get syncServerUrl =>
      _t('Endereço do servidor', 'Server address');
  static String get syncServerUrlHint =>
      _t('http://192.168.0.10:8090', 'http://192.168.0.10:8090');
  static String get syncSaveUrl => _t('Salvar endereço', 'Save address');
  static String get syncUrlSaved => _t('Endereço salvo.', 'Address saved.');
  static String get syncUrlInvalid => _t(
    'Endereço inválido. Use http:// ou https://.',
    'Invalid address. Use http:// or https://.',
  );
  static String get syncTest => _t('Testar conexão', 'Test connection');
  static String syncTestOk(String serverId) => _language == AppLanguage.en
      ? 'Server reachable ($serverId).'
      : 'Servidor acessível ($serverId).';
  static String get syncTestFailed => _t(
    'Não foi possível alcançar o servidor.',
    'Could not reach the server.',
  );
  static String get syncEnabled =>
      _t('Sincronizar automaticamente', 'Sync automatically');
  static String get syncEnabledHelp => _t(
    'Tenta sincronizar ao abrir, ao alterar dados, ao reconectar e periodicamente.',
    'Tries to sync on open, on data changes, on reconnect and periodically.',
  );
  static String get syncNow => _t('Sincronizar agora', 'Sync now');
  static String get syncRunning => _t('Sincronizando…', 'Syncing…');
  static String syncDone(int pushed, int pulled, int copies) =>
      _language == AppLanguage.en
      ? 'Sync done: $pushed sent, $pulled received, $copies conflict copies.'
      : 'Sync concluído: $pushed enviados, $pulled recebidos, $copies cópias de conflito.';
  static String syncPending(int count) =>
      _language == AppLanguage.en ? '$count pending' : '$count pendentes';
  static String syncLastSync(String date) =>
      _language == AppLanguage.en ? 'Last sync: $date' : 'Último sync: $date';
  static String get syncNever => _t('Nunca sincronizado.', 'Never synced.');
  static String get syncNotConfigured => _t(
    'Configure o endereço e pareie o dispositivo.',
    'Set the address and pair this device.',
  );
  static String get syncError => _t(
    'Falha na sincronização. Verifique servidor e rede.',
    'Sync failed. Check server and network.',
  );
  static String get syncPair => _t('Parear dispositivo', 'Pair device');
  static String get syncPairTitle => _t('Pareamento', 'Pairing');
  static String get syncPairHelp => _t(
    'Cole o JSON/código gerado no servidor ou escaneie o QR.',
    'Paste the JSON/code from the server or scan the QR.',
  );
  static String get syncPairCodeHint =>
      _t('Código de pareamento', 'Pairing code');
  static String get syncPairSuccess =>
      _t('Dispositivo pareado.', 'Device paired.');
  static String get syncPairFailed =>
      _t('Pareamento recusado ou expirado.', 'Pairing refused or expired.');
  static String get syncScanQr => _t('Escanear QR', 'Scan QR');
  static String get syncScanHint =>
      _t('Aponte para o QR de pareamento', 'Point at the pairing QR');
  static String get syncScannerError => _t(
    'Câmera indisponível. Use o código manual.',
    'Camera unavailable. Use the manual code.',
  );
  static String get syncDisconnect => _t('Desconectar', 'Disconnect');
  static String get syncDisconnectConfirm => _t(
    'Remover servidor e token deste dispositivo?',
    'Remove server and token from this device?',
  );
  static String get syncDisconnected =>
      _t('Servidor desconectado.', 'Server disconnected.');
  static String get syncNotConfiguredShort =>
      _t('Não configurado', 'Not configured');
  static String get syncErrorDetail => _t('Detalhes', 'Details');

  static String get settingsAbout => _t('Sobre', 'About');
  static String get settingsLocalData => _t(
    'Dados salvos localmente neste tablet, sem sincronização nesta versão.',
    'Data saved locally on this tablet, without synchronization in this version.',
  );
  static String get settingsLanguage => _t('Idioma', 'Language');
  static String get settingsLanguageHelp =>
      _t('Idioma da interface e das datas.', 'Interface and date language.');
  static String get settingsBackup =>
      _t('Backup e restauração', 'Backup and restore');
  static String get settingsBackupHelp => _t(
    'Exporte todos os dados em um arquivo JSON ou restaure um backup. A importação substitui os dados atuais.',
    'Export all data to a JSON file or restore a backup. Importing replaces current data.',
  );
  static String get backupExport => _t('Exportar backup', 'Export backup');
  static String get backupImport => _t('Importar backup', 'Import backup');
  static String backupExportSuccess(String path) => _language == AppLanguage.en
      ? 'Backup exported: $path'
      : 'Backup exportado: $path';
  static String get backupExportCanceled =>
      _t('Exportação cancelada.', 'Export cancelled.');
  static String get backupImportCanceled =>
      _t('Importação cancelada.', 'Import cancelled.');
  static String get backupImportConfirmTitle =>
      _t('Substituir todos os dados?', 'Replace all data?');
  static String backupImportCounts(int postIts, int notes) =>
      _language == AppLanguage.en
      ? '$postIts post-its and $notes notes will be restored.'
      : '$postIts post-its e $notes notas serão restaurados.';
  static String backupImportDate(String date) =>
      _language == AppLanguage.en ? 'Backup from $date.' : 'Backup de $date.';
  static String get backupImportWarning => _t(
    'Os dados atuais serão substituídos. Um snapshot automático será criado antes da importação.',
    'Current data will be replaced. An automatic snapshot is created before importing.',
  );
  static String backupImported(int postIts, int notes) =>
      _language == AppLanguage.en
      ? 'Backup restored: $postIts post-its and $notes notes.'
      : 'Backup restaurado: $postIts post-its e $notes notas.';
  static String backupSnapshotCreated(String path) =>
      _language == AppLanguage.en ? 'Snapshot: $path' : 'Snapshot: $path';
  static String get backupErrorInvalid =>
      _t('Arquivo de backup inválido.', 'Invalid backup file.');
  static String get backupErrorChecksum => _t(
    'O conteúdo do arquivo não confere com o checksum.',
    'File contents do not match the checksum.',
  );
  static String get backupErrorVersion => _t(
    'Versão de backup incompatível com este aplicativo.',
    'Backup version is not supported by this app.',
  );
  static String get backupErrorSchema => _t(
    'O backup usa um esquema de dados incompatível.',
    'The backup uses an unsupported data schema.',
  );
  static String get backupErrorGeneric => _t(
    'Não foi possível concluir a operação de backup.',
    'Could not complete the backup operation.',
  );
  static String get backupSnapshots =>
      _t('Snapshots automáticos', 'Automatic snapshots');
  static String get backupSnapshotsEmpty =>
      _t('Nenhum snapshot ainda.', 'No snapshots yet.');
  static String get backupRestoreSnapshot =>
      _t('Restaurar snapshot', 'Restore snapshot');
  static String get backupRestoreConfirmTitle =>
      _t('Restaurar este snapshot?', 'Restore this snapshot?');
  static String backupRestoreConfirmBody(String date) =>
      _language == AppLanguage.en
      ? 'Current data will be replaced by the snapshot from $date. A new snapshot is created first.'
      : 'Os dados atuais serão substituídos pelo snapshot de $date. Um novo snapshot será criado antes.';
  static String get confirm => _t('Confirmar', 'Confirm');

  static String get viewModeDay => _t('Dia', 'Day');
  static String get viewModeFourDays => _t('4 dias', '4 days');
  static String get viewModeWeek => _t('Semana', 'Week');
  static String get viewModeTwoWeeks => _t('2 semanas', '2 weeks');
  static String get viewModeMonth => _t('Mês', 'Month');
  static String get recurringShort => _t('Recorrente', 'Recurring');
  static String get recurringHelp => _t(
    'Aparece hoje e avança sozinho para o próximo dia enquanto estiver pendente, até ser concluído ou cancelado.',
    'Appears today and advances to the next day while pending, until completed or cancelled.',
  );
  static String get postponed => _t('Adiado', 'Postponed');
  static String get advancesDaily => _t('Avança diariamente', 'Advances daily');
  static String get postponedUntil => _t('Adiado até', 'Postponed until');
  static String get recurringPostponedHelp => _t(
    'Enquanto adiado, não avança. Depois da data, volta a ser carregado para o dia atual se continuar pendente.',
    'While postponed, it does not advance. After that date, it returns to today if still pending.',
  );
  static String get statusDoneAction => _t('Concluir', 'Complete');
  static String get statusCancelAction => _t('Cancelar tarefa', 'Cancel task');
  static String get statusReopenAction => _t('Reabrir', 'Reopen');
  static String get statusUpdatedMessage =>
      _t('Estado atualizado.', 'Status updated.');

  static String get previousPeriod => _t('Período anterior', 'Previous period');
  static String get nextPeriod => _t('Próximo período', 'Next period');
  static String get decreaseDays => _t('Menos dias', 'Fewer days');
  static String get increaseDays => _t('Mais dias', 'More days');

  static String get taskType => _t('Tarefa', 'Task');
  static String get eventType => _t('Evento', 'Event');
  static String get recurringType => _t('TO-DO recorrente', 'Recurring TO-DO');
  static String get highlightType => _t('Evento marcante', 'Highlighted event');
  static String get eventSymbol => '✮';
  static String get highlightSymbol => '+';

  static String get detailsTitle =>
      _t('Detalhes do post-it', 'Post-it details');
  static String get detailsSection => _t('Detalhes', 'Details');
  static String get noDetails =>
      _t('Sem detalhes adicionais.', 'No additional details.');
  static String get periodLabel => _t('Período', 'Period');
  static String get noteExcerptTitle =>
      _t('Trecho copiado da nota', 'Excerpt copied from note');
  static String get linkedNoteTitle => _t('Nota vinculada', 'Linked note');
  static String get close => _t('Fechar', 'Close');
  static String get emptyDay =>
      _t('Nenhum post-it neste dia.', 'No post-its on this day.');
  static String get calendarHint => _t(
    'Toque: selecionar · 2/3 toques: tarefa/evento · segure: prévia · deslize: período/dias',
    'Tap: select · 2/3 taps: task/event · hold: preview · swipe: period/days',
  );
  static String get todayBadge => _t('hoje', 'today');
  static String get continuation => _t('continua', 'continues');

  static String get newPostIt => _t('Novo post-it', 'New post-it');
  static String get editPostIt => _t('Editar post-it', 'Edit post-it');
  static String get fieldTitle => _t('Título', 'Title');
  static String get fieldDetails =>
      _t('Detalhes (opcional)', 'Details (optional)');
  static String get fieldType => _t('Tipo', 'Type');
  static String get fieldDate => _t('Data', 'Date');
  static String get fieldNoDate => _t('Sem data', 'Undated');
  static String get fieldStartDate => _t('Início', 'Start');
  static String get fieldEndDate => _t('Fim', 'End');
  static String get fieldHighlight =>
      _t('Evento marcante (+)', 'Highlighted event (+)');
  static String get save => _t('Salvar', 'Save');
  static String get cancel => _t('Cancelar', 'Cancel');
  static String get edit => _t('Editar', 'Edit');
  static String get delete => _t('Excluir', 'Delete');
  static String get actions => _t('Ações', 'Actions');
  static String get moveToDate => _t('Mover para data…', 'Move to date…');
  static String get changeDuration =>
      _t('Alterar duração…', 'Change duration…');
  static String get moveUp => _t('Subir na ordem', 'Move up');
  static String get moveDown => _t('Descer na ordem', 'Move down');
  static String get resizeStart => _t('Redimensionar início', 'Resize start');
  static String get resizeEnd => _t('Redimensionar fim', 'Resize end');
  static String get deleting => _t('Excluir post-it?', 'Delete post-it?');
  static String get deleteExplanation => _t(
    'O post-it sairá da agenda, mas o histórico e o registro serão preservados no banco.',
    'The post-it leaves the calendar, but history and the record are preserved in the database.',
  );
  static String get confirmDelete => _t('Excluir', 'Delete');
  static String get savedMessage => _t('Post-it salvo.', 'Post-it saved.');
  static String get deletedMessage =>
      _t('Post-it excluído.', 'Post-it deleted.');
  static String get restoredMessage =>
      _t('Post-it restaurado.', 'Post-it restored.');
  static String get undo => _t('Desfazer', 'Undo');
  static String get movedMessage => _t('Post-it movido.', 'Post-it moved.');
  static String get resizedMessage =>
      _t('Duração atualizada.', 'Duration updated.');
  static String get reorderedMessage =>
      _t('Ordem atualizada.', 'Order updated.');

  static String get errorTitleEmpty =>
      _t('Informe um título.', 'Enter a title.');
  static String get errorTitleLong => _t(
    'O título deve ter no máximo 120 caracteres.',
    'The title must be at most 120 characters.',
  );
  static String get errorEventDate =>
      _t('Escolha a data do evento.', 'Choose the event date.');
  static String get errorEndBeforeStart => _t(
    'A data final não pode ser anterior à inicial.',
    'The end date cannot be before the start date.',
  );
  static String get errorEndWithoutStart => _t(
    'Informe a data inicial antes da final.',
    'Enter the start date before the end date.',
  );
  static String get errorIntervalOnTask => _t(
    'Apenas eventos podem ocupar vários dias.',
    'Only events can span multiple days.',
  );
  static String get errorHighlightEvent => _t(
    'O símbolo + só pode ser usado em eventos.',
    'The + symbol can only be used on events.',
  );
  static String get errorSave => _t(
    'Não foi possível salvar. Verifique os dados e tente novamente.',
    'Could not save. Check the data and try again.',
  );
  static String get errorMove =>
      _t('Não foi possível mover o post-it.', 'Could not move the post-it.');
  static String get errorResize => _t(
    'Não foi possível redimensionar o evento.',
    'Could not resize the event.',
  );
  static String get errorDelete => _t(
    'Não foi possível excluir o post-it.',
    'Could not delete the post-it.',
  );
  static String get errorReorder =>
      _t('Não foi possível alterar a ordem.', 'Could not change the order.');

  static String moreItems(int count) =>
      _language == AppLanguage.en ? '+$count more' : '+$count mais';
  static String get hiddenEventsTitle =>
      _t('Eventos adicionais', 'Additional events');
  static String get hiddenEventsHelp => _t(
    'Eventos que não couberam nas faixas desta semana.',
    'Events that did not fit in this week\'s lanes.',
  );
  static String hiddenEvents(int count) =>
      _language == AppLanguage.en ? '+$count events' : '+$count eventos';
}
