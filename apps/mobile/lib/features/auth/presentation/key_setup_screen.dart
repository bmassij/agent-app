import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:cursor_mobile_commander/app/routes.dart';
import 'package:cursor_mobile_commander/features/auth/domain/auth_failure.dart';
import 'package:cursor_mobile_commander/features/auth/presentation/auth_provider.dart';
import 'package:cursor_mobile_commander/features/auth/presentation/widgets/qr_scanner_widget.dart';
import 'package:cursor_mobile_commander/shared/constants/colors.dart';
import 'package:cursor_mobile_commander/shared/constants/sizes.dart';
import 'package:cursor_mobile_commander/shared/widgets/loading_spinner.dart';

/// Paste or scan a Cursor API key; validates via GET /v1/me.
class KeySetupScreen extends ConsumerStatefulWidget {
  const KeySetupScreen({super.key});

  @override
  ConsumerState<KeySetupScreen> createState() => _KeySetupScreenState();
}

class _KeySetupScreenState extends ConsumerState<KeySetupScreen> {
  final _controller = TextEditingController();
  bool _obscure = true;
  bool _showScanner = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok =
        await ref.read(keySetupProvider.notifier).validateAndSave(_controller.text);
    if (!mounted) {
      return;
    }
    if (ok) {
      context.go(Routes.connectGithub);
    }
  }

  void _onQrScanned(BarcodeCapture capture) {
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) {
      return;
    }
    final key = QrScannerWidget.parseApiKeyFromPayload(raw);
    if (key != null) {
      setState(() {
        _showScanner = false;
        _controller.text = key;
      });
    }
  }

  String _failureMessage(AuthFailure failure) {
    return switch (failure) {
      InvalidKeyFailure(:final message) => message,
      NetworkFailure(:final message) => message,
      StorageFailure(:final message) => message,
      BiometricFailure(:final message) => message,
      GithubOAuthFailure(:final message) => message,
    };
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(keySetupProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cursor API Key'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.connectCursor),
        ),
      ),
      body: _showScanner
          ? QrScannerWidget(onDetect: _onQrScanned)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Enter your Cursor API key from Dashboard → API Keys.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  TextField(
                    controller: _controller,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'API key',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _showScanner = true),
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan QR code'),
                  ),
                  const SizedBox(height: AppSizes.paddingLarge),
                  if (setupState.isLoading) const LoadingSpinner(),
                  if (setupState case AsyncData(:final value))
                    value.fold(
                      () => const SizedBox.shrink(),
                      (failure) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSizes.paddingMedium,
                        ),
                        child: Text(
                          _failureMessage(failure),
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ),
                  FilledButton(
                    onPressed: setupState.isLoading ? null : _submit,
                    child: const Text('Validate & continue'),
                  ),
                ],
              ),
            ),
    );
  }
}
