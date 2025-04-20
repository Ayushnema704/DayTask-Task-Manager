import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todoapp/features/tasks/data/models/task_model.dart';
import 'package:todoapp/features/tasks/data/services/task_service.dart';

// Events
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class LoadTasks extends TaskEvent {
  final String userId;

  const LoadTasks(this.userId);

  @override
  List<Object> get props => [userId];
}

class AddTask extends TaskEvent {
  final String title;
  final String userId;

  const AddTask({
    required this.title,
    required this.userId,
  });

  @override
  List<Object> get props => [title, userId];
}

class DeleteTask extends TaskEvent {
  final String taskId;

  const DeleteTask(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class ToggleTaskStatus extends TaskEvent {
  final TaskModel task;

  const ToggleTaskStatus(this.task);

  @override
  List<Object> get props => [task];
}

class EditTask extends TaskEvent {
  final TaskModel task;
  final String newTitle;

  const EditTask({
    required this.task,
    required this.newTitle,
  });

  @override
  List<Object> get props => [task, newTitle];
}

// States
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskModel> tasks;

  const TaskLoaded(this.tasks);

  @override
  List<Object> get props => [tasks];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskService _taskService;

  TaskBloc(this._taskService) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskStatus>(_onToggleTaskStatus);
    on<EditTask>(_onEditTask);
  }

  Future<void> _onLoadTasks(
    LoadTasks event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      print('Loading tasks for user: ${event.userId}');
      final tasks = await _taskService.getTasks(event.userId);
      print('Successfully loaded ${tasks.length} tasks');
      emit(TaskLoaded(tasks));
    } catch (e, stackTrace) {
      print('Error loading tasks: $e');
      print('Stack trace: $stackTrace');
      emit(TaskError('Failed to load tasks: $e'));
    }
  }

  Future<void> _onAddTask(
    AddTask event,
    Emitter<TaskState> emit,
  ) async {
    try {
      print('Adding task: ${event.title} for user: ${event.userId}');
      final newTask = await _taskService.createTask(
        title: event.title,
        userId: event.userId,
      );
      print('Successfully added task: ${newTask.id}');
      
      if (state is TaskLoaded) {
        final currentTasks = (state as TaskLoaded).tasks;
        emit(TaskLoaded([newTask, ...currentTasks]));
      } else {
        emit(TaskLoaded([newTask]));
      }
    } catch (e, stackTrace) {
      print('Error adding task: $e');
      print('Stack trace: $stackTrace');
      emit(TaskError('Failed to add task: $e'));
    }
  }

  Future<void> _onDeleteTask(
    DeleteTask event,
    Emitter<TaskState> emit,
  ) async {
    try {
      print('Deleting task: ${event.taskId}');
      await _taskService.deleteTask(event.taskId);
      print('Successfully deleted task: ${event.taskId}');
      
      if (state is TaskLoaded) {
        final currentTasks = (state as TaskLoaded).tasks;
        final updatedTasks = currentTasks
            .where((task) => task.id != event.taskId)
            .toList();
        emit(TaskLoaded(updatedTasks));
      }
    } catch (e, stackTrace) {
      print('Error deleting task: $e');
      print('Stack trace: $stackTrace');
      emit(TaskError('Failed to delete task: $e'));
    }
  }

  Future<void> _onToggleTaskStatus(
    ToggleTaskStatus event,
    Emitter<TaskState> emit,
  ) async {
    try {
      print('Toggling task status for task: ${event.task.id}');
      final updatedTask = await _taskService.toggleTaskStatus(event.task);
      print('Successfully toggled task status: ${updatedTask.id}');
      
      if (state is TaskLoaded) {
        final currentTasks = (state as TaskLoaded).tasks;
        final updatedTasks = currentTasks.map((task) {
          if (task.id == updatedTask.id) {
            return updatedTask;
          }
          return task;
        }).toList();
        emit(TaskLoaded(updatedTasks));
      }
    } catch (e, stackTrace) {
      print('Error toggling task status: $e');
      print('Stack trace: $stackTrace');
      emit(TaskError('Failed to toggle task status: $e'));
    }
  }

  Future<void> _onEditTask(
    EditTask event,
    Emitter<TaskState> emit,
  ) async {
    try {
      print('Editing task: ${event.task.id} with new title: ${event.newTitle}');
      final updatedTask = await _taskService.updateTaskTitle(
        event.task,
        event.newTitle,
      );
      print('Successfully edited task: ${updatedTask.id}');
      
      if (state is TaskLoaded) {
        final currentTasks = (state as TaskLoaded).tasks;
        final updatedTasks = currentTasks.map((task) {
          if (task.id == updatedTask.id) {
            return updatedTask;
          }
          return task;
        }).toList();
        emit(TaskLoaded(updatedTasks));
      }
    } catch (e, stackTrace) {
      print('Error editing task: $e');
      print('Stack trace: $stackTrace');
      emit(TaskError('Failed to edit task: $e'));
    }
  }
} 