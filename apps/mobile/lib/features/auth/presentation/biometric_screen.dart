import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cursor_mobile_commander/features/auth/domain/auth_failure.dart';
import 'package:cursor_mobile_commander/features/auth/presentation/auth_provider.dart';
import 'package:cursor_mobile_commander/shared/constants/colors.dart';
import 'package:cursor_mobile_commander/shared/constants/sizes.dart';
import 'package:cursor_mobile_commander/shared/widgets/loading_spinner.dart';

/// Biometric unlock gate shown on app launch when enabled.
class BiometricScreen extends ConsumerStatefulWidget {
  const BiometricScreen({
    required this.onUnlocked,
    super.key,
  });

  final VoidCallback onUnlocked;

  @override
  ConsumerState<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends ConsumerState<BiometricScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _authenticate() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = await ref.read(authRepositoryProvider.future);
    final result = await repo.authenticateWithBiometric();
    if (!mounted) {
      return;
    }
    result.fold(
      (failure) {
        setState(() {
          _loading = false;
          _error = switch (failure) {
            BiometricFailure(:final message) => message,
            _ => 'Authentication failed',
          };
        });
      },
      (_) {
        ref.read(biometricUnlockedProvider.notifier).unlock();
        widget.onUnlocked();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fingerprint, size: 64, color: AppColors.accent),
              const SizedBox(height: AppSizes.paddingMedium),
              Text(
                'Unlock with biometrics',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              if (_error != null)
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
              const SizedBox(height: AppSizes.paddingLarge),
              if (_loading) const LoadingSpinner(),
              if (!_loading)
                FilledButton(
                  onPressed: _authenticate,
                  child: const Text('Try again'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
