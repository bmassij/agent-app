import 'package:aivance_capabilities/aivance_capabilities.dart';
import 'package:aivance_provider_contract/aivance_provider_contract.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockExecutionProvider extends Mock implements ExecutionProvider {}

void main() {
  group('ProviderRegistry', () {
    late ProviderRegistry registry;
    late _MockExecutionProvider cursor;

    setUp(() {
      registry = ProviderRegistry();
      cursor = _MockExecutionProvider();
      when(() => cursor.id).thenReturn('cursor');
    });

    test('registers and resolves default provider', () {
      registry.register(cursor, isDefault: true);
      expect(registry.defaultProvider, same(cursor));
      expect(registry.get('cursor'), same(cursor));
    });

    test('throws when provider is missing', () {
      expect(() => registry.get('missing'), throwsStateError);
    });

    test('tracks registered provider ids', () {
      registry.register(cursor, isDefault: true);
      expect(registry.providerIds, contains('cursor'));
      expect(registry.isRegistered('cursor'), isTrue);
    });
  });

  group('ExecutionProvider contract', () {
    test('mock can declare capabilities', () async {
      final provider = _MockExecutionProvider();
      when(() => provider.id).thenReturn('cursor');
      when(() => provider.getCapabilities()).thenAnswer(
        (_) async => right({
          ExecutionCapability.chat,
          ExecutionCapability.streaming,
        }),
      );

      final caps = await provider.getCapabilities();
      expect(caps.isRight(), isTrue);
      expect(caps.getOrElse((_) => {}), contains(ExecutionCapability.chat));
    });
  });
}
