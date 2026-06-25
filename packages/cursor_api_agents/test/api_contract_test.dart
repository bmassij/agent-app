import 'dart:convert';
import 'dart:io';

import 'package:cursor_api_agents/cursor_api_agents.dart';
import 'package:test/test.dart';

void main() {
  group('live API contract — request bodies', () {
    test('CreateAgentRequest serializes prompt.text schema', () {
      const request = CreateAgentRequest(
        repos: [
          AgentRepoConfig(
            url: 'https://github.com/bmassij/spaansetuin-enzo-next',
            startingRef: 'main',
          ),
        ],
        prompt: 'Reply with exactly: SPRINT4_VALIDATION_OK.',
        modelId: 'composer-2',
        mode: 'agent',
        autoCreatePr: false,
        workOnCurrentBranch: false,
      );

      final json = request.toJson();

      expect(json['prompt'],
          {'text': 'Reply with exactly: SPRINT4_VALIDATION_OK.'});
      expect(json['repos'], [
        {
          'url': 'https://github.com/bmassij/spaansetuin-enzo-next',
          'startingRef': 'main',
        },
      ]);
      expect(json['model'], {'id': 'composer-2'});
      expect(json['mode'], 'agent');
      expect(json['autoCreatePR'], false);
      expect(json['workOnCurrentBranch'], false);
      expect(json.containsKey('messages'), isFalse);
      expect(json.containsKey('options'), isFalse);
    });

    test('CreateAgentRequest supports prUrl and prompt images', () {
      final request = CreateAgentRequest.singleRepo(
        repoUrl: 'https://github.com/o/r',
        prompt: 'fix',
        prUrl: 'https://github.com/o/r/pull/1',
        modelId: 'composer-2',
        images: const [
          PromptImage(data: 'abc', mimeType: 'image/png'),
        ],
        modelParams: const [ModelParam(id: 'fast', value: true)],
        mode: 'plan',
      );

      final json = request.toJson();
      expect(json['repos'], [
        {
          'url': 'https://github.com/o/r',
          'prUrl': 'https://github.com/o/r/pull/1',
        },
      ]);
      expect(json['prompt']['images'], hasLength(1));
      expect(json['mode'], 'plan');
      expect(json['model']['params'], [
        {'id': 'fast', 'value': true},
      ]);
    });

    test('CreateRunRequest serializes prompt.text schema', () {
      const request = CreateRunRequest(
        prompt: 'Say FOLLOWUP_OFFICIAL_OK only.',
      );

      final json = request.toJson();

      expect(json, {
        'prompt': {'text': 'Say FOLLOWUP_OFFICIAL_OK only.'},
      });
      expect(json.containsKey('messages'), isFalse);
    });
  });

  group('live API contract — response parsing', () {
    test('CreateAgentResult parses nested agent/run from live capture', () {
      final raw = File('test/fixtures/live_create_agent_response.json')
          .readAsStringSync();
      final result = CreateAgentResult.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );

      expect(result.agentId, 'bc-8894ba09-4ad1-4e12-b8ea-58b4b3f24274');
      expect(result.runId, 'run-33670876-265f-4f39-9fb7-67253c272300');
      expect(result.status, 'CREATING');
    });

    test('CreateAgentResult supports legacy flat response', () {
      final result = CreateAgentResult.fromJson({
        'agentId': 'a1',
        'runId': 'r1',
        'status': 'running',
      });

      expect(result.agentId, 'a1');
      expect(result.runId, 'r1');
      expect(result.status, 'running');
    });

    test('CreateRunResult parses nested run from live capture', () {
      final raw = File('test/fixtures/live_create_run_response.json')
          .readAsStringSync();
      final result = CreateRunResult.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );

      expect(result.runId, 'run-6626bad1-d438-4fe1-86ce-64659a174e36');
      expect(result.status, 'CREATING');
    });

    test('CreateRunResult supports legacy flat response', () {
      final result = CreateRunResult.fromJson({
        'runId': 'r2',
        'status': 'running',
      });

      expect(result.runId, 'r2');
      expect(result.status, 'running');
    });

    test('AgentListPage parses items array from live capture', () {
      final raw = File('test/fixtures/live_list_agents_response.json')
          .readAsStringSync();
      final page = AgentListPage.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );

      expect(page.agents, hasLength(1));
      expect(page.agents.single.agentId,
          'bc-8894ba09-4ad1-4e12-b8ea-58b4b3f24274');
      expect(page.agents.single.name, 'Sprint 4 validation response');
      expect(
        page.agents.single.latestRunId,
        'run-6626bad1-d438-4fe1-86ce-64659a174e36',
      );
    });

    test('AgentListPage supports legacy agents array', () {
      final page = AgentListPage.fromJson({
        'agents': [
          {'id': 'a1', 'status': 'ACTIVE'},
        ],
      });

      expect(page.agents.single.agentId, 'a1');
    });

    test('RunModel parses live GET run response', () {
      final raw =
          File('test/fixtures/live_get_run_response.json').readAsStringSync();
      final run = RunModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);

      expect(run.runId, 'run-33670876-265f-4f39-9fb7-67253c272300');
      expect(run.agentId, 'bc-8894ba09-4ad1-4e12-b8ea-58b4b3f24274');
      expect(run.status, 'FINISHED');
      expect(run.resultText, 'SPRINT4_VALIDATION_OK');
    });
  });
}
