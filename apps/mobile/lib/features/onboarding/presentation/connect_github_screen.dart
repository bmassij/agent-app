import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cursor_mobile_commander/app/routes.dart';
import 'package:cursor_mobile_commander/features/auth/data/github_auth_service.dart';
import 'package:cursor_mobile_commander/features/auth/domain/auth_failure.dart';
import 'package:cursor_mobile_commander/features/onboarding/presentation/onboarding_provider.dart';
import 'package:cursor_mobile_commander/shared/constants/github_config.dart';
import 'package:cursor_mobile_commander/shared/constants/sizes.dart';
import 'package:cursor_mobile_commander/shared/widgets/loading_spinner.dart';

/// GitHub OAuth PKCE connection step.
class ConnectGithubScreen extends ConsumerStatefulWidget {
  const ConnectGithubScreen({super.key});

  @override
  ConsumerState<ConnectGithubScreen> createState() =>
      _ConnectGithubScreenState();
}

class _ConnectGithubScreenState extends ConsumerState<ConnectGithubScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _connect() async {
    if (!GithubConfig.isConfigured) {
      setState(() {
        _error =
            'Set GITHUB_CLIENT_ID via --dart-define when building the app.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(githubAuthServiceProvider).startOAuthFlow();
    } on GithubOAuthFailure catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final githubAsync = ref.watch(githubConnectedProvider);

    ref.listen(githubConnectedProvider, (prev, next) {
      next.whenData((connected) {
        if (connected && mounted) {
          context.go(Routes.pinRepo);
        }
      });
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Connect GitHub')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Connect GitHub so agents can access your repositories. '
              'Uses OAuth with PKCE — no backend required.',
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            githubAsync.when(
              data: (connected) => connected
                  ? const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('GitHub connected'),
                      ],
                    )
                  : const SizedBox.shrink(),
              loading: () => const LoadingSpinner(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSizes.paddingMedium),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const Spacer(),
            if (_loading) const LoadingSpinner(),
            if (!_loading)
              FilledButton(
                onPressed: _connect,
                child: const Text('Connect GitHub'),
              ),
            TextButton(
              onPressed: () => context.go(Routes.pinRepo),
              child: const Text('Skip for now'),
            ),
          ],
        ),
      ),
    );
  }
}
