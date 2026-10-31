# Progresso das etapas

## Etapa 0 — Preparação (concluída em 2026-10-31)

### Implementado

- Repositório git inicializado (`main`) com commit do template original e,
  em seguida, commit desta etapa.
- Template do contador removido (`test/widget_test.dart` excluído,
  `lib/main.dart` substituído).
- Dependências adicionadas: `drift 2.35.3`, `sqlite3 3.8.0`,
  `path_provider 2.1.6`, `path 1.9.1`, `intl 0.20.3`, `uuid 4.6.0`,
  `flutter_localizations`; dev: `drift_dev 2.35.2`, `build_runner 2.17.1`.
- Banco drift mínimo (`AppDatabase`, esquema v1) com tabela `app_settings`
  (chave/valor) e conexão em arquivo via `path_provider`.
- Tema Material 3 provisório, locale pt_BR e tela temporária.
- Nome de exibição Android alterado para **Planner**.
- Testes: smoke da tela inicial; gravação/leitura em memória; persistência em
  arquivo entre abertura, fechamento e reabertura do banco.
- Documentação: `README.md`, `docs/DECISOES.md`, este arquivo.

### Comandos executados

```bash
git init -b main && git commit -m "chore: initial Flutter template"
flutter pub add drift sqlite3 path_provider uuid intl path
flutter pub add dev:drift_dev dev:build_runner
flutter pub add flutter_localizations --sdk=flutter
dart run build_runner build
flutter analyze
flutter test
flutter build apk --debug
```

### Resultados

- `flutter analyze`: sem issues.
- `flutter test`: 3 testes, todos aprovados, incluindo SQLite em memória e
  persistência em arquivo (hooks nativos do `sqlite3` funcionando no host
  Windows).
- `flutter build apk --debug`: aprovado. Gerou
  `build/app/outputs/flutter-apk/app-debug.apk`; o Gradle instalou
  automaticamente NDK 28.0.13004108, CMake 3.22.1 e Android SDK Platform 35
  (necessários para compilar o SQLite via hooks). Tempo do `assembleDebug`:
  ~385 s na primeira execução.

### Arquivos alterados

- `pubspec.yaml`, `pubspec.lock`
- `lib/main.dart` (substituído)
- `lib/data/db/app_database.dart`, `lib/data/db/app_database.g.dart` (gerado)
- `test/app_test.dart`, `test/data/db/app_database_test.dart`
- `test/widget_test.dart` (removido)
- `android/app/src/main/AndroidManifest.xml`
- `windows/flutter/generated_plugins.cmake` (regenerado)
- `README.md`, `docs/DECISOES.md`, `docs/PROGRESSO.md`

### Limitações e pendências

- Interface funcional inexistente; apenas tela temporária.
- `applicationId` provisório, aguardando decisão.
- Build Windows não validado: Developer Mode desabilitado (necessário para
  plugins) e Visual Studio sem o workload C++; irrelevante para o alvo Android.
- Sem CI configurada.
- Codegen precisa ser executado após alterações de esquema.

### Próximo passo

Etapa 1 — fundação: `DateOnly`, `Clock`, entidades, esquema completo com
migrações, repositórios e testes de domínio/persistência. Aguardando
aprovação para iniciar.
