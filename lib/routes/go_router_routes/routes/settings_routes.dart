import 'package:flutter/material.dart';

import 'package:WashAm/routes/app_routes_constants.dart';
import 'package:go_router/go_router.dart';

class SettingsRoutes {
  static final List<GoRoute> routes = [
    GoRoute(
        name: 'settings',
        path: ApplicationRoutesConstants.settings,
        builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Settings')),
              body: Text('Settings Page'),
            )),
  ];
}
