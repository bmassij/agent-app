import 'package:aivance_provider_contract/src/execution_provider.dart';

/// Registers and resolves [ExecutionProvider] instances for dependency injection.
class ProviderRegistry {
  ProviderRegistry();

  final Map<String, ExecutionProvider> _providers = {};
  String? _defaultProviderId;

  /// Registers a provider. When [isDefault] is true, it becomes the default.
  void register(ExecutionProvider provider, {bool isDefault = false}) {
    _providers[provider.id] = provider;
    if (isDefault || _defaultProviderId == null) {
      _defaultProviderId = provider.id;
    }
  }

  /// Returns a registered provider by id.
  ExecutionProvider get(String providerId) {
    final provider = _providers[providerId];
    if (provider == null) {
      throw StateError('ExecutionProvider not registered: $providerId');
    }
    return provider;
  }

  /// Returns the default registered provider.
  ExecutionProvider get defaultProvider {
    final id = _defaultProviderId;
    if (id == null) {
      throw StateError('No ExecutionProvider registered');
    }
    return get(id);
  }

  /// All registered provider ids.
  Iterable<String> get providerIds => _providers.keys;

  /// Whether a provider id is registered.
  bool isRegistered(String providerId) => _providers.containsKey(providerId);

  /// Clears all registrations (for tests).
  void clear() {
    _providers.clear();
    _defaultProviderId = null;
  }
}
