import 'dart:developer';

import 'package:chatroom_app/blocs/app_block_observer.dart';
import 'package:chatroom_app/config/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:chatroom_app/config/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chatroom_app/blocs/theme/theme_bloc.dart';
import 'package:chatroom_app/blocs/theme/theme_state.dart';
import 'package:chatroom_app/repositories/auth_repository.dart';
import 'package:chatroom_app/blocs/auth/auth_bloc.dart';
import 'package:chatroom_app/repositories/room_repository.dart';
import 'package:chatroom_app/blocs/room/room_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.windows,
    );
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  
  final prefs = await SharedPreferences.getInstance();
  final authRepository = AuthRepository();
  final authBloc = AuthBloc(authRepository: authRepository);
  final roomRepository = RoomRepository();
  
  // Wait for initial user value
  await authRepository.user.first;
  
  // Initialize router with authBloc
  AppRouter.initialize(authBloc);
  
  // Check initial auth status
  authBloc.checkAuthStatus();

  // Listen for Auth changes and refresh the GoRouter
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    authBloc.checkAuthStatus();
  });
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeBloc(prefs)),
        BlocProvider(create: (context) => authBloc),
        BlocProvider(create: (context) => RoomBloc(roomRepository: roomRepository)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp.router(
          title: 'Chatroom App',
          theme: themeState.themeData,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
