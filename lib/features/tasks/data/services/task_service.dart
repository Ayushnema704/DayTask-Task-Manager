import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todoapp/features/tasks/data/models/task_model.dart';

class TaskService {
  final SupabaseClient _supabaseClient;

  TaskService(this._supabaseClient);

  Future<void> testConnection() async {
    try {
      print('Testing database connection...');
      // Try to get the current user's ID
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }
      print('Current user ID: ${user.id}');

      // Try to query the tasks table
      final response = await _supabaseClient
          .from('tasks')
          .select('count')
          .eq('user_id', user.id)
          .single();

      print('Database connection test successful');
      print('Current user has ${response['count']} tasks');
    } catch (e, stackTrace) {
      print('Database connection test failed');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.details}');
        print('Postgrest error hint: ${e.hint}');
        print('Postgrest error code: ${e.code}');
      }
      rethrow;
    }
  }

  Future<List<TaskModel>> getTasks(String userId) async {
    try {
      print('Fetching tasks for user: $userId');
      print('Supabase client state: ${_supabaseClient.auth.currentUser?.id}');
      
      final response = await _supabaseClient
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('Raw response: $response');
      print('Tasks fetched successfully: ${response.length} tasks');
      return (response as List)
          .map((task) => TaskModel.fromJson(task))
          .toList();
    } catch (e, stackTrace) {
      print('Error fetching tasks: $e');
      print('Stack trace: $stackTrace');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.details}');
        print('Postgrest error hint: ${e.hint}');
        print('Postgrest error code: ${e.code}');
      }
      rethrow;
    }
  }

  Future<TaskModel> createTask({
    required String title,
    required String userId,
  }) async {
    try {
      print('Creating task for user: $userId with title: $title');
      final response = await _supabaseClient.from('tasks').insert({
        'title': title,
        'user_id': userId,
        'is_completed': false,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      print('Task created successfully: ${response['id']}');
      return TaskModel.fromJson(response);
    } catch (e, stackTrace) {
      print('Error creating task: $e');
      print('Stack trace: $stackTrace');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.details}');
        print('Postgrest error hint: ${e.hint}');
        print('Postgrest error code: ${e.code}');
      }
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      print('Deleting task: $taskId');
      await _supabaseClient
          .from('tasks')
          .delete()
          .eq('id', taskId);

      print('Task deleted successfully: $taskId');
    } catch (e, stackTrace) {
      print('Error deleting task: $e');
      print('Stack trace: $stackTrace');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.details}');
        print('Postgrest error hint: ${e.hint}');
        print('Postgrest error code: ${e.code}');
      }
      rethrow;
    }
  }

  Future<TaskModel> toggleTaskStatus(TaskModel task) async {
    try {
      print('Toggling task status for task: ${task.id}');
      final response = await _supabaseClient
          .from('tasks')
          .update({'is_completed': !task.isCompleted})
          .eq('id', task.id)
          .select()
          .single();

      print('Task status toggled successfully: ${task.id}');
      return TaskModel.fromJson(response);
    } catch (e, stackTrace) {
      print('Error toggling task status: $e');
      print('Stack trace: $stackTrace');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.details}');
        print('Postgrest error hint: ${e.hint}');
        print('Postgrest error code: ${e.code}');
      }
      rethrow;
    }
  }

  Future<TaskModel> updateTaskTitle(TaskModel task, String newTitle) async {
    try {
      print('Updating task title: ${task.id} to: $newTitle');
      final response = await _supabaseClient
          .from('tasks')
          .update({'title': newTitle})
          .eq('id', task.id)
          .select()
          .single();

      print('Task title updated successfully: ${task.id}');
      return TaskModel.fromJson(response);
    } catch (e, stackTrace) {
      print('Error updating task title: $e');
      print('Stack trace: $stackTrace');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.details}');
        print('Postgrest error hint: ${e.hint}');
        print('Postgrest error code: ${e.code}');
      }
      rethrow;
    }
  }
} 