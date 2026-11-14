class Event {
  const Event({
    required this.id,
    required this.title,
    this.description,
    this.categoryId,
    required this.isAllDay,
    this.eventDate,
    this.startAt,
    this.endAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String? description;
  final String? categoryId;
  final bool isAllDay;
  /// Date-only value for an all-day event. Persistence uses `YYYY-MM-DD`.
  final DateTime? eventDate;
  /// Local date/time values persisted as Unix epoch milliseconds.
  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Validates the mutually exclusive date and time fields for both event types.
  bool get isValidTimeInterval {
    if (isAllDay) {
      return eventDate != null && startAt == null && endAt == null;
    }
    return eventDate == null &&
        startAt != null &&
        endAt != null &&
        endAt!.isAfter(startAt!);
  }

  String? get validationMessage {
    if (title.trim().isEmpty) return 'El título del evento es obligatorio.';
    if (!isValidTimeInterval) {
      return isAllDay
          ? 'Un evento de día completo requiere fecha y no acepta horario.'
          : 'Un evento con horario requiere inicio y fin, el fin debe ser posterior y no admite fecha de día completo.';
    }
    return null;
  }

  bool get isValid => validationMessage == null;

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    bool? isAllDay,
    DateTime? eventDate,
    DateTime? startAt,
    DateTime? endAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDescription = false,
    bool clearCategoryId = false,
    bool clearEventDate = false,
    bool clearStartAt = false,
    bool clearEndAt = false,
  }) =>
      Event(
        id: id ?? this.id,
        title: title ?? this.title,
        description: clearDescription ? null : description ?? this.description,
        categoryId: clearCategoryId ? null : categoryId ?? this.categoryId,
        isAllDay: isAllDay ?? this.isAllDay,
        eventDate: clearEventDate ? null : eventDate ?? this.eventDate,
        startAt: clearStartAt ? null : startAt ?? this.startAt,
        endAt: clearEndAt ? null : endAt ?? this.endAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event &&
          other.id == id &&
          other.title == title &&
          other.description == description &&
          other.categoryId == categoryId &&
          other.isAllDay == isAllDay &&
          other.eventDate == eventDate &&
          other.startAt == startAt &&
          other.endAt == endAt &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        title,
        description,
        categoryId,
        isAllDay,
        eventDate,
        startAt,
        endAt,
        createdAt,
        updatedAt,
      );
}
