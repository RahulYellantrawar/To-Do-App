import 'package:flutter/material.dart';
import 'package:to_do/helpers/db_helper.dart'; // Import your DatabaseHelper class
import 'package:to_do/helpers/task.dart'; // Import your Task model class

class TaskProvider extends ChangeNotifier {
  final dbHelper = DatabaseHelper();
  List<Task> _tasks = [];
  List<Task> _completedTasks = [];

  List<Task> get tasks => _tasks;

  List<Task> get completedTasks => _completedTasks;

  Future<void> addTask(Task newTask) async {
    await dbHelper.insertTask(newTask);
    await fetchTasks();
    notifyListeners();
  }

  Future<void> deleteTask(int taskId) async {
    await dbHelper.deleteTask(taskId);
    await fetchTasks();
    await fetchCompletedTasks();
    notifyListeners();
  }

  Future<void> fetchTasks() async {
    await dbHelper.initDatabase();
    _tasks = await dbHelper.getTasks();
    // _completedTasks = await dbHelper.getCompletedTasks();
    notifyListeners();
  }

  Future<void> fetchCompletedTasks() async {
    await dbHelper.initDatabase();
    _completedTasks = await dbHelper.getCompletedTasks();

    notifyListeners();
  }

  Task findById(String id) {
    return _tasks.firstWhere((todo) => todo.id == id);
  }

  Future<void> updateTask(int taskId, Task task) async {
    await dbHelper.updateTask(taskId, task);
    await fetchTasks();

    notifyListeners();
  }

  Future<void> markTaskAsCompleted(
      int taskId, Task task, bool completed) async {
    task.completed = true; // Mark the task as completed
    await dbHelper.updateTaskCompletion(
      task.id!,
      true,
    );
    _tasks.remove(task);
    _completedTasks.add(task);
    print(task.completed!); // Add it to the completed tasks list
    notifyListeners(); // Notify listeners to update the UI
  }

  Future<void> markTaskAsNotCompleted(
      int taskId, Task task, bool completed) async {
    task.completed = false; // Mark the task as completed
    await dbHelper.updateTaskCompletion(
      task.id!,
      false,
    );

    _completedTasks.remove(task);
    _tasks.add(task);
    print(task.completed!); // Add it to the completed tasks list
    notifyListeners(); // Notify listeners to update the UI
  }

  List<int> completedTaskIds = [];

  // Check if a task is visible in the active tasks list
  bool isTaskVisible(Task task) {
    return !completedTaskIds.contains(task.id);
  }

  // Check if a completed task is visible in the completed tasks list
  bool isCompletedTaskVisible(Task task) {
    return completedTaskIds.contains(task.id);
  }
}
