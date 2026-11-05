import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_strings.dart';

/// Tela com descrição do projeto, versão instalada e links úteis.
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  static const repositoryUrl = 'https://github.com/MikeMequis1/Stick2Planner';
  static const profileUrl = 'https://github.com/MikeMequis1';

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late final Future<PackageInfo?> _packageInfo = _loadPackageInfo();

  static Future<PackageInfo?> _loadPackageInfo() async {
    try {
      return await PackageInfo.fromPlatform();
    } on Object {
      return null;
    }
  }

  Future<void> _open(String url) async {
    final messenger = ScaffoldMessenger.of(context);
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } on Object {
      opened = false;
    }
    if (!opened && mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text(AppStrings.aboutLinkFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.aboutTitle)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.viewPaddingOf(context).bottom,
        ),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.sticky_note_2_outlined,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.appName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder<PackageInfo?>(
                    future: _packageInfo,
                    builder: (context, snapshot) {
                      final info = snapshot.data;
                      if (info == null) return const SizedBox.shrink();
                      return Text(
                        AppStrings.aboutVersion(info.version),
                        key: const Key('about-version'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(AppStrings.aboutDescription, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  key: const Key('about-repository'),
                  leading: const Icon(Icons.code),
                  title: Text(AppStrings.aboutRepository),
                  subtitle: const Text('github.com/MikeMequis1/Stick2Planner'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _open(AboutPage.repositoryUrl),
                ),
                const Divider(height: 1),
                ListTile(
                  key: const Key('about-profile'),
                  leading: const Icon(Icons.person_outline),
                  title: Text(AppStrings.aboutProfile),
                  subtitle: const Text('github.com/MikeMequis1'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _open(AboutPage.profileUrl),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
