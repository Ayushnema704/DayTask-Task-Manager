import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/core/routes/app_router.dart';
import 'package:todoapp/core/theme/app_theme.dart';
import 'package:todoapp/core/theme/theme_provider.dart';
import 'package:todoapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:todoapp/features/auth/data/services/auth_service.dart';
import 'package:todoapp/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:todoapp/features/tasks/data/services/task_service.dart';
import 'package:todoapp/config/auth_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  
  await Supabase.initialize(
    url: 'https://xdigsjuxylfxkmvjzhgq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhkaWdzanV4eWxmeGttdmp6aGdxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUwNjA4NzMsImV4cCI6MjA2MDYzNjg3M30.CUOvp37bWpBME9VTpSwwEum2-ztUHerCAF5mlDPms3s',
    debug: true,
  );
  
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),
        BlocProvider(
          create: (context) => AuthBloc(
            AuthService(Supabase.instance.client),
          ),
        ),
        BlocProvider(
          create: (context) => TaskBloc(
            TaskService(Supabase.instance.client),
          )..add(LoadTasks(Supabase.instance.client.auth.currentUser?.id ?? '')),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'DayTask',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
