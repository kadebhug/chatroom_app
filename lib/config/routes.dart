import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chatroom_app/views/auth/login/login_view.dart';
import 'package:chatroom_app/views/auth/register/register_view.dart';
import 'package:chatroom_app/views/home/home_view.dart';
import 'package:chatroom_app/views/room/room_list_view.dart';
import 'package:chatroom_app/views/room/single_room_view.dart';
import 'package:chatroom_app/views/settings/settings_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: "/login",
  observers: [MyNavigatorObserver()],
  routes: <RouteBase>[
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
        ),
        GoRoute(
          path: 'rooms/:id',
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
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = FirebaseAuth.instance.currentUser != null;
    final bool loggingIn = state.matchedLocation == '/login';
    final bool registering = state.matchedLocation == '/register';

    if (!loggedIn) {
      return loggingIn || registering ? null : '/login';
    }

    if (loggingIn) {
      return '/';
    }

    return null;
  },
);


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