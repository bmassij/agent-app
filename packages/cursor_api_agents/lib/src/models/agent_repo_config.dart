/// Repository target for [CreateAgentRequest] per Cloud Agents API v1.
class AgentRepoConfig {
  const AgentRepoConfig({
    required this.url,
    this.startingRef,
    this.prUrl,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        if (startingRef != null) 'startingRef': startingRef,
        if (prUrl != null) 'prUrl': prUrl,
      };

  final String url;
  final String? startingRef;
  final String? prUrl;
}
