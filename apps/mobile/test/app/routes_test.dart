import 'package:flutter_test/flutter_test.dart';

import 'package:cursor_mobile_commander/app/routes.dart';

void main() {
  group('Routes', () {
    test('onboarding paths are stable', () {
      expect(Routes.onboarding, '/onboarding');
      expect(Routes.connectCursor, '/onboarding/connect-cursor');
      expect(Routes.connectGithub, '/onboarding/connect-github');
    });

    test('home tab paths are stable', () {
      expect(Routes.homeProjects, '/home/projects');
      expect(Routes.homeAgents, '/home/agents');
      expect(Routes.homeSettings, '/home/settings');
    });

    test('parameterized helpers build expected paths', () {
      expect(Routes.projectDetail('abc'), '/home/projects/abc');
      expect(Routes.agentChat('bc-1'), '/home/agents/bc-1/chat');
      expect(Routes.prDetail('org', 'repo', 42), '/review/org/repo/pulls/42');
    });
  });
}
