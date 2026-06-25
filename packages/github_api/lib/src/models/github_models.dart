import 'dart:convert';

class GithubRepoModel {
  const GithubRepoModel({
    required this.fullName,
    required this.htmlUrl,
    this.defaultBranch,
    this.privateRepo,
  });

  factory GithubRepoModel.fromJson(Map<String, dynamic> json) {
    return GithubRepoModel(
      fullName: json['full_name'] as String? ?? '',
      htmlUrl: json['html_url'] as String? ?? '',
      defaultBranch: json['default_branch'] as String?,
      privateRepo: json['private'] as bool?,
    );
  }

  final String fullName;
  final String htmlUrl;
  final String? defaultBranch;
  final bool? privateRepo;
}

class GithubPullRequestModel {
  const GithubPullRequestModel({
    required this.number,
    required this.title,
    required this.state,
    this.mergeable,
    this.mergeableState,
    this.draft,
    this.htmlUrl,
  });

  factory GithubPullRequestModel.fromJson(Map<String, dynamic> json) {
    return GithubPullRequestModel(
      number: json['number'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      state: json['state'] as String? ?? 'open',
      mergeable: json['mergeable'] as bool?,
      mergeableState: json['mergeable_state'] as String?,
      draft: json['draft'] as bool?,
      htmlUrl: json['html_url'] as String?,
    );
  }

  final int number;
  final String title;
  final String state;
  final bool? mergeable;
  final String? mergeableState;
  final bool? draft;
  final String? htmlUrl;
}

class GithubPullFileModel {
  const GithubPullFileModel({
    required this.filename,
    this.patch,
    this.status,
  });

  factory GithubPullFileModel.fromJson(Map<String, dynamic> json) {
    return GithubPullFileModel(
      filename: json['filename'] as String? ?? '',
      patch: json['patch'] as String?,
      status: json['status'] as String?,
    );
  }

  final String filename;
  final String? patch;
  final String? status;
}

class GithubBranchModel {
  const GithubBranchModel({required this.name, this.sha});

  factory GithubBranchModel.fromJson(Map<String, dynamic> json) {
    final commit = json['commit'] as Map<String, dynamic>?;
    return GithubBranchModel(
      name: json['name'] as String? ?? '',
      sha: commit?['sha'] as String?,
    );
  }

  final String name;
  final String? sha;
}

class GithubFileContent {
  const GithubFileContent({
    required this.path,
    required this.content,
    this.encoding,
  });

  factory GithubFileContent.fromJson(Map<String, dynamic> json) {
    return GithubFileContent(
      path: json['path'] as String? ?? '',
      content: json['content'] as String? ?? '',
      encoding: json['encoding'] as String?,
    );
  }

  String decodeUtf8() {
    if (encoding == 'base64') {
      final normalized = content.replaceAll('\n', '');
      return utf8.decode(base64.decode(normalized));
    }
    return content;
  }

  final String path;
  final String content;
  final String? encoding;
}

class GithubCheckStatus {
  const GithubCheckStatus({
    required this.state,
    this.totalCount,
    this.failingContexts,
  });

  final String state;
  final int? totalCount;
  final List<String>? failingContexts;
}

class GithubCommitModel {
  const GithubCommitModel({
    required this.sha,
    required this.message,
  });

  factory GithubCommitModel.fromJson(Map<String, dynamic> json) {
    final commit = json['commit'] as Map<String, dynamic>? ?? {};
    return GithubCommitModel(
      sha: json['sha'] as String? ?? '',
      message: commit['message'] as String? ?? '',
    );
  }

  final String sha;
  final String message;
}
