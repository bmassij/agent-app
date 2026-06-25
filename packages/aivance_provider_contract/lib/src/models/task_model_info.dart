class TaskModelInfo {
  const TaskModelInfo({
    required this.id,
    this.name,
  });

  final String id;
  final String? name;
}

class TaskModelListPage {
  const TaskModelListPage({required this.models});

  final List<TaskModelInfo> models;
}
