import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';

class MobileOrganizerApp extends ConsumerWidget {
  const MobileOrganizerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Organizador Personal',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
