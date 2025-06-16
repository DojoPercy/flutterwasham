import 'dart:async';

import 'package:WashAm/presentation/common_blocs/auth/auth_bloc.dart';
import 'package:WashAm/presentation/common_blocs/auth/auth_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:WashAm/configuration/allowed_paths.dart';
import 'package:WashAm/configuration/app_logger.dart';
import 'package:WashAm/routes/app_routes_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:WashAm/routes/go_router_routes/routes/auth_routes.dart';
import 'package:WashAm/routes/go_router_routes/routes/home_routes.dart';
import 'package:WashAm/routes/go_router_routes/routes/settings_routes.dart';
import 'package:WashAm/utils/security_utils.dart';
import 'package:go_router/go_router.dart';

class ErrorScreen extends StatelessWidget {
  final GoException? error;

  const ErrorScreen(this.error, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${error?.message}'),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }
}

class AppGoRouterConfig {
  static final _log = AppLogger.getLogger("AppGoRouterConfig");
  static final GoRouter router = GoRouter(
    initialLocation: ApplicationRoutesConstants.home,
    debugLogDiagnostics: true,
    errorBuilder: (context, state) => ErrorScreen(state.error),
    routes: [
      ...HomeRoutes.routes,
      ...AuthRoutes.routes,
      ...SettingsRoutes.routes,
    ],
    redirect: (context, state) async {
      _log.debug("BEGIN: redirect");
      _log.debug("redirect - uri: ${state.uri}");
      _log.debug("authPaths: $authPaths");
      // Skip redirect for login page
      if (authPaths.any((p) => state.uri.path.startsWith(p))) {
        _log.debug("END: redirect null - with authPaths");
        return null;
      }

      // check : when redirect the new page then load the account data
      if (state.uri.toString() == ApplicationRoutesConstants.home) {}
      // check : when jwtToken is null then redirect to login page
      final isUserLogged = await SecurityUtils().isUserLoggedIn();
      final isUserExists = await SecurityUtils().isUserExists();
      if (!isUserLogged && !SecurityUtils.isAllowedPath(state.uri.toString())) {
        _log.debug("END: isUserLoggedIn is false and isAllowedPath is false");
        if (state.uri.toString() != ApplicationRoutesConstants.onboarding) {
          return ApplicationRoutesConstants.login;
        } else {}
      }
      if (isUserExists == null) {
        return null;
      }
      if (!isUserExists) {
        return ApplicationRoutesConstants.register;
      }
      if (state.uri.toString() == ApplicationRoutesConstants.home) {
        _log.debug("Loading user profile from local storage");
        context.read<AuthBloc>().add(LoadUserProfileFromStorage());
      } else {
        _log.debug("END: redirect return null");
        return null;
      }
    },
  );

  static MaterialApp routeBuilder(
      ThemeData light, ThemeData dark, String language) {
    return MaterialApp.router(
      theme: light,
      darkTheme: dark,
      debugShowCheckedModeBanner: true,
      debugShowMaterialGrid: false,
      localizationsDelegates: const [
        AppLocals.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocals.supportedLocales,
      locale: Locale(language),
      routerConfig: AppGoRouterConfig.router,
    );
  }
}
