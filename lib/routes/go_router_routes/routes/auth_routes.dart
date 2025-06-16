import 'package:WashAm/presentation/screen/get_started/register.dart';
import 'package:WashAm/presentation/screen/homepage/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:WashAm/presentation/screen/delivery_time/delivery_time.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:WashAm/presentation/screen/login/login_screen.dart';
import 'package:WashAm/presentation/screen/onboarding/onboarding_screen.dart';
import 'package:WashAm/routes/app_routes_constants.dart';

import 'package:go_router/go_router.dart';

class AuthRoutes {
  static final List<GoRoute> routes = [
    GoRoute(
        name: 'login',
        path: ApplicationRoutesConstants.login,
        builder: (context, state) => LoginScreen()),
    GoRoute(
        name: 'onboarding',
        path: ApplicationRoutesConstants.onboarding,
        builder: (context, state) => OnboardingPage()),
    GoRoute(
        name: 'register',
        path: ApplicationRoutesConstants.register,
        builder: (context, state) => RegistrationScreen())
  ];
}
