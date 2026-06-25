import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cursor_mobile_commander/features/settings/domain/app_update_info.dart';
import 'package:cursor_mobile_commander/features/settings/presentation/settings_provider.dart';
import 'package:cursor_mobile_commander/shared/constants/colors.dart';
import 'package:cursor_mobile_commander/shared/constants/sizes.dart';

/// App settings — version info and LAN OTA updates from your PC.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _serverController = TextEditingController();
  bool _serverDirty = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final url = await ref.read(updateServerUrlProvider.future);
      if (!mounted || _serverDirty) {
        return;
      }
      if (url != null) {
        _serverController.text = url;
      }
    });
  }

  @override
  void dispose() {
    _serverController.dispose();
    super.dispose();
  }

  Future<void> _saveServerUrl() async {
    await ref
        .read(updateServerUrlProvider.notifier)
        .save(_serverController.text);
    if (!mounted) {
      return;
    }
    setState(() => _serverDirty = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Update server saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final packageInfo = ref.watch(packageInfoProvider);
    final updateState = ref.watch(appUpdateControllerProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      children: [
        Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSizes.paddingLarge),
        packageInfo.when(
          data: (info) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('App version'),
            subtitle: Text('${info.version} (build ${info.buildNumber})'),
          ),
          loading: () => const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('App version'),
            subtitle: Text('Loading…'),
          ),
          error: (_, __) => const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('App version'),
            subtitle: Text('Unknown'),
          ),
        ),
        const Divider(height: 32),
        Text(
          'Updates from your PC',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        Text(
          'Run the update server on your PC (same Wi‑Fi). Then check for updates here — no Google Drive needed.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        TextField(
          controller: _serverController,
          decoration: const InputDecoration(
            labelText: 'Update server URL',
            hintText: 'http://192.168.1.10:8765',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
          onChanged: (_) => setState(() => _serverDirty = true),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _serverDirty ? _saveServerUrl : null,
            child: const Text('Save server URL'),
          ),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        FilledButton.icon(
          onPressed: updateState.isBusy
              ? null
              : () => ref
                  .read(appUpdateControllerProvider.notifier)
                  .checkForUpdate(),
          icon: const Icon(Icons.system_update),
          label: const Text('Check for updates'),
        ),
        if (updateState.availableUpdate != null) ...[
          const SizedBox(height: AppSizes.paddingMedium),
          _UpdateCard(
            update: updateState.availableUpdate!,
            onInstall: updateState.isBusy
                ? null
                : () => ref
                    .read(appUpdateControllerProvider.notifier)
                    .installAvailableUpdate(),
          ),
        ],
        if (updateState.progress != null) ...[
          const SizedBox(height: AppSizes.paddingMedium),
          if (updateState.progress!.value != null)
            LinearProgressIndicator(
              value: updateState.progress!.value! / 100,
            )
          else
            const LinearProgressIndicator(),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(updateState.progress!.message ?? ''),
        ],
        if (updateState.infoMessage != null) ...[
          const SizedBox(height: AppSizes.paddingMedium),
          Text(
            updateState.infoMessage!,
            style: const TextStyle(color: AppColors.accent),
          ),
        ],
        if (updateState.errorMessage != null) ...[
          const SizedBox(height: AppSizes.paddingMedium),
          Text(
            updateState.errorMessage!,
            style: const TextStyle(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}

class _UpdateCard extends StatelessWidget {
  const _UpdateCard({
    required this.update,
    required this.onInstall,
  });

  final AppUpdateInfo update;
  final VoidCallback? onInstall;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Version ${update.versionName} (build ${update.versionCode})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (update.releaseNotes != null &&
                update.releaseNotes!.isNotEmpty) ...[
              const SizedBox(height: AppSizes.paddingSmall),
              Text(update.releaseNotes!),
            ],
            const SizedBox(height: AppSizes.paddingMedium),
            FilledButton(
              onPressed: onInstall,
              child: const Text('Download & install'),
            ),
          ],
        ),
      ),
    );
  }
}
