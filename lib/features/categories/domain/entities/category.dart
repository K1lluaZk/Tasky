/// Pure Dart domain entity representing a category.
/// Categories are shared across tasks and events to classify activities with colors and optional icons.
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String color;
  final String? icon;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Validates whether a given string is a valid 6 or 8-digit hex color format.
  static bool isValidHexColor(String hex) {
    final clean = hex.trim();
    final hexRegex = RegExp(r'^#([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');
    return hexRegex.hasMatch(clean);
  }

  /// Returns the 32-bit ARGB integer value for UI rendering (e.g., Color(category.colorValue)),
  /// keeping the domain entity independent of Flutter's UI libraries.
  int get colorValue {
    var hexStr = color.replaceAll('#', '').trim();
    if (hexStr.length == 6) {
      hexStr = 'FF$hexStr';
    }
    return int.tryParse(hexStr, radix: 16) ?? 0xFF9E9E9E;
  }

  Category copyWith({
    String? id,
    String? name,
    String? color,
    String? icon,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.color == color &&
        other.icon == icon &&
        other.isDefault == isDefault;
  }

  @override
  int get hashCode => Object.hash(id, name, color, icon, isDefault);
}
