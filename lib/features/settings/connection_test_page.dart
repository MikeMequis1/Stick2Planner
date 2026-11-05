import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../../app/services/sync_coordinator.dart';

/// Tela dedicada para editar o endereço do servidor e testar a conexão.
///
/// Testar aqui valida apenas rede/URL (`/v1/health`); não pareia o aparelho.
class ConnectionTestPage extends StatefulWidget {
  const ConnectionTestPage({super.key});

  @override
  State<ConnectionTestPage> createState() => _ConnectionTestPageState();
}

class _ConnectionTestPageState extends State<ConnectionTestPage> {
  final TextEditingController _url = TextEditingController();
  final FocusNode _urlFocus = FocusNode();
  SyncCoordinator? _sync;
  bool _busy = false;
  String? _result;
  bool _resultOk = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sync = AppScope.of(context).sync;
    if (identical(sync, _sync)) return;
    _sync?.removeListener(_syncUrlFromState);
    _sync = sync;
    _sync!.addListener(_syncUrlFromState);
    _url.text = sync.serverUrl ?? '';
  }

  /// Mantém o campo alinhado quando pareamento/desconexão mudam a URL.
  void _syncUrlFromState() {
    if (!mounted || _urlFocus.hasFocus) return;
    final value = _sync?.serverUrl ?? '';
    if (_url.text != value) _url.text = value;
  }

  @override
  void dispose() {
    _sync?.removeListener(_syncUrlFromState);
    _urlFocus.dispose();
    _url.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await AppScope.of(context).sync.setServerUrl(_url.text);
      messenger.showSnackBar(SnackBar(content: Text(AppStrings.syncUrlSaved)));
    } on FormatException {
      messenger.showSnackBar(
        SnackBar(content: Text(AppStrings.syncUrlInvalid)),
      );
    }
  }

  Future<void> _test() async {
    final sync = AppScope.of(context).sync;
    setState(() {
      _busy = true;
      _result = null;
    });
    try {
      final health = await sync.testConnection(_url.text);
      if (!mounted) return;
      setState(() {
        _resultOk = true;
        _result = AppStrings.syncTestOk(health.serverId);
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _resultOk = false;
        _result = AppStrings.syncTestFailed;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.syncConnection)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.viewPaddingOf(context).bottom,
        ),
        children: [
          TextField(
            key: const Key('sync-connection-url'),
            controller: _url,
            focusNode: _urlFocus,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: AppStrings.syncServerUrl,
              hintText: AppStrings.syncServerUrlHint,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (_) {
              if (_result != null) setState(() => _result = null);
            },
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                key: const Key('sync-connection-save'),
                onPressed: _busy ? null : _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(AppStrings.syncSaveUrl),
              ),
              OutlinedButton.icon(
                key: const Key('sync-connection-test'),
                onPressed: _busy ? null : _test,
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_tethering),
                label: Text(AppStrings.syncTest),
              ),
            ],
          ),
          if (_result != null) ...[
            const SizedBox(height: 12),
            Text(
              _result!,
              key: const Key('sync-connection-result'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: _resultOk
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
