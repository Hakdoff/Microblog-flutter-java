import 'package:flutter/material.dart';
import 'package:flutter_java_crud/register/task/Services/pages/services/task_service.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isChecked = false;

  TaskService taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Task"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const 
            EdgeInsets.all(8),
          child: Column(
            children: [
              const SizedBox(height: 10,),
              TextField(
                controller: titleController,
                decoration: const 
                InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Title"
                ),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: descriptionController,
                decoration: const 
                InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Description"
                ),
              ),
              const SizedBox(height: 10,),
              Checkbox(value: isChecked, onChanged: (bool? value){
                setState(() {
                  isChecked = value!;
                });
              }),
            ElevatedButton(onPressed: (){
              taskService.saveTask(titleController.text,
              descriptionController.text,
              isChecked
              ); titleController.clear();
              descriptionController.clear();
              setState(() {
                isChecked = false;
              });
            }, child: const Text('Save'))
            ],
          ),
        ),
      ),
    );
  }
}