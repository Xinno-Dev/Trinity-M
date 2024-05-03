import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larba_00/common/provider/temp_provider.dart';

final routerProvider = Provider<GoRouter>(
  (ref) {
    final provider = ref.read(tempProvider);
    return GoRouter(
      routes: provider.route,
      initialLocation: '/firebaseSetup',
      // initialLocation: '/login',
      refreshListenable: provider,
      redirect: provider.redirectLogic,
    );
  },
);
