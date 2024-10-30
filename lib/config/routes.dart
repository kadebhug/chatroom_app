import 'dart:async';
import 'dart:developer';

import 'package:chatroom_app/blocs/auth/auth_bloc.dart';
import 'package:chatroom_app/blocs/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chatroom_app/views/auth/login/login_view.dart';
import 'package:chatroom_app/views/auth/register/register_view.dart';
import 'package:chatroom_app/views/home/home_view.dart';
import 'package:chatroom_app/views/room/single_room_view.dart';
import 'package:chatroom_app/views/settings/settings_view.dart';

abstract class AppRouter {
  static const login = 'login';
  static const register = 'register';
  static const forgotPassword = 'forgot-password';
  static const home = 'home';
  static const settings = 'settings';
  static const roomList = 'rooms';
  static const room = 'room';

  static List<RouteBase> routes = [
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginView();
      },
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterView();
      },
    ),
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeView();
      },
      routes: [
        GoRoute(
          path: 'rooms/:id',
          builder: (BuildContext context, GoRouterState state) {
            final roomId = state.pathParameters['id']!;
            return SingleRoomView(roomId: roomId);
          },
        ),
        GoRoute(
          path: '/settings',
          builder: (BuildContext context, GoRouterState state) {
            return const SettingsView();
          },
        ),
      ],
    ),
  ];

  static late final GoRouter router;
  static late final AuthBloc authBloc;

  static void initialize(AuthBloc bloc) {
    authBloc = bloc;
    router = GoRouter(
      routes: routes,
      redirect: redirect,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
    );
  }

  static String? redirect(BuildContext context, GoRouterState state) {
    final authState = authBloc.state;  // Use the static authBloc instead of context.read
    final isAuthRoute = state.matchedLocation == '/login' || 
                       state.matchedLocation == '/register';

    if (authState is AuthSuccess) {
      if (isAuthRoute) {
        return '/';
      }
      return null;
    } else {
      if (!isAuthRoute) {
        return '/login';
      }
      return null;
    }
  }
}

class MyNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    log("ROUTE PUSHED: ${route.toString()} <-- ${previousRoute.toString()}");
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    log("ROUTE POPPED: ${route.toString()} <-- ${previousRoute.toString()}");
  }
}

// Add this class to handle router refreshes based on AuthBloc state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
