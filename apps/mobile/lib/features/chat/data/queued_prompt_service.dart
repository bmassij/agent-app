import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:cursor_mobile_commander/core/database/app_database.dart';

/// Persists and processes offline prompt queue ([QueuedPrompts] table).
class QueuedPromptService {
  QueuedPromptService(this._db);

  final AppDatabase _db;

  Future<String> enqueue({
    required String repoUrl,
    required String promptText,
    String? agentId,
    Map<String, dynamic> options = const {},
  }) async {
    final id =
        '${DateTime.now().toUtc().microsecondsSinceEpoch}-${promptText.hashCode}';
    await _db.into(_db.queuedPrompts).insert(
          QueuedPromptsCompanion.insert(
            id: id,
            agentId: Value(agentId),
            repoUrl: repoUrl,
            promptText: promptText,
            options: Value(jsonEncode(options)),
            createdAt: DateTime.now().toUtc(),
            status: const Value('pending'),
          ),
        );
    return id;
  }

  Future<List<QueuedPromptRow>> listPending() async {
    return (_db.select(_db.queuedPrompts)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<void> markSent(String id) async {
    await (_db.update(_db.queuedPrompts)..where((t) => t.id.equals(id))).write(
      QueuedPromptsCompanion(
        status: const Value('sent'),
      ),
    );
  }

  Future<void> markFailed(String id, {String? reason}) async {
    await (_db.update(_db.queuedPrompts)..where((t) => t.id.equals(id))).write(
      QueuedPromptsCompanion(
        status: const Value('failed'),
        options: Value(
          jsonEncode({'error': reason ?? 'send_failed'}),
        ),
      ),
    );
  }

  Future<int> pendingCount() async {
    final rows = await listPending();
    return rows.length;
  }
}
