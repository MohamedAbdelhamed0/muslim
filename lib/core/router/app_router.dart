import 'package:go_router/go_router.dart';
import '../../features/adhan/presentation/ui_desktop/adhan_desktop_screen.dart';
import '../../features/adhan/presentation/ui_mobile/adhan_mobile_screen.dart';

GoRouter createRouter({required bool isDesktop}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'adhan',
        builder: (context, state) {
          return isDesktop ? const AdhanDesktopScreen() : const AdhanMobileScreen();
        },
      ),
    ],
  );
}
