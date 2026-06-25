/// Normalizes GitHub repository URLs without provider-specific types.
class RepoUrlUtils {
  const RepoUrlUtils._();

  static String normalize(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('github.com/')) {
      return 'https://$trimmed';
    }
    if (!trimmed.contains('://') && trimmed.contains('/')) {
      return 'https://github.com/$trimmed';
    }
    return trimmed;
  }
}
