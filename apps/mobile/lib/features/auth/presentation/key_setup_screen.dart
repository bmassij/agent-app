import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:cursor_mobile_commander/app/routes.dart';
import 'package:cursor_mobile_commander/features/auth/domain/auth_failure.dart';
import 'package:cursor_mobile_commander/features/auth/presentation/auth_provider.dart';
import 'package:cursor_mobile_commander/features/onboarding/presentation/onboarding_provider.dart';
import 'package:cursor_mobile_commander/features/auth/presentation/widgets/qr_scanner_widget.dart';
import 'package:cursor_mobile_commander/shared/constants/colors.dart';
import 'package:cursor_mobile_commander/shared/constants/sizes.dart';
import 'package:cursor_mobile_commander/shared/widgets/loading_spinner.dart';

/// Paste or scan a Cursor API key; validates via GET /v1/me.
class KeySetupScreen extends ConsumerStatefulWidget {
  const KeySetupScreen({
    this.startWithScanner = false,
    super.key,
  });

  final bool startWithScanner;

  @override
  ConsumerState<KeySetupScreen> createState() => _KeySetupScreenState();
}

class _KeySetupScreenState extends ConsumerState<KeySetupScreen> {
  final _controller = TextEditingController();
  late final MobileScannerController _scannerController;
  bool _obscure = true;
  late bool _showScanner;
  bool _scanHandled = false;

  @override
  void initState() {
    super.initState();
    _showScanner = widget.startWithScanner;
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Navigate away before refreshing auth so GoRouter does not remount this
  /// screen mid-save (which cleared the form and reopened the scanner).
  Future<void> _advanceAfterKeySaved() async {
    if (!mounted) {
      return;
    }
    ref.read(authSessionProvider.notifier).markAuthenticated();
    await ref.read(onboardingCompletedProvider.notifier).markCompleted();
    if (!mounted) {
      return;
    }
    context.go(Routes.homeWorkers);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authSessionProvider.notifier).refresh();
    });
  }

  Future<void> _submit() async {
    final ok = await ref
        .read(keySetupProvider.notifier)
        .validateAndSave(_controller.text);
    if (!mounted) {
      return;
    }
    if (ok) {
      await _advanceAfterKeySaved();
    }
  }

  Future<void> _onQrScanned(BarcodeCapture capture) async {
    if (_scanHandled) {
      return;
    }
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) {
      return;
    }
    final key = QrScannerWidget.parseApiKeyFromPayload(raw);
    if (key == null) {
      return;
    }

    _scanHandled = true;
    await _scannerController.stop();
    setState(() {
      _controller.text = key;
    });

    final ok = await ref.read(keySetupProvider.notifier).validateAndSave(key);
    if (!mounted) {
      return;
    }
    if (ok) {
      await _advanceAfterKeySaved();
      return;
    }

    _scanHandled = false;
    await _scannerController.start();
    setState(() => _showScanner = false);
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

    if (_showScanner) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan connection QR'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: setupState.isLoading
                ? null
                : () async {
                    await _scannerController.stop();
                    setState(() {
                      _showScanner = false;
                      _scanHandled = false;
                    });
                  },
          ),
        ),
        body: Stack(
          children: [
            QrScannerWidget(
              controller: _scannerController,
              onDetect: _onQrScanned,
            ),
            if (setupState.isLoading)
              const ColoredBox(
                color: Color(0x99000000),
                child: Center(child: LoadingSpinner(message: 'Validating…')),
              ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspace connection'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.connectCursor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Paste your access code, or scan a QR from your computer.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            TextField(
              controller: _controller,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Access code',
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
              onPressed: () async {
                _scanHandled = false;
                await _scannerController.start();
                setState(() => _showScanner = true);
              },
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
