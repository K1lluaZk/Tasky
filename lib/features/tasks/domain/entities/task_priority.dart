enum TaskPriority { low, medium, high }

extension TaskPriorityParsing on TaskPriority {
  static TaskPriority fromString(String value) => TaskPriority.values
      .firstWhere((priority) => priority.name == value, orElse: () => TaskPriority.medium);
}
