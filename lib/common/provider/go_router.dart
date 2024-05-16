import '../../../common/common_package.dart';
import 'temp_provider.dart';

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
