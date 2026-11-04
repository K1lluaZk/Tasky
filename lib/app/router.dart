import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/tasks/presentation/pages/task_list_page.dart';

final routerProvider = Provider<GoRouter>((ref) => AppRouter.router);

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const TaskListPage()),
    ],
  );
}
