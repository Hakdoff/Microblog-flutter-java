import 'package:flutter/material.dart';
import 'package:flutter_java_crud/register/task/Services/database_services.dart';
import 'package:flutter_java_crud/register/task/model/task.dart';

class TasksData extends ChangeNotifier{
  List<Task> tasks = [];

  Future<void> getTasks() async {
    tasks = await DatabaseServices.getTasks();
    notifyListeners();
  }

  void addTask(String taskTitle) async {
    Task task = await DatabaseServices.addTask(taskTitle);
    tasks.add(task);
    notifyListeners();
  }

  // void updateTask(Task task) {
  //   tasks.toggle();
  //   // DatabaseServices.updateTask(task.id);
  //   notifyListeners();
  // }

  void deleteTask(Task task) {
    tasks.remove(task);
    // DatabaseServices.deleteTask(task.id);
    notifyListeners();
  }
}