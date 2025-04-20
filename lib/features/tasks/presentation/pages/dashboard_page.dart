import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:todoapp/core/theme/theme_provider.dart';
import 'package:todoapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:todoapp/features/auth/data/models/user_model.dart';
import 'package:todoapp/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:todoapp/features/tasks/presentation/pages/home_screen.dart';
import 'package:todoapp/features/tasks/presentation/pages/chat_screen.dart';
import 'package:todoapp/features/tasks/presentation/pages/calendar_screen.dart';
import 'package:todoapp/features/tasks/presentation/pages/notifications_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _taskController = TextEditingController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  void _loadTasks() {
    final currentUser = Supabase.instance.client.auth.currentUser;
    print('Loading tasks, current user: ${currentUser?.id}');
    
    if (currentUser != null) {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthSuccess) {
        print('Restoring auth state in dashboard...');
        context.read<AuthBloc>().add(
              AuthStateChanged(
                UserModel(
                  id: currentUser.id,
                  email: currentUser.email!,
                ),
              ),
            );
      }
      context.read<TaskBloc>().add(LoadTasks(currentUser.id));
    } else {
      print('No authenticated user found in dashboard');
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _showAddTaskDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'Enter task title',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final currentUser = Supabase.instance.client.auth.currentUser;
                  print('Adding task, current user: ${currentUser?.id}');
                  
                  if (currentUser != null && _taskController.text.isNotEmpty) {
                    print('Adding task: ${_taskController.text} for user: ${currentUser.id}');
                    context.read<TaskBloc>().add(
                          AddTask(
                            title: _taskController.text.trim(),
                            userId: currentUser.id,
                          ),
                        );
                    _taskController.clear();
                    Navigator.pop(context);
                    
                    // Reload tasks after adding
                    context.read<TaskBloc>().add(LoadTasks(currentUser.id));
                  } else {
                    print('Cannot add task: ${currentUser == null ? 'User not authenticated' : 'Empty task'}');
                    if (currentUser == null) {
                      context.go('/login');
                    }
                  }
                },
                child: const Text('Add Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              title: Text(
                Theme.of(context).brightness == Brightness.dark
                    ? 'Light Mode'
                    : 'Dark Mode',
              ),
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (value) {
                  context.read<ThemeProvider>().toggleTheme();
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  context.read<AuthBloc>().add(LogoutRequested());
                  context.go('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsMenu(context),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(),
          ChatScreen(),
          SizedBox(),
          CalendarScreen(),
          NotificationsScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: const Color(0xFFFFD233),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.home_outlined,
                color: _currentIndex == 0 ? const Color(0xFFFFD233) : Colors.grey,
              ),
              onPressed: () => setState(() => _currentIndex = 0),
            ),
            IconButton(
              icon: Icon(
                Icons.chat_bubble_outline,
                color: _currentIndex == 1 ? const Color(0xFFFFD233) : Colors.grey,
              ),
              onPressed: () => setState(() => _currentIndex = 1),
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: Icon(
                Icons.calendar_today_outlined,
                color: _currentIndex == 3 ? const Color(0xFFFFD233) : Colors.grey,
              ),
              onPressed: () => setState(() => _currentIndex = 3),
            ),
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: _currentIndex == 4 ? const Color(0xFFFFD233) : Colors.grey,
              ),
              onPressed: () => setState(() => _currentIndex = 4),
            ),
          ],
        ),
      ),
    );
  }
} 