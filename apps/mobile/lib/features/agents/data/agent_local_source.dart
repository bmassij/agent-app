import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/features/agents/domain/agent_model.dart';
import 'package:cursor_mobile_commander/features/agents/domain/run_model.dart';

/// Drift persistence for [AgentSessions] and [RunRecords].
class AgentLocalSource {
  AgentLocalSource(this._db);

  final AppDatabase _db;

  Stream<List<AgentSession>> watchAgents() {
    final query = _db.select(_db.agentSessions)
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    return query.watch().map((rows) => rows.map(_mapAgent).toList());
  }

  Future<List<AgentSession>> listAgents() async {
    final rows = await (_db.select(_db.agentSessions)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
    return rows.map(_mapAgent).toList();
  }

  Future<AgentSession?> getAgent(String agentId) async {
    final row = await (_db.select(_db.agentSessions)
          ..where((t) => t.agentId.equals(agentId)))
        .getSingleOrNull();
    return row == null ? null : _mapAgent(row);
  }

  Future<void> upsertAgent({
    required String agentId,
    required String projectId,
    required String name,
    required String status,
    String? latestRunId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
  }) async {
    final now = DateTime.now().toUtc();
    await _db.into(_db.agentSessions).insertOnConflictUpdate(
          AgentSessionsCompanion.insert(
            agentId: agentId,
            projectId: projectId,
            name: name,
            status: status,
            latestRunId: Value(latestRunId),
            createdAt: createdAt ?? now,
            updatedAt: updatedAt ?? now,
            tags: Value(jsonEncode(tags ?? const [])),
          ),
        );
  }

  Future<void> upsertRun({
    required String runId,
    required String agentId,
    required String status,
    String? resultText,
    String? errorCode,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? completedAt,
  }) async {
    final now = DateTime.now().toUtc();
    await _db.into(_db.runRecords).insertOnConflictUpdate(
          RunRecordsCompanion.insert(
            runId: runId,
            agentId: agentId,
            status: status,
            resultText: Value(resultText),
            errorCode: Value(errorCode),
            errorMessage: Value(errorMessage),
            createdAt: createdAt ?? now,
            completedAt: Value(completedAt),
          ),
        );
  }

  Future<List<RunSummary>> listRunsForAgent(String agentId) async {
    final rows = await (_db.select(_db.runRecords)
          ..where((t) => t.agentId.equals(agentId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(_mapRun).toList();
  }

  Future<List<RunSummary>> listAllRuns() async {
    final rows = await (_db.select(_db.runRecords)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(_mapRun).toList();
  }

  Future<RunSummary?> getRun(String runId) async {
    final row = await (_db.select(_db.runRecords)
          ..where((t) => t.runId.equals(runId)))
        .getSingleOrNull();
    return row == null ? null : _mapRun(row);
  }

  AgentSession _mapAgent(AgentSessionRow row) {
    List<String> tags = const [];
    try {
      final decoded = jsonDecode(row.tags);
      if (decoded is List) {
        tags = decoded.whereType<String>().toList();
      }
    } catch (_) {
      tags = const [];
    }
    return AgentSession(
      agentId: row.agentId,
      projectId: row.projectId,
      name: row.name,
      status: row.status,
      latestRunId: row.latestRunId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      tags: tags,
    );
  }

  RunSummary _mapRun(RunRecordRow row) {
    return RunSummary(
      runId: row.runId,
      agentId: row.agentId,
      status: row.status,
      resultText: row.resultText,
      createdAt: row.createdAt,
      completedAt: row.completedAt,
      errorMessage: row.errorMessage,
    );
  }
}
