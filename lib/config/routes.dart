import 'dart:developer';

import 'package:chatroom_app/blocs/auth/auth_bloc.dart';
import 'package:chatroom_app/blocs/auth/auth_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:chatroom_app/views/auth/login/login_view.dart';
import 'package:chatroom_app/views/auth/register/register_view.dart';
import 'package:chatroom_app/views/home/home_view.dart';
import 'package:chatroom_app/views/room/room_list_view.dart';
import 'package:chatroom_app/views/room/single_room_view.dart';
import 'package:chatroom_app/views/settings/settings_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
          path: 'rooms',
          builder: (BuildContext context, GoRouterState state) {
            return const RoomListView();
          },
          routes: [
            GoRoute(
              path: ':id',
              builder: (BuildContext context, GoRouterState state) {
                final roomId = state.pathParameters['id'];
                return SingleRoomView(roomId: roomId!);
              },
            ),
          ],
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

  static GoRouter router = GoRouter(
    debugLogDiagnostics: kDebugMode,
    initialLocation: "/login",
    observers: [MyNavigatorObserver()],
    routes: routes,
    redirect: redirect,
  );

  static String? redirect(BuildContext context, GoRouterState state) {
    final authState = context.read<AuthBloc>().state;
    final isAuthRoute = state.matchedLocation == '/login' || 
                       state.matchedLocation == '/register';
    if (authState is AuthSuccess) {
    log('authState --> AUTH SUCCESS --> ${authState.toString()}');
      // If user is authenticated and tries to access auth routes, redirect to home
      if (isAuthRoute) {
        return '/';
      }
      return null;
    } else {
      // If user is not authenticated and tries to access protected routes, redirect to login
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
