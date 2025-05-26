import 'package:aclinic/models/task.dart';
import 'package:aclinic/services/database_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _databaseService = DatabaseService.instance;
  String? _task = null;

  @override
  Widget build(Object context) {
    return Scaffold(
      floatingActionButton: _addTaskButton(),
      body: _taskList(),
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context as BuildContext, // Casteo necesario
          builder: (_) => AlertDialog(
            title: const Text('Add Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _task = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintText: 'Enter task content',
                  ),
                ),
                MaterialButton(
                  color: Colors.blue,
                  onPressed: () {
                    if (_task == null || _task == "") return;
                    _databaseService.addTask(_task!);
                    setState(() {
                      _task = null;
                    });
                    Navigator.of(context as BuildContext).pop();
                  },
                  child: const Text(
                    'Add Task',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }

  Widget _taskList() {
    return FutureBuilder<List<Task>>(
      future: _databaseService.getTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No tasks found.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            Task task = snapshot.data![index];
            return ListTile(
              onLongPress: () {
                _databaseService.deleteTask(task.id);
                setState(() {});
              },
              title: Text(
                task.content
                ),
              trailing: Checkbox(
                value: task.status == 1, 
                onChanged: (value) {
                  _databaseService.updateTaskStatus(
                    task.id, 
                    value == true ? 1 : 0,
                  );
                  setState(() {});
                },
              ),
            );
          },
        );
      },
    );
  }
}
