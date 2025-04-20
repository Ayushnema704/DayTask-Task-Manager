import 'package:go_router/go_router.dart';
import 'package:todoapp/features/auth/presentation/pages/login_page.dart';
import 'package:todoapp/features/auth/presentation/pages/signup_page.dart';
import 'package:todoapp/features/tasks/presentation/pages/dashboard_page.dart';
import 'package:todoapp/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:todoapp/features/splash/presentation/pages/splash_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:todoapp/features/auth/data/models/user_model.dart';
import 'package:todoapp/features/tasks/presentation/bloc/task_bloc.dart';

final AppRouter = _AppRouter();

class _AppRouter {
  late final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) {
          print('Building splash screen route');
          return const SplashPage();
        },
      ),
      GoRoute(
        path: '/',
        builder: (context, state) {
          final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
          return isLoggedIn ? const DashboardPage() : const OnboardingPage();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/auth/callback',
        builder: (context, state) {
          final uri = Uri.parse(state.uri.toString());
          final accessToken = uri.queryParameters['access_token'];
          final refreshToken = uri.queryParameters['refresh_token'];
          
          if (accessToken != null && refreshToken != null) {
            final user = Supabase.instance.client.auth.currentUser;
            if (user != null) {
              final userModel = UserModel(
                id: user.id,
                email: user.email!,
              );
              context.read<AuthBloc>().add(AuthStateChanged(userModel));
              context.read<TaskBloc>().add(LoadTasks(user.id));
              return const SplashPage();
            }
          }
          return const LoginPage();
        },
      ),
    ],
    redirect: (context, state) async {
      final currentUser = Supabase.instance.client.auth.currentUser;
      final isLoggedIn = currentUser != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';
      final isOnSplash = state.matchedLocation == '/splash';

      // Don't redirect if on splash or handling auth callback
      if (isOnSplash || state.matchedLocation == '/auth/callback') {
        return null;
      }

      // Handle other redirects
      if (!isLoggedIn && !isAuthRoute && state.matchedLocation != '/') {
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/splash';
      }

      return null;
    },
  );
}
