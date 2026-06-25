import 'package:commander_orchestrator/src/models/repo_context_bundle.dart';

/// In-memory TTL cache for repository context bundles.
class ContextCache {
  ContextCache({this.defaultTtl = const Duration(minutes: 15)});

  final Duration defaultTtl;
  final Map<String, _Entry> _store = {};

  RepoContextBundle? get(String key) {
    final entry = _store[key];
    if (entry == null) {
      return null;
    }
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _store.remove(key);
      return null;
    }
    return entry.bundle;
  }

  void put(String key, RepoContextBundle bundle, {Duration? ttl}) {
    _store[key] = _Entry(
      bundle: bundle,
      expiresAt: DateTime.now().add(ttl ?? defaultTtl),
    );
  }

  void invalidate(String keyPrefix) {
    _store.removeWhere((k, _) => k.startsWith(keyPrefix));
  }

  void clear() => _store.clear();
}

class _Entry {
  _Entry({required this.bundle, required this.expiresAt});

  final RepoContextBundle bundle;
  final DateTime expiresAt;
}
