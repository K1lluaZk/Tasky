import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';

class TaskListPage extends ConsumerWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(taskControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: tasksState.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(child: Text('No hay tareas aún'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final task = tasks[index];

              return Card(
                child: ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.description ?? 'Sin descripción'),
                  trailing: Text(task.priorityLabel),
                ),
              );
            },
          );
        },
        error: (error, stackTrace) =>
            Center(child: Text('Error al cargar tareas: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
