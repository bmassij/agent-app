import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cursor_mobile_commander/features/chat/presentation/chat_provider.dart';

/// Model picker bottom sheet (GET /v1/models).
class ModelPickerSheet extends ConsumerWidget {
  const ModelPickerSheet({
    required this.onSelected,
    super.key,
  });

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelsAsync = ref.watch(modelsProvider);

    return modelsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(e.toString()),
      ),
      data: (page) {
        if (page.models.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No models available'),
          );
        }
        return ListView(
          shrinkWrap: true,
          children: [
            for (final model in page.models)
              ListTile(
                title: Text(model.name ?? model.id),
                subtitle: Text(model.id),
                onTap: () {
                  Navigator.of(context).pop();
                  onSelected(model.id);
                },
              ),
          ],
        );
      },
    );
  }
}
