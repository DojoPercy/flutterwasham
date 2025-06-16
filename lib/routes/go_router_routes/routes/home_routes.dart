import 'package:WashAm/presentation/screen/homepage/homescreen.dart';
import 'package:WashAm/presentation/screen/homepage/schedule_order.dart';
import 'package:WashAm/presentation/screen/profile/profile_screen.dart';
import 'package:WashAm/routes/app_routes_constants.dart';
import 'package:go_router/go_router.dart';

class HomeRoutes {
  static final List<GoRoute> routes = [
    GoRoute(
      name: 'home',
      path: ApplicationRoutesConstants.home,
      builder: (context, state) => HomeScreen(),
      routes: [
        GoRoute(
          name: 'schedule',
          path: 'schedule',
          builder: (context, state) => ScheduleOrderScreen(),
        ),
        GoRoute(
          name: 'profile',
          path: 'profile',
          builder: (context, state) => MyProfilePage(),
        ),
      ],
    ),
  ];
}
