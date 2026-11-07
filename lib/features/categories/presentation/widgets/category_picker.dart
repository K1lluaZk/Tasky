import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';

/// Interactive selector that allows choosing from available categories or selecting none.
class CategoryPicker extends ConsumerWidget {
  const CategoryPicker({
    super.key,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final String? selectedCategoryId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoryControllerProvider);

    return categoriesState.when(
      data: (categories) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Sin categoría'),
              selected: selectedCategoryId == null,
              onSelected: (selected) {
                if (selected) onSelected(null);
              },
            ),
            ...categories.map((category) {
              final isSelected = selectedCategoryId == category.id;
              final color = Color(category.colorValue);

              return ChoiceChip(
                avatar: CircleAvatar(
                  backgroundColor: color,
                  radius: 5,
                ),
                label: Text(category.name),
                selected: isSelected,
                selectedColor: color.withValues(alpha: 0.25),
                onSelected: (selected) {
                  onSelected(selected ? category.id : null);
                },
              );
            }),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 36,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (err, _) => Text(
        'Error al cargar categorías: $err',
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }
}
