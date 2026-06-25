import 'package:aivance_capabilities/aivance_capabilities.dart';
import 'package:test/test.dart';

void main() {
  group('ExecutionCapability', () {
    test('each capability has a stable id', () {
      for (final cap in ExecutionCapability.values) {
        expect(cap.id, isNotEmpty);
        expect(executionCapabilityFromId(cap.id), cap);
      }
    });

    test('includes required execution capabilities', () {
      expect(ExecutionCapability.values, contains(ExecutionCapability.chat));
      expect(
          ExecutionCapability.values, contains(ExecutionCapability.streaming));
      expect(
          ExecutionCapability.values, contains(ExecutionCapability.followUps));
      expect(ExecutionCapability.values,
          contains(ExecutionCapability.repositories));
    });
  });
}
