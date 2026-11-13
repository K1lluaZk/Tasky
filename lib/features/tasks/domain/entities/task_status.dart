enum TaskStatus { pending, completed, cancelled }

extension TaskStatusParsing on TaskStatus {
  static TaskStatus fromString(String value) => TaskStatus.values
      .firstWhere((status) => status.name == value, orElse: () => TaskStatus.pending);
}
