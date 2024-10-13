import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chatroom_app/views/auth/login/login_view.dart';
import 'package:chatroom_app/views/auth/register/register_view.dart';
import 'package:chatroom_app/views/home/home_view.dart';
import 'package:chatroom_app/views/room/room_list_view.dart';
import 'package:chatroom_app/views/room/single_room_view.dart';
import 'package:chatroom_app/views/settings/settings_view.dart';

final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: "/settings",
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
  // Add a redirect to implement guards for protected routes
  redirect: (BuildContext context, GoRouterState state) {
    // Implement your authentication logic here
    bool isAuthenticated = true; // Replace with actual auth check
    
    if (!isAuthenticated && 
        !(state.matchedLocation == '/login' || state.matchedLocation == '/register')) {
      return '/login';
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
